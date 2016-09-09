defmodule Xee.TokenGenerator do
  @doc """
  Generate 'Universally Unique Identifier' with version 4.
  """

  def generate() do
    {unique, ""} = UUID.uuid4(:hex) |> Integer.parse(16)
    shorten_hex(unique + 1)
  end

  def shorten_hex(hex) do
    characters = Enum.to_list(?0..?9) ++ Enum.to_list(?a..?z)
    to_string shorten(hex, List.to_tuple(characters))
  end

  def shorten(0, _), do: []

  def shorten(x, characters) do
    size = tuple_size(characters)
    [elem(characters, rem(x, size)) | shorten(div(x, size), characters)]
  end
end
