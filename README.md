# Yaml for Elixir

[![Build Status](https://travis-ci.org/KamilLelonek/yaml-elixir.svg)](https://travis-ci.org/KamilLelonek/yaml-elixir)

## How does it work?

This is a wrapper for [yamerl](https://github.com/yakaz/yamerl) - a native Erlang `YAML` parser which brings all of the functionalities to Elixir language.

## Installation

Add `Yaml Elixir` as a dependency in your `mix.exs` file.

```elixir
defp deps do
  [
     # ...
    { :yaml_elixir, "~> 0.0.1" }
  ]
end
```

You should also update your applications list to include `Yaml Elixir`:

```elixir
def application do
  [
     applications: [
       # ...
       :yaml_elixir
     ]
  ]
end
```

Once you've done that, run `mix deps.get` in your command line to fetch the dependency.

## Usage

With `Yaml Elixir` you have an access to two methods, one for parsing a string and an another one for parsing a file.

Run `iex -S mix` in your terminal to try how their works.

### Parsing string

```elixir
iex(1)>     yaml = """
...(1)>       a: a
...(1)>       b: 1
...(1)>       c: true
...(1)>       d: ~
...(1)>       e: nil
...(1)>     """
"  a: a\n  b: 1\n  c: true\n  d: ~\n  e: nil\n"
iex(2)> YamlElixir.read_from_string yaml
%{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => "nil"}
```

### Parsing file

```elixir
iex(1)> path = File.cwd! |> Path.join("test/fixtures/flat.yml")
"/Users/squixy/Desktop/yaml-elixir/test/fixtures/flat.yml"
iex(2)> YamlElixir.read_from_file path
%{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []}
```

You can find more examples in [`test` directory](https://github.com/KamilLelonek/yaml-elixir/blob/master/test/yaml_elixir_test.exs).

## Contribution

In case of any problems or suggestions do not hesitate and create a pull request.
