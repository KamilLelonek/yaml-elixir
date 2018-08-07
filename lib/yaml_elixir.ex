defmodule YamlElixir do
  alias YamlElixir.Mapper

  @yamerl_options [
    detailed_constr: true,
    str_node_as_binary: true
  ]

  def read_all_from_file!(path, options \\ []),
    do: prepare_and_read(:file, path, options)

  def read_all_from_file(path, options \\ []) do
    {:ok, read_all_from_file!(path, options)}
  catch
    :throw, {:yamerl_exception, list} ->
      {:error, format_error(list)}
  end

  def read_from_file!(path, options \\ []),
    do: prepare_and_read(:file, path, Keyword.put(options, :one_result, true))

  def read_from_file(path, options \\ []) do
    {:ok, read_from_file!(path, options)}
  catch
    :throw, {:yamerl_exception, list} ->
      {:error, format_error(list)}
  end

  def read_all_from_string!(string, options \\ []),
    do: prepare_and_read(:string, string, options)

  def read_all_from_string(string, options \\ []) do
    {:ok, read_all_from_string!(string, options)}
  catch
    :throw, {:yamerl_exception, list} ->
      {:error, format_error(list)}
  end

  def read_from_string!(string, options \\ []),
    do: prepare_and_read(:string, string, Keyword.put(options, :one_result, true))

  def read_from_string(string, options \\ []) do
    {:ok, read_from_string!(string, options)}
  catch
    :throw, {:yamerl_exception, list} ->
      {:error, format_error(list)}
  end

  defp prepare_and_read(type, source, options) do
    ensure_yamerl_started()

    options
    |> merge_options()
    |> read(type, source)
  end

  defp read(options, type, source) do
    type
    |> yamerl_constr(source, options)
    |> extract_data(options)
    |> Mapper.process(options)
  end

  defp merge_options(options),
    do: Keyword.merge(options, @yamerl_options)

  defp yamerl_constr(:file, path, options), do: :yamerl_constr.file(path, options)
  defp yamerl_constr(:string, data, options), do: :yamerl_constr.string(data, options)

  defp extract_data(data, options) do
    options
    |> Keyword.get(:one_result)
    |> maybe_take_last(data)
  end

  defp maybe_take_last(true, data), do: List.last(data)
  defp maybe_take_last(_, data), do: data

  defp ensure_yamerl_started, do: Application.start(:yamerl)

  defp format_error(list, result \\ "")
  defp format_error([], result), do: result
  defp format_error([{_, _, message, line, col, _, _, _} = error|t], result) do
    error |> IO.inspect
    format_error(t, result <> "line: #{line} column: #{col}\r\n#{message}\r\n")
  end
end
