defmodule YamlElixir.Node.KeywordList do
  require Record
  import YamlElixir.Records, only: :macros

  @tag 'tag:yaml_elixir,2019:keyword_list'

  def tags(), do: [@tag]

  def try_construct_token(constr, node, token) do
    if Record.is_record(:yamerl_collection_start, token)
        and yamerl_collection_start(token, :kind) == :mapping
        and yamerl_tag(yamerl_collection_start(token, :tag), :uri) == @tag do
      construct_token(constr, node, token)
    else
      :unrecognized
    end
  end

  def construct_token(constr, node, yamerl_collection_start() = token) do
    node =
      unfinished_node(
        module: __MODULE__,
        path: {:keyword_list, :undefined},
        pres: :yamerl_constr.get_pres_details(token),
        priv: []
      )

    {:unfinished, node, false};
  end

  def construct_token(_, unfinished_node() = node, yamerl_mapping_key() = _token) do
    node = unfinished_node(node, priv: {'$expecting_key', unfinished_node(node, :priv)})

    {:unfinished, node, false};
  end

  def construct_token(_, unfinished_node() = node, yamerl_mapping_value() = _token) do
    {key, keyword_list} = unfinished_node(node, :priv)
    node = unfinished_node(node, priv: {key, '$expecting_value', keyword_list})

    {:unfinished, node, false};
  end

  def construct_token(constr, unfinished_node() = node, yamerl_collection_end() = _token) do
    if yamerl_constr(constr, :detailed_constr) do
      node =
        yaml_elixir_keyword_list(
          module: __MODULE__,
          tag: @tag,
          pres: unfinished_node(node, :pres),
          pairs: unfinished_node(node, :priv)
        )

      {:finished, node}
    else
      {:finished, unfinished_node(node, :priv)}
    end
  end

  def construct_node(_, unfinished_node() = node, value) do
    node =
      case unfinished_node(node, :path) do
        {:keyword_list, :undefined} ->
          {'$expecting_key', keyword_list} = unfinished_node(node, :priv)

          unfinished_node(node, path: {:keyword_list, value}, priv: {value, keyword_list})

        {:keyword_list, _} ->
          {key, '$expecting_value', keyword_list} = unfinished_node(node, :priv)

          unfinished_node(node, path: {:keyword_list, :undefined}, priv: [{key, value} | keyword_list])
      end

    {:unfinished, node, false}
  end

  def construct_node(_, _, token) do
    error =
      yamerl_parsing_error(
        name: :not_a_mapping,
        token: token,
        text: "Invalid mapping",
        line: elem(unfinished_node(node, :pres), 0),
        column: elem(unfinished_node(node, :pres), 1)
      )

      throw(error)
  end

  def node_pres(node) do
    elem(node, 2)
  end
end
