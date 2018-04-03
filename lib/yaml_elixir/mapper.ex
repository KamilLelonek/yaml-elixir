defmodule YamlElixir.Mapper do
  def process(nil, _options), do: %{}
  def process(yaml, options) when is_list(yaml), do: Enum.map(yaml, &process(&1, options))
  def process(yaml, options), do: yaml |> _to_map(options) |> extract_map()

  defp extract_map(nil), do: %{}
  defp extract_map(map), do: map

  defp _to_map({:yamerl_doc, document}, options), do: _to_map(document, options)

  defp _to_map({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}, options),
    do: Enum.map(seq, &_to_map(&1, options))

  defp _to_map({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}, options),
    do: _tuples_to_map(map_tuples, %{}, options)

  defp _to_map({:yamerl_str, :yamerl_node_str, _tag, _loc, <<?:, elem::binary>>}, atoms: true),
    do: String.to_atom(elem)

  defp _to_map({:yamerl_null, :yamerl_node_null, _tag, _loc}, _options), do: nil
  defp _to_map({_yamler_element, _yamler_node_element, _tag, _loc, elem}, _options), do: elem

  defp _tuples_to_map([], map, _options), do: map

  defp _tuples_to_map([{key, val} | rest], map, options) do
    case key do
      {:yamerl_seq, :yamerl_node_seq, _tag, _log, _seq, _n} ->
        _tuples_to_map(
          rest,
          Map.put_new(map, _to_map(key, options), _to_map(val, options)),
          options
        )

      {_yamler_element, _yamler_node_element, _tag, _log, name} ->
        _tuples_to_map(
          rest,
          Map.put_new(map, key_for(name, options), _to_map(val, options)),
          options
        )
    end
  end

  defp key_for(<<?:, name::binary>>, atoms: true), do: String.to_atom(name)
  defp key_for(name, _options), do: name
end
