defmodule YamlElixir do
  alias YamlElixir.Mapper

  @yamerl_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  def read_all_from_file!(path, options \\ []) do
    ensure_yamerl_started()

    path
    |> :yamerl_constr.file(@yamerl_options)
    |> Mapper.process(options)
  end

  def read_all_from_file(path, options \\ []) do
    {:ok, read_all_from_file!(path, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_from_file!(path, options \\ []) do
    ensure_yamerl_started()

    path
    |> :yamerl_constr.file(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end

  def read_from_file(path, options \\ []) do
    {:ok, read_from_file!(path, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_all_from_string!(string, options \\ []) do
    ensure_yamerl_started()

    string
    |> :yamerl_constr.string(@yamerl_options)
    |> Mapper.process(options)
  end

  def read_all_from_string(string, options \\ []) do
    {:ok, read_all_from_string!(string, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  def read_from_string!(string, options \\ []) do
    ensure_yamerl_started()

    string
    |> :yamerl_constr.string(@yamerl_options)
    |> List.last()
    |> Mapper.process(options)
  end

  def read_from_string(string, options \\ []) do
    {:ok, read_from_string!(string, options)}
  catch
    _, _ -> {:error, "malformed yaml"}
  end

  defp ensure_yamerl_started, do: Application.start(:yamerl)
end
