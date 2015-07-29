defmodule YamlElixir do
  def start(_type, _args) do
    Supervisor.start_link(children, options)
  end

  defp children, do: []
  defp options,  do: [strategy: :one_for_one, name: Figaro.Supervisor]

  def read_from_file(path) do
    :yamerl_constr.file(path, detailed_constr: true)
      |> YamlElixir.Mapper.process
  end

  def read_from_string(string) do
    :yamerl_constr.string(string, detailed_constr: true)
      |> YamlElixir.Mapper.process
  end
end
