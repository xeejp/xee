defmodule XeeWeb.ExperimentServerTest do
  use ExUnit.Case, async: false
  use XeeWeb.ExperimentTestHelper
  alias Xee.ExperimentServer

  setup do
    ExperimentServer.remove_all
    :ok
  end

  test "create, get and get_info" do
    assert :ok == ExperimentServer.create(:a, test_experiment, :A) |> elem(0)
    assert :ok == ExperimentServer.create(:b, test_experiment, :B) |> elem(0)
    assert :ok == ExperimentServer.create(:c, test_experiment, :C) |> elem(0)
    a = ExperimentServer.get(:a)
    b = ExperimentServer.get(:b)
    c = ExperimentServer.get(:c)
    assert is_pid(a)
    assert is_pid(b)
    assert is_pid(c)
    assert Process.alive?(a)
    assert Process.alive?(b)
    assert Process.alive?(c)
    assert :A == ExperimentServer.get_info(:a)
    assert :B == ExperimentServer.get_info(:b)
    assert :C == ExperimentServer.get_info(:c)
  end

  test "get_all" do
    ExperimentServer.create(:a, test_experiment, :A)
    ExperimentServer.create(:b, test_experiment, :B)
    ExperimentServer.create(:c, test_experiment, :C)
    %{a: {a, :A}, b: {b, :B}, c: {c, :C}} = ExperimentServer.get_all()
    assert is_pid(a)
    assert is_pid(b)
    assert is_pid(c)
    assert Process.alive?(a)
    assert Process.alive?(b)
    assert Process.alive?(c)
  end

  test "has?" do
    refute ExperimentServer.has?(:a)
    ExperimentServer.create(:a, test_experiment, :A)
    assert ExperimentServer.has?(:a)
    refute ExperimentServer.has?(:b)
    ExperimentServer.create(:b, test_experiment, :B)
    assert ExperimentServer.has?(:b)
  end

  test "remove" do
    ExperimentServer.create(:a, test_experiment, :A)
    ExperimentServer.create(:b, test_experiment, :B)
    assert ExperimentServer.has?(:a)
    assert :ok == ExperimentServer.remove(:a)
    refute ExperimentServer.has?(:a)
    assert ExperimentServer.has?(:b)
    assert :ok == ExperimentServer.remove(:b)
    refute ExperimentServer.has?(:b)
  end
end
