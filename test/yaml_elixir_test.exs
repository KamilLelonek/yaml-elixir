defmodule YamlElixirTest do
  use ExUnit.Case

  test "should parse blank file" do
    assert_parse_file "blank", %{}
  end

  test "should parse empty file" do
    assert_parse_file "empty", %{}
  end

  test "should parse flat file" do
    assert_parse_file "flat", %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []}
  end

  test "should parse nested file" do
    assert_parse_file "nested", %{
      "dev"  => %{"foo" => "bar"},
      "prod" => %{"foo" => "foo"},
      "test" => %{"foo" => "baz"}
    }
  end

  test "should parse blank string" do
    assert_parse_string "", %{}
  end

  test "should parse flat string" do
    yaml = """
      a: a
      b: 1
      c: true
      d: ~
      e: nil
    """
    assert_parse_string yaml, %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => "nil"}
  end

  test "should parse nested string" do
    yaml = """
      prod:
        foo: foo
      dev:
        foo: bar
      test:
        foo: baz
    """
    assert_parse_string yaml, %{
      "prod" => %{"foo" => "foo"},
      "dev"  => %{"foo" => "bar"},
      "test" => %{"foo" => "baz"}
    }
  end

  defp assert_parse_file(file_name, result) do
    path = File.cwd! |> Path.join("test/fixtures/#{file_name}.yml")
    assert YamlElixir.read_from_file(path) == result
  end

  defp assert_parse_string(string, result) do
    assert YamlElixir.read_from_string(string) == result
  end
end
