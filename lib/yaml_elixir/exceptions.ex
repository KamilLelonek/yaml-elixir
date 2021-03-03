defmodule YamlElixir.FileNotFoundError do
  defexception message: "file error"
end

defmodule YamlElixir.ParsingError do
  defexception [:line, :column, :type, message: "parsing error"]

  def from_yamerl({:yamerl_parsing_error, :error, human_readable_error, line, column, error_type, _token_being_parsed, _}) do
    %__MODULE__{
      message: to_string(human_readable_error),
      line: line,
      column: column,
      type: error_type
    }
  end
  def from_yamerl(_) do
    %__MODULE__{
      message: "malformed yaml"
    }
  end
end
