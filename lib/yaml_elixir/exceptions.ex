defmodule YamlElixir.FileNotFoundError do
  defexception message: "file error"
end

defmodule YamlElixir.ParsingError do
  defexception message: "parsing error"
end
