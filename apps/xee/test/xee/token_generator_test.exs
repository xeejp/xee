defmodule TokenGeneratorTest do
  use ExUnit.Case, async: true
  test "generate" do
    assert String.length(Xee.TokenGenerator.generate) >= 1
    assert Xee.TokenGenerator.generate != Xee.TokenGenerator.generate
  end
end
