defmodule Gradient.ElixirExpr do
  @moduledoc """
  Module formats the Erlang abstract expressions to the Elixir code.

  FIXME
  - nil ([]) line is not specified by AstSpecifier

  TODO Elixir
  - structs

  TODO Erlang
  - bitstring comprehension
  - bitstring constructor
  - case expression
  - fun expression clauses
  - if expression
  - list comprehension
  - receive expression
  - try expression
  - record / don't use by Elixir, probably can be skipped

  """

  @spec pretty_print_body([:erl_parse.abstract_expr()]) :: [String.t()]
  def pretty_print_body(exprs) do
    Enum.map(exprs, &pretty_print/1)
  end

  @spec pretty_print(:erl_parse.abstract_expr()) :: String.t()
  def pretty_print({:atom, _, l}) do
    ":" <> Atom.to_string(l)
  end

  def pretty_print({:char, _, l}) do
    "?" <> List.to_string([l])
  end

  def pretty_print({:float, _, l}) do
    Float.to_string(l)
  end

  def pretty_print({:integer, _, l}) do
    Integer.to_string(l)
  end

  def pretty_print({:string, _, charlist}) do
    List.to_string(charlist)
  end

  def pretty_print({:remote, _, module, fun}) do
    module = pretty_print(module)
    fun = pretty_print(fun)
    module <> "." <> fun
  end

  def pretty_print({:block, _, body}) do
    # TODO maybe add indent?
    body
    |> pretty_print_body()
    |> Enum.join("\n")
  end

  def pretty_print({:catch, _, expr}) do
    pretty_print(expr)
  end

  def pretty_print({:cons, _, [h_expr, t_expr]}) do
    "[#{pretty_print(h_expr)} | #{pretty_print(t_expr)}]"
  end

  def pretty_print({:fun, _, {:function, name, arity}}) do
    name = pretty_print(name)
    arity = pretty_print(arity)
    "&#{name}/#{arity}"
  end

  def pretty_print({:fun, _, {:function, module, name, arity}}) do
    module = pretty_print(module)
    name = pretty_print(name)
    arity = pretty_print(arity)
    "#{module}.&#{name}/#{arity}"
  end

  def pretty_print({:call, _, name, args}) do
    args =
      Enum.map(args, &pretty_print/1)
      |> Enum.join(" ,")

    name = pretty_print(name)
    name <> "(" <> args <> ")"
  end

  def pretty_print({:map, _, pairs}) do
    pairs = Enum.map(pairs, &format_map_element/1) |> Enum.join(", ")
    "%{" <> pairs <> "}"
  end

  def pretty_print({:map, _, map, pairs}) do
    pairs = Enum.map(pairs, &format_map_element/1) |> Enum.join(", ")
    map = pretty_print(map)
    "%{" <> map <> " | " <> pairs <> "}"
  end

  def pretty_print({:match, _, var, expr}) do
    pretty_print(var) <> " = " <> pretty_print(expr)
  end

  def pretty_print({nil, _}) do
    "[]"
  end

  def pretty_print({:op, _, op, type}) do
    Atom.to_string(op) <> " " <> pretty_print(type)
  end

  def pretty_print({:op, _, op, left_type, right_type}) do
    operator = " " <> Atom.to_string(op) <> " "
    pretty_print(left_type) <> operator <> pretty_print(right_type)
  end

  def pretty_print({:type, _, :tuple, elements}) do
    elements_str = Enum.map(elements, &pretty_print(&1)) |> Enum.join(", ")
    "{" <> elements_str <> "}"
  end

  def pretty_print({:var, _, t}) do
    Atom.to_string(t)
  end

  def pretty_print(expr) do
    :erl_pp.expr(expr)
    |> :erlang.iolist_to_binary()
  end

  # Private

  @spec format_map_element(tuple()) :: String.t()
  def format_map_element({field, _, key, value})
      when field in [:map_field_assoc, :map_field_exact] do
    key = pretty_print(key)
    value = pretty_print(value)
    key <> " => " <> value
  end
end
