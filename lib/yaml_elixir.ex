defmodule YamlElixir do
  def start(_type, _args),
    do: Supervisor.start_link(children(), options())

  @yamerl_options [
    detailed_constr:    true,
    str_node_as_binary: true,
  ]

  defp children(), do: []
  defp options(),  do: [strategy: :one_for_one, name: YamlElixir.Supervisor]

  def read_all_from_file(path, options \\ []) do
    path
      |> :yamerl_constr.file(@yamerl_options)
      |> YamlElixir.Mapper.process(options)
  end

  def read_from_file(path, options \\ []) do
    path
      |> :yamerl_constr.file(@yamerl_options)
      |> List.last()
      |> YamlElixir.Mapper.process(options)
  end

  def read_all_from_string(string, options \\ []) do
    string
      |> :yamerl_constr.string(@yamerl_options)
      |> YamlElixir.Mapper.process(options)
  end

  def read_from_string(string, options \\ []) do
    string
    |> :yamerl_constr.string(@yamerl_options)
    |> List.last()
    |> YamlElixir.Mapper.process(options)
  end
end
