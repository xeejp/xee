defmodule XeeWeb.ThemeTest do
  use ExUnit.Case
  alias Xee.Theme

  test "granted?" do
    id1 = 1
    id2 = 2
    id3 = 3
    id4 = 4
    theme1 = %Theme{}
    theme2 = %Theme{granted: MapSet.new}
    theme3 = %Theme{granted: MapSet.new [id2, id3]}
    assert Theme.granted? theme1, id1
    assert Theme.granted? theme1, id2
    assert Theme.granted? theme1, id3
    assert Theme.granted? theme1, id4
    refute Theme.granted? theme2, id1
    refute Theme.granted? theme2, id2
    refute Theme.granted? theme2, id3
    refute Theme.granted? theme2, id4
    refute Theme.granted? theme3, id1
    assert Theme.granted? theme3, id2
    assert Theme.granted? theme3, id3
    refute Theme.granted? theme3, id4
    assert Theme.granted? theme1
    assert Theme.granted? theme2
    refute Theme.granted? theme3
  end
end
