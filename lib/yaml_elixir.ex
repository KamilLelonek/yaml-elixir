defmodule YamlElixir do
  def start(_type, _args) do
    Supervisor.start_link(children, options)
  end

  defp children, do: []
  defp options,  do: [strategy: :one_for_one, name: Figaro.Supervisor]

  def read_all_from_file(path) do
    path
      |> :yamerl_constr.file(detailed_constr: true)
      |> YamlElixir.Mapper.process
  end

  def read_from_file(path) do
    path
      |> :yamerl_constr.file(detailed_constr: true)
      |> List.last
      |> YamlElixir.Mapper.process
  end

  def read_all_from_string(string) do
    string
      |> :yamerl_constr.string(detailed_constr: true)
      |> YamlElixir.Mapper.process
  end

  def read_from_string(string) do
    string
    |> :yamerl_constr.string(detailed_constr: true)
    |> List.last
    |> YamlElixir.Mapper.process
  end
end
