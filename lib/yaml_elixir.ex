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

  def read_all_from_file(path, options \\ []) do
    result = read_all_from_file!(path, options)
    {:ok, result}
  rescue
    _ -> error("malformed yaml")
  end

  def read_from_file!(path, options \\ []) do
    path
    |> :yamerl_constr.file(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end

  def read_from_file(path, options \\ []) do
    result = read_from_file!(path, options)
    {:ok, result}
  rescue
    _ -> error("malformed yaml")
  end

  def read_all_from_string!(string, options \\ []) do
    string
    |> :yamerl_constr.string(@yamerl_options)
    |> Mapper.process(options)
  end

  def read_all_from_string(string, options \\ []) do
    result = read_all_from_string!(string, options)
    {:ok, result}
  rescue
    _ -> error("malformed yaml")
  end

  def read_from_string!(string, options \\ []) do
    string
    |> :yamerl_constr.string(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end

  def read_from_string(string, options \\ []) do
    result = read_from_string!(string, options)
    {:ok, result}
  rescue
    _ -> error("malformed yaml")
  end

  defp error(message) do
    yamerl_started =
      Application.started_applications()
      |> Enum.any?(fn {app, _, _} ->
        app == :yamerl
      end)

    if yamerl_started do
      {:error, message}
    else
      {:error, "yamerl is not running; start it with Application.ensure_started(:yamerl)"}
    end
  end
end
