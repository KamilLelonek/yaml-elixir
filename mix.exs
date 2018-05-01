defmodule YamlElixir.Mixfile do
  use Mix.Project

  def project do
    [
      app: :yaml_elixir,
      version: "2.0.2",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp deps do
    [
      {:yamerl, "~> 0.7"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp description do
    """
    Yaml parser for Elixir based on native Erlang implementation.
    """
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md"],
      maintainers: ["Kamil Lelonek"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/KamilLelonek/yaml-elixir"}
    ]
  end
end
