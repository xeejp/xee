defmodule Xee.ThemeServerTest do
  use ExUnit.Case
  alias Xee.ThemeServer, as: ThemeServer

  setup do
    ThemeServer.start_link()
    on_exit fn ->
      case Process.whereis(ThemeServer) do
        pid when is_pid(pid) -> Process.exit(pid, :kill)
        _ -> nil
      end
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
end
