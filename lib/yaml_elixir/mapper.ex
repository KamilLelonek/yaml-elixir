defmodule YamlElixir.Mapper do
  def process(nil, options), do: empty_container(options)
  def process(yaml, options) when is_list(yaml), do: Enum.map(yaml, &process(&1, options))

  def process(yaml, options),
    do:
      yaml
      |> _to_map(options)
      |> extract_map(options)

  defp extract_map(nil, options), do: empty_container(options)
  defp extract_map(map, _), do: map

  defp _to_map({:yamerl_doc, document}, options), do: _to_map(document, options)

  defp _to_map({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}, options),
    do: Enum.map(seq, &_to_map(&1, options))

  defp _to_map({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}, options),
    do: _tuples_to_map(map_tuples, empty_container(options), options)

  defp _to_map(
         {:yamerl_str, :yamerl_node_str, _tag, _loc, <<?:, elem::binary>> = original_elem},
         options
       ) do
    if Keyword.get(options, :atoms) do
      String.to_atom(elem)
    else
      original_elem
    end
  end

  defp _to_map({:yamerl_null, :yamerl_node_null, _tag, _loc}, _options), do: nil
  defp _to_map({_yamler_element, _yamler_node_element, _tag, _loc, elem}, _options), do: elem

  defp _tuples_to_map([], map, _options), do: map

  defp _tuples_to_map([{key, val} | rest], map, options) do
    agregator_module =
      case Keyword.get(options, :maps_as_keywords) do
        true -> &append_kv/3
        _ -> &Map.put_new/3
      end

    case key do
      {:yamerl_seq, :yamerl_node_seq, _tag, _log, _seq, _n} ->
        _tuples_to_map(
          rest,
          agregator_module.(map, _to_map(key, options), _to_map(val, options)),
          options
        )

      {_yamler_element, _yamler_node_element, _tag, _log, name} ->
        _tuples_to_map(
          rest,
          agregator_module.(map, key_for(name, options), _to_map(val, options)),
          options
        )
    end
  end

  defp key_for(<<?:, name::binary>> = original_name, options) do
    if Keyword.get(options, :atoms) do
      String.to_atom(name)
    else
      original_name
    end
  end

  defp key_for(name, _options), do: name

  defp empty_container(options) do
    case Keyword.get(options, :maps_as_keywords) do
      true -> []
      _ -> %{}
    end
  end

  defp append_kv(list, key, value) do
    [{key, value} | list]
  end
end
