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
    {:yaml_elixir, "~> x.x.x"}, # where "x.x.x" equals version in mix.exs
  ]
end
```

**ALWAYS MAKE SURE YOU USE THE LATEST VERSION FROM [`mix.ex`](https://github.com/KamilLelonek/yaml-elixir/blob/master/mix.exs#L7)**

You should also update your applications list to include `Yaml Elixir`:

```elixir
def application do
  [
     applications: [
       # ...
       :yaml_elixir,
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

### Support for atoms

By default, all map keys are processed as strings, as are all bareword or quoted
values. If you would prefer to autodetect keys and values that begin with `:` as
atoms, this can be accomplished by passing `atoms: true` as an option to any of
the `read_*` functions.

```elixir
iex(1)>     yaml = """
...(1)>       a: a
...(1)>       b: 1
...(1)>       c: true
...(1)>       d: ~
...(1)>       e: nil,
...(1)>       :f: :atom
...(1)>     """
"  a: a\n  b: 1\n  c: true\n  d: ~\n  e: nil\n"
iex(2)> YamlElixir.read_from_string yaml, atoms: true
%{:f => :atom, "a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => "nil"}
```

Atoms are not garbage collected by BEAM, so be careful with this option, and
don't use it with user-supplied input. One other caveat: if you enable
autodetection of atoms, any string values entered (e.g.,
`":not_really_an_atom"`) will be converted to atoms, as well. If you only need
to support a few atom values, you _might_ be better off enabling yamerl's
custom tag for atoms:

```elixir
:yamerl_app.set_param(:node_mods, [:yamerl_node_erlang_atom])
```

and then using the somewhat inconvenient syntax for it:

```yaml
atom_key: !<tag:yamerl,2012:atom> atom_value
```

### Elixir Sigil

The `YamlElixir.Sigil` module provides the `~y` sigil that
can be useful for example for keeping short configurations
or other inlined yaml.

```elixir
import YamlElixir.Sigil

@config ~y"""
debug: false
port:  9200
files:
  - some/file.csv
  - another/file.csv
"""
```

Use the `a` sigil modifier to turn on atom values from yaml:

```
~y":answer: yes"a
```

You can find more examples in [`test` directory](https://github.com/KamilLelonek/yaml-elixir/blob/master/test/yaml_elixir_test.exs).

## Mix tasks

Sometimes, you may want to use `yaml_elixir` in your `mix` tasks. To do that, you must ensure that the application has started.

    Application.ensure_all_started(:yaml_elixir)

After that, you will be able to use `yaml-elixir` in your `mix` tasks.

> Credits to [bobbypriambodo](https://github.com/bobbypriambodo).

## Contribution

In case of any problems or suggestions do not hesitate and create a pull request.
