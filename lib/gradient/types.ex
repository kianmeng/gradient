defmodule Gradient.Types do
  @type token :: tuple()
  @type tokens :: [tuple()]
  @type abstract_type :: :erl_parse.abstract_type()
  @type form ::
          :erl_parse.abstract_clause()
          | :erl_parse.abstract_expr()
          | :erl_parse.abstract_form()
          | :erl_parse.abstract_type()
  @type forms :: [form()]
  @type options :: keyword()
end
