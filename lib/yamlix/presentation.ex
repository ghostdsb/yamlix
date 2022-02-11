defmodule Presentation do
  alias RepresentationGraph.Node
  @special_chars ~w(: { } [ ] , & * # ? | - < > = ! % @ \\)

  def present(tree, wrap \\ true) do
    if wrap,
      do: "--- " <> produce(tree) <> "...\n",
      else: produce(tree)
  end

  defp produce(%Node{value: list} = node) when is_list(list),
    do: block_sequence(%Node{node | value: list}, 0)

  defp produce(%Node{value: map} = node) when is_map(map),
    do: block_mapping(%Node{node | value: map}, 0)

  defp produce(node),
    do: literal(node, 0) <> "\n"

  defp block_sequence(%Node{value: list, literal_content: false}, n) do
    List.foldl(list, "\n", fn val, acc ->
      acc <> indent(n) <> "- " <> sequence_element(val, n + 1)
    end)
  end

  defp block_sequence(%Node{value: list}, n) do
    List.foldl(list, "\n", fn val, acc ->
      acc <> indent(n) <> sequence_element(val, n + 1)
    end)
  end

  defp sequence_element(%Node{value: list} = node, n) when is_list(list),
    do: block_sequence(node, n)

  defp sequence_element(%Node{value: map}, n) when is_map(map) do
    case Map.keys(map) do
      [] ->
        "{}\n"

      [key | keys] ->
        mapping_pair(map, key, n) <>
          (keys
           |> List.foldl("", fn key, acc ->
             acc <> indent(n) <> mapping_pair(map, key, n)
           end))
    end
  end

  defp sequence_element(node, _n), do: literal(node, 0) <> "\n"

  defp block_mapping(%Node{value: map}, n) do
    map
    |> Map.keys()
    |> List.foldl("\n", fn key, acc ->
      acc <> indent(n) <> mapping_pair(map, key, n)
    end)
  end

  defp mapping_pair(map, %Node{literal_content: literal_content} = key, n) do
    separator =
      if literal_content,
        do: ": |",
        else: ":"

    literal(key, 0) <>
      separator <> mapping_value(Map.get(map, key), n)
  end

  defp mapping_value(%Node{value: list} = node, n) when is_list(list),
    do: block_sequence(%Node{node | value: list}, n)

  defp mapping_value(%Node{value: map} = node, n) when is_map(map),
    do: block_mapping(%Node{node | value: map}, n + 1)

  defp mapping_value(node, _n),
    do: " " <> literal(node, 0) <> "\n"

  defp literal(%Node{value: val, tag: t, literal_content: literal_content}, n),
    do: indent(n) <> tag_and_space(t) <> escape(Kernel.to_string(val), literal_content)

  defp tag_and_space(t) do
    case t do
      "" -> ""
      tag -> tag <> " "
    end
  end

  @spec indent(non_neg_integer) :: String.t()
  defp indent(0), do: ""

  defp indent(level), do: String.duplicate(" ", level * 2)

  defp escape(string, false) do
    if String.contains?(string, @special_chars),
      do: "\"#{string}\"",
      else: string
  end

  defp escape(string, _), do: string
end
