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
    assert ThemeServer.get(:example1) == %Xee.Experiment{
      theme_id: :example1, module: Example1,
      host: "// example1 host.js\n",
      participant: "// example1 participant.js\n"}
    assert ThemeServer.get(:example2) == %Xee.Experiment{
      theme_id: :example2, module: Example2,
      host: "// example2 host.js\n",
      participant: "// example2 participant.js\n"}
  end
end
