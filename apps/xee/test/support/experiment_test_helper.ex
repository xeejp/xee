defmodule XeeWeb.ExperimentTestHelper do
  @moduledoc """
  Provides helper functions for testing experiment.

  ## Example
  ```elixir
  defmodule XeeWeb.ExampleTest do
    use ExUnit.Case, async: false # Specify async: false
    use XeeWeb.ExperimentTestHelper # Use this helper

    setup do
      ExperimentServer.start_link() # Start ExperimentServer
      ExperimentServer.create("a", test_experiment) # Create an experiment process
      prepare_servers # Prepare servers before calling join_channel
      host_socket = join_channel("a") # Joining as a host
      participant_socket1 = join_channel("a", "p1") # Joining as a participant named "p1"
      participant_socket2 = join_channel("a", "p2") # Joining as a participant named "p1"
      on_exit fn ->
        ExperimentServer.stop() # Stop ExperimentServer
        stop([host_socket, participant_socket1, participant_socket2]) # Stop all sockets
      end
      :ok
    end

    # Write tests
  end
  ```
  """
  @endpoint XeeWeb.Endpoint

  defmacro __using__(_opts) do
    quote do
      Code.require_file(Path.expand("./../../experiments/test/test.exs", unquote(__DIR__)))
      host = File.read!(Path.expand("./../../experiments/test/host.js", unquote(__DIR__)))
      participant = File.read!(Path.expand("./../../experiments/test/participant.js", unquote(__DIR__)))
      @test_experiment %Xee.Experiment{theme_id: :t1, module: Test, host: host, participant: participant}
      Code.require_file(Path.expand("./../../experiments/test2/test.exs", unquote(__DIR__)))
      host = File.read!(Path.expand("./../../experiments/test2/host.js", unquote(__DIR__)))
      participant = File.read!(Path.expand("./../../experiments/test2/participant.js", unquote(__DIR__)))
      @test2_experiment %Xee.Experiment{theme_id: :t2, module: Test2, host: host, participant: participant}
      import XeeWeb.ExperimentTestHelper
      def test_experiment, do: @test_experiment
      def test2_experiment, do: @test2_experiment
    end
  end

  @doc """
  Starts onetime token servers.
  """
  def prepare_servers do
  end

  @doc """
  Returns a socket connected as a host.
  """
  def join_channel(xid) do
    token = Phoenix.Token.sign(XeeWeb.Endpoint, "experiment", {:host, xid})
    socket("x:" <> xid, %{"token" => token})
  end


  @doc """
  Returns a socket connected as a participant.
  """
  def join_channel(xid, name) do
    token = Phoenix.Token.sign(XeeWeb.Endpoint, "experiment", {:participant, xid, name})
    socket("x:" <> xid, %{"token" => token})
  end

  @doc """
  Stops sockets.
  """
  def stop(sockets) do
    require Phoenix.ChannelTest
    Task.async(fn ->
      Enum.map(sockets, fn socket ->
        Phoenix.ChannelTest.push socket, "stop", finish()
      end)
      |> Enum.each(fn _ ->
        receive do
          _ -> nil
        end
      end)
    end)
    |> Task.await
    :timer.sleep(10) # just to be safe
  end

  defp finish do
    send self(), :finished
  end

  defp socket(topic, param) do
    require Phoenix.ChannelTest
    {:ok, socket} = Phoenix.ChannelTest.connect(XeeWeb.UserSocket, %{})
    {:ok, _, socket} = Phoenix.ChannelTest.subscribe_and_join(socket, topic, param)
    socket
  end
end
