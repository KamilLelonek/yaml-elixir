defmodule YamlElixir do
  alias YamlElixir.Mapper

  @yamerl_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  def read_all_from_file!(path, options \\ []) do
    path
    |> :yamerl_constr.file(@yamerl_options)
    |> Mapper.process(options)
  end

  def read_from_file!(path, options \\ []) do
    path
    |> :yamerl_constr.file(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end

  def read_all_from_string!(string, options \\ []) do
    string
    |> :yamerl_constr.string(@yamerl_options)
    |> Mapper.process(options)
  end

  def read_from_string!(string, options \\ []) do
    string
    |> :yamerl_constr.string(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end
end
