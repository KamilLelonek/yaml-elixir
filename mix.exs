defmodule YamlElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app:             :yaml_elixir,
      version:         "1.2.0",
      elixir:          "~> 1.0",
      build_embedded:  Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description:     description,
      package:         package,
      deps:            deps
    ]
  end

  def application do
    [
      mod:          { YamlElixir, [] },
      applications: apps
    ]
  end

  defp apps do
    [
      :yamerl
    ]
  end

  defp deps do
    [
      { :yamerl, github: "yakaz/yamerl" }
    ]
  end

  defp description do
    """
    Yaml parser for Elixir based on native Erlang implementation.
    """
  end

  defp package do
    [
      files:       ["lib", "config", "mix.exs", "README.md"],
      maintainers: ["Kamil Lelonek"],
      licenses:    ["MIT"],
      links:       %{ "GitHub" => "https://github.com/KamilLelonek/yaml-elixir" }
    ]
  end
end
