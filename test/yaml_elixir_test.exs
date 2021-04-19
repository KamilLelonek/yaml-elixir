defmodule YamlElixirTest do
  use ExUnit.Case

  test "should parse blank file" do
    assert_parse_file("blank", %{})
  end

  test "should parse empty file" do
    assert_parse_file("empty", %{})
  end

  test "should parse flat file" do
    assert_parse_file("flat", %{
      "a" => "a",
      "b" => 1,
      "c" => true,
      "d" => nil,
      "e" => [],
      ":f" => ":atom",
      "g" => 88.0
    })
  end

  test "should parse flat file with atoms option" do
    assert_parse_file(
      "flat",
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => [], :f => :atom, "g" => 88.0},
      atoms: true
    )
  end

  test "should parse nested file" do
    assert_parse_file("nested", %{
      "dev" => %{"foo" => "bar"},
      "prod" => %{"foo" => "foo"},
      "test" => %{"foo" => "baz"}
    })
  end

  test "should parse file with multiple documents" do
    assert_parse_multi_file("multi", [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ])
  end

  test "should parse file with multiple empty documents" do
    assert_parse_multi_file("multi_empty", [%{}, %{}, %{}])
  end

  test "should parse blank string" do
    assert_parse_string("", %{})
  end

  test "should parse flat string" do
    yaml = """
      a: a
      b: 1
      c: true
      d: ~
      e: nil
      f: 1.2
    """

    assert_parse_string(yaml, %{
      "a" => "a",
      "b" => 1,
      "c" => true,
      "d" => nil,
      "e" => "nil",
      "f" => 1.2
    })
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

    assert_parse_string(yaml, %{
      "prod" => %{"foo" => "foo"},
      "dev" => %{"foo" => "bar"},
      "test" => %{"foo" => "baz"}
    })
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

    assert_parse_multi_string(yaml, [
      %{"a" => "a", "b" => 1, "c" => true, "d" => nil, "e" => []},
      %{"z" => "z", "x" => 1, "y" => true, "w" => nil, "v" => []}
    ])
  end

  test "should parse string with mapping between sequences" do
    yaml = """
    ---
    ?
      - a
      - b
    :
      - 1
      - 2
    ? [c, d]
    : [3, 4]
    ? [e]
    : 5
    """

    assert_parse_string(yaml, %{["a", "b"] => [1, 2], ["c", "d"] => [3, 4], ["e"] => 5})
  end

  test "should parse flat json string" do
    json = """
      {
        "a": "a",
        "b": 1,
        "c": true,
        "d": null,
        "e": "null",
        "f": 1.2
      }
    """

    assert_parse_string(
      json,
      %{
        "a" => "a",
        "b" => 1,
        "c" => true,
        "d" => nil,
        "e" => "null",
        "f" => 1.2
      },
      schema: :json
    )
  end

  test "should parse nested json string" do
    json = """
      {
        "object": {
          "string": "value",
          "null": null,
          "number": 1
        },
        "array": [1, 2, null, "4"]
      }
    """

    assert_parse_string(
      json,
      %{
        "object" => %{
          "string" => "value",
          "null" => nil,
          "number" => 1
        },
        "array" => [1, 2, nil, "4"]
      },
      schema: :json
    )
  end

  test "sigil should parse string document" do
    import YamlElixir.Sigil

    yaml = ~y"""
    a: A
    b: 1
    """

    assert %{"a" => "A", "b" => 1} == yaml
  end

  test "sigil with atom keys option" do
    import YamlElixir.Sigil

    yaml = ~y"""
    a: :A
    :b: 1
    """a

    assert %{"a" => :A, b: 1} == yaml
  end

  test "should get error tuple for invalid literal" do
    yaml = "*invalid"

    assert {:error, %YamlElixir.ParsingError{}} = YamlElixir.read_all_from_string(yaml)
    assert {:error, %YamlElixir.ParsingError{}} = YamlElixir.read_from_string(yaml)
  end

  test "exception structs should have line, column, and type values" do
    {:error, error} = YamlElixir.read_all_from_string("*invalid")

    assert %YamlElixir.ParsingError{
             line: 1,
             column: 1,
             type: :no_matching_anchor
           } = error
  end

  test "bang function should raise exception for invalid literal" do
    yaml = "*invalid"

    assert_raise YamlElixir.ParsingError,
                 ~s/No anchor corresponds to alias "invalid" (line: 1, column: 1)/,
                 fn ->
                   YamlElixir.read_all_from_string!(yaml)
                 end
  end

  test "should get error tuple for invalid file" do
    path = test_data("invalid")

    assert {:error, %YamlElixir.ParsingError{}} = YamlElixir.read_all_from_file(path)
    assert {:error, %YamlElixir.ParsingError{}} = YamlElixir.read_from_file(path)
  end

  test "bang function should raise exception for invalid file" do
    path = test_data("invalid")

    assert_raise YamlElixir.ParsingError, "malformed yaml", fn ->
      YamlElixir.read_all_from_file!(path)
    end
  end

  test "should get file error tuple for non-existent file" do
    path = test_data("not_found")
    assert {:error, %YamlElixir.FileNotFoundError{}} = YamlElixir.read_all_from_file(path)
    assert {:error, %YamlElixir.FileNotFoundError{}} = YamlElixir.read_from_file(path)
  end

  test "bang function should raise exception for non-existent file" do
    path = test_data("not_found")

    assert_raise YamlElixir.FileNotFoundError, ~r/Failed to open file/, fn ->
      YamlElixir.read_all_from_file!(path)
    end
  end

  test "should receive keyword list when used `maps_as_keywords` option" do
    assert_parse_file(
      "nested",
      [{"test", [{"foo", "baz"}]}, {"dev", [{"foo", "bar"}]}, {"prod", [{"foo", "foo"}]}],
      maps_as_keywords: true
    )
  end

  test "should receive keyword list of keyword lists when used `maps_as_keywords` option and parsing nested map" do
    assert_parse_file(
      "nested_map",
      [{"prod", [{"test", [{"foo", "baz"}]}, {"dev", [{"foo", "bar"}]}, {"foo", "foo"}]}],
      maps_as_keywords: true
    )
  end

  test "should receive maps as keyword lists when map is tagged in the file" do
    assert_parse_file(
      "keyword_list",
      %{
        "prod" => %{
          "foo" => [{"bar", "foo"}, {"foo", "bar"}],
          "bar" => %{"foo" => "bar", "bar" => "foo"}
        }
      },
      node_mods: [YamlElixir.Node.KeywordList]
    )
  end

  test "should receive a single map entry with a keyword list as its value" do
    assert_parse_file(
      "single_value_keyword_list",
      %{"prod" => [{"bar", "foo"}, {"foo", "bar"}]},
      node_mods: [YamlElixir.Node.KeywordList]
    )
  end

  test "should merge keys for a file using anchors when asked to" do
    assert_parse_file(
      "simple_anchors",
      %{"foo" => %{"bar" => "baz"}, "merged_foo" => %{"bar" => "baz"}},
      merge_anchors: true
    )
  end

  test "should merge output for a string using anchors when asked to merge anchors" do
    yaml = """
    a: &a
      b: 42
    c:
     <<: *a
     d: 43
    """

    assert_parse_string(
      yaml,
      %{"a" => %{"b" => 42}, "c" => %{"b" => 42, "d" => 43}},
      merge_anchors: true
    )

    yaml = """
    a: &a
      b: 42
    c:
      <<: *a
      d: 43
      b: 41
    """

    assert_parse_string(
      yaml,
      %{"a" => %{"b" => 42}, "c" => %{"b" => 41, "d" => 43}},
      merge_anchors: true
    )
  end

  defp test_data(file_name), do: Path.join(File.cwd!(), "test/fixtures/#{file_name}.yml")

  defp assert_parse_multi_file(file_name, result, options \\ []) do
    path = test_data(file_name)

    assert YamlElixir.read_all_from_file!(path, options) == result
  end

  defp assert_parse_file(file_name, result, options \\ []) do
    path = test_data(file_name)

    assert YamlElixir.read_from_file!(path, options) == result
  end

  defp assert_parse_multi_string(string, result, options \\ []) do
    assert YamlElixir.read_all_from_string!(string, options) == result
  end

  defp assert_parse_string(string, result, options \\ []) do
    assert YamlElixir.read_from_string!(string, options) == result
  end
end
