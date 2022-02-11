defmodule Serialize do
  alias RepresentationGraph.Node

  def serialize(graph),
    do: generate_anchors(graph)

  def generate_anchors(tree) do
    {new_tree, _} = do_generate_anchors(tree, 1)
    new_tree
  end

  defp do_generate_anchors(%Node{value: list, anchor: ""} = node, count) when is_list(list) do
    {new_list, new_count} =
      Enum.reduce(list, {[], count}, fn elem, {new_list, count} ->
        {new_elem, count} = do_generate_anchors(elem, count)
        {[new_elem | new_list], count}
      end)

    {%Node{node | value: Enum.reverse(new_list), anchor: new_count}, new_count + 1}
  end

  defp do_generate_anchors(%Node{value: map, anchor: ""} = node, count) when is_map(map) do
    {new_map, new_count} =
      List.foldl(Map.keys(map), {Map.new(), count}, fn key, {new_map, count} ->
        {key_node, count} = do_generate_anchors(key, count)
        {value_node, count} = do_generate_anchors(Map.get(map, key), count)
        {Map.put_new(new_map, key_node, value_node), count}
      end)

    {%Node{node | value: new_map, anchor: new_count}, new_count + 1}
  end

  defp do_generate_anchors(node, count),
    do: {%Node{node | anchor: count}, count + 1}
end
