defmodule Xee.ThemeServerTest do
  use ExUnit.Case
  alias Xee.ThemeServer, as: ThemeServer

  setup do
    on_exit fn ->
      Agent.stop(ThemeServer)
      ThemeServer.start_link()
    end
    :ok
  end

  test "register and get" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert :A == ThemeServer.get(:a)
    assert :B == ThemeServer.get(:b)
    assert :C == ThemeServer.get(:c)
  end

  test "register and get_all" do
    assert :ok == ThemeServer.register(:a, :A)
    assert :ok == ThemeServer.register(:b, :B)
    assert :ok == ThemeServer.register(:c, :C)
    assert %{a: :A, b: :B, c: :C} == ThemeServer.get_all()
  end

  test "load experiments" do
    ThemeServer.load("test/assets/example_experiments.exs")
    themes = ThemeServer.get_all()
    themes |> Map.to_list() |> Enum.map(fn {key, value} ->
      case value.name do
        "example1" ->
          %Xee.Theme{
            name: "example1",
            experiment: %Xee.Experiment{
              theme_id: id, module: Example1,
              host: "// example1 host.js\n",
              participant: "// example1 participant.js\n"
            }
          } = value
          assert id == key
        "example2" ->
          %Xee.Theme{
            name: "example2",
            experiment: %Xee.Experiment{
              theme_id: id, module: Example2,
              host: "// example2 host.js\n",
              participant: "// example2 participant.js\n"}
          } = value
          assert id == key
      end
    end)
  end
end
