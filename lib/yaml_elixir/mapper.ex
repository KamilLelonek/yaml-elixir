defmodule YamlElixir.Mapper do
  def process(nil, options), do: ensure_map(nil, options)
  def process(yaml, options) when is_list(yaml), do: Enum.map(yaml, &process(&1, options))

  def process(yaml, options) do
    yaml
    |> _to_map(options)
    |> ensure_map(options)
  end

  defp _to_map({:yamerl_doc, document}, options), do: _to_map(document, options)

  defp _to_map({:yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n}, options),
    do: Enum.map(seq, &_to_map(&1, options))

  defp _to_map({:yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples}, options),
    do: _tuples_to_map(map_tuples, options)

  defp _to_map({:yaml_elixir_keyword_list, _module, _tag, _loc, tuples}, options) do
    _tuples_to_map(tuples, options, [])
  end

  defp _to_map({:yamerl_str, :yamerl_node_str, _tag, _loc, element}, _options),
    do: element

  defp _to_map({:yamerl_null, :yamerl_node_null, _tag, _loc}, _options), do: nil
  defp _to_map({:yamerl_null, :yamerl_node_null_json, _tag, _loc}, _options), do: nil
  defp _to_map({_yamler_element, _yamler_node_element, _tag, _loc, elem}, _options), do: elem

  defp _tuples_to_map(map_tuples, options),
    do: _tuples_to_map(map_tuples, options, empty_container(options))

  defp _tuples_to_map(items, options, container) when container == [] or container == %{} do
    items
    |> aggregate_map_items(container, options)
    |> reverse_map()
    |> adjust_empty_map(options)
  end

  defp get_map_tuples({:yamerl_map, :yamerl_node_map, _tag, _loc, tuples}), do: tuples
  defp get_map_tuples({:yaml_elixir_keyword_list, _module, _tag, _loc, tuples}), do: tuples
  defp get_map_tuples(_), do: nil

  defp aggregate_map_items(items, container, options) do
    Enum.reduce(items, container, fn {key, val}, container ->
      key = _to_map(key, options)
      merge? = key == "<<" and Keyword.get(options, :merge_anchors) == true

      if items = merge? and get_map_tuples(val) do
        aggregate_map_items(items, container, options)
      else
        key = key_for(key, options)
        val = val |> _to_map(options) |> maybe_atom(options)

        case container do
          _ when is_list(container) -> [{key, val} | container]
          _ when is_map(container) -> Map.put(container, key, val)
        end
      end
    end)
  end

  defp reverse_map(object) when is_list(object), do: Enum.reverse(object)
  defp reverse_map(map) when is_map(map), do: map

  defp key_for("<<", _options), do: "<<#{System.unique_integer([:positive, :monotonic])}"

  defp key_for(name, options), do: maybe_atom(name, options)

  defp maybe_atom(":" <> name = original_name, options) do
    case Keyword.get(options, :atoms) do
      true -> String.to_atom(name)
      _ -> original_name
    end
  end

  defp maybe_atom(name, _options), do: name

  defp empty_container(options) do
    case Keyword.get(options, :maps_as_keywords) do
      true -> []
      _ -> %{}
    end
  end

  defp ensure_map(nil, options), do: adjust_empty_map(empty_container(options), options)
  defp ensure_map(result, options), do: adjust_empty_map(result, options)

  defp adjust_empty_map([], options), do: Keyword.get(options, :empty_keyword_list, [])
  defp adjust_empty_map(map, _options), do: map
end
