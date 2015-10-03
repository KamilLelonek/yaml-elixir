defmodule YamlElixirTest do
  use ExUnit.Case

  test "should parse blank file" do
    assert_parse_file "blank", %{}
  end

  test "should parse empty file" do
    assert_parse_file "empty", %{}
  end

  test "should parse flat file" do
    assert_parse_file "flat", %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => [], ":f" => ":atom"}
  end

  test "should parse flat file with atoms option" do
    assert_parse_file "flat", %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => [], :f => :atom}, atoms: true
  end

  test "should parse nested file" do
    assert_parse_file "nested", %{
      "dev"  => %{"foo" => "bar"},
      "prod" => %{"foo" => "foo"},
      "test" => %{"foo" => "baz"}
    }
  end

  test "should parse file with multiple documents" do
    assert_parse_multi_file "multi", [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ]
  end

  test "should parse file with multiple empty documents" do
    assert_parse_multi_file "multi_empty", [%{}, %{}, %{}]
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

  test "should parse string with multiple documents" do
    yaml = """
    ---

    a: a
    b: 1
    c: true
    d: ~
    e: []

    ---

    z: z
    x: 1
    y: true
    w: ~
    v: []
    """
    assert_parse_multi_string yaml,  [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ]
  end

  defp test_data(file_name) do
    File.cwd! |> Path.join("test/fixtures/#{file_name}.yml")
  end

  defp assert_parse_multi_file(file_name, result, options \\ []) do
    path = test_data(file_name)
    assert YamlElixir.read_all_from_file(path, options) == result
  end

  defp assert_parse_file(file_name, result, options \\ []) do
    path = test_data(file_name)
    assert YamlElixir.read_from_file(path, options) == result
  end

  defp assert_parse_multi_string(string, result, options \\ []) do
    assert YamlElixir.read_all_from_string(string, options) == result
  end

  defp assert_parse_string(string, result, options \\ []) do
    assert YamlElixir.read_from_string(string, options) == result
  end
end
