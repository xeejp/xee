defmodule Xee.Theme do
  defstruct experiment: nil, id: "", name: "", playnum: 0, lastupdate: 0, producer: "", contact: "", manual: "", granted: nil

  def granted?(%Xee.Theme{granted: %MapSet{} = mapset}, id) do
    MapSet.member?(mapset, id)
  end
  def granted?(_, _), do: true
  def granted?(%Xee.Theme{granted: %MapSet{} = mapset}) do
    MapSet.size(mapset) == 0
  end
  def granted?(_), do: true
end
