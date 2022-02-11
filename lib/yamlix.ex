defmodule Yamlix do
  alias RepresentationGraph, as: R
  alias Serialize, as: S
  alias Presentation, as: P

  @doc """
  Converts term to yaml format.
  This function is useful for sending boolean values to the server.
  ## Examples
      # Assuming form contains a User schema
      checkbox(form, :famous)
      dump(term, wrap: false, multiline_fields: ["examples"])
      #=> "\nexamples: |\n- some string\nregex: | text\n"
  ## Options
    * `:wrap` - boolean(), wrap the enitre term to yaml document notation.
      Defaults to "true"
    * `:multiline_fields` - list, take fields which should be parsed as Literal Scalar.
      They are multiline and witout escape characters
      [Read more about `Literal Scalar`](https://yaml.org/spec/1.2-old/spec.html#id2795688)
      Defaults to []
    * `:literal` - boolean(), nake an entire term to be parsed as Literal Scalar
      Usefull for lists.
      Defaults to "false"
  """
  @spec dump(any, Keyword.t()) :: String.t()
  def dump(scalar, params \\ []) do
    wrap = Keyword.get(params, :wrap, true)
    multiline_fields = Keyword.get(params, :multiline_fields, [])
    literal = Keyword.get(params, :literal, false)

    scalar
    |> R.represent(multiline_fields, literal)
    |> S.serialize()
    |> P.present(wrap)
  end
end
