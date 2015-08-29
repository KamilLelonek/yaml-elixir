defmodule YamlElixir.Mapper do

  def process([]), do: [%{}]

  def process(yaml) when is_list(yaml) do
    yaml
      |> Enum.map(&_to_map/1)
      |> Enum.map(&extract_map/1)
  end

  defp extract_map(nil), do: %{}
  defp extract_map(map), do: map

  defp _to_map({:yamerl_doc, document}), do: _to_map(document)

  defp _to_map({ :yamerl_seq, :yamerl_node_seq, _tag, _loc, seq, _n }),
  do:  Enum.map(seq, &_to_map(&1))

  defp _to_map({ :yamerl_map, :yamerl_node_map, _tag, _loc, map_tuples }),
  do:  _tuples_to_map(map_tuples, %{})

  defp _to_map({ :yamerl_str, :yamerl_node_str, _tag, _loc, elem }),
  do:  to_string(elem)

  defp _to_map({ :yamerl_null, :yamerl_node_null, _tag, _loc }),
  do:  nil

  defp _to_map({ _yamler_element, _yamler_node_element, _tag, _loc, elem }),
  do:  elem

  defp _tuples_to_map([], map),
  do:  map

  defp _tuples_to_map([{ key, val } | rest], map) do
    case key do
      { :yamerl_str, :yamerl_node_str, _tag, _log, name } ->
         _tuples_to_map(rest, Dict.put_new(map, to_string(name), _to_map(val)))
    end
  end
end
