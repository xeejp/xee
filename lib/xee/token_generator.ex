defmodule Xee.TokenGenerator do
  @doc """
  Generate 'Universally Unique Identifier' with version 4.
  """
  def generate() do
    UUID.uuid4()
  end
end
