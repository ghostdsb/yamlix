defmodule RepresentationGraph do
  defmodule Node do
    defstruct value: "", tag: "", anchor: "", literal_content: false

    def new(list, multiline_fields, literal_content) when is_list(list) do
      new_list =
        Enum.map(list, fn val ->
          Node.new(val, multiline_fields, literal_content)
        end)

      %Node{value: new_list, literal_content: literal_content}
    end

    def new(map, multiline_fields, literal_content) when is_map(map) do
      new_map =
        Map.keys(map)
        |> List.foldl(%{}, fn key, acc ->
          new_key = Node.new(key, multiline_fields, literal_content)

          new_value =
            map
            |> Map.get(key)
            |> Node.new(multiline_fields, new_key.literal_content)

          Map.put(acc, new_key, new_value)
        end)

      %Node{value: new_map, tag: "", literal_content: literal_content}
    end

    def new(scalar, _, _) when is_atom(scalar) and not is_boolean(scalar),
      do: %Node{value: scalar, tag: "!<tag:yamerl,2012:atom>"}

    def new(scalar, multiline_fields, literal_content),
      do: %Node{value: scalar, literal_content: literal_content || scalar in multiline_fields}

    def value(%Node{value: v}), do: v
  end

  def represent(scalar, multiline_fields, literal),
    do: Node.new(scalar, multiline_fields, literal)
end
