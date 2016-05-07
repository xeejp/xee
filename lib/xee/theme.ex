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

defmodule Xee.ThemeScript do
  @moduledoc """
  A behaviour module for implementing the theme script.

  ## Examples

      def YourTheme do
        use Xee.ThemeScript

        # Callbacks

        def init, do: %{ids: MapSet.new(), logs: []}

        def join(%{ids: ids} = data, id) do
          {:ok, %{data | ids: MapSet.put(ids, id)}}
        end

        def handle_received(data, received) do
          handle_received(data, received, :host)
        end

        def handle_received(%{logs: logs} = data, received, id) do
          {:ok, %{data | logs: [{id, received} | logs]}}
        end
      end

  """

  @typedoc "Return values of `init/0`, `join/2`, and `handle_received/*` functions."
  @type result ::
    {:ok, new_state :: term} |
    :error |
    {:error, reason :: term}

  @doc """
  Invoked when the theme is loaded or reloaded.
  """
  @callback install :: :ok | :error | {:error, reason :: term}

  @doc """
  Invoked when experiment is being created.

  Returning `{:ok, new_state}` sets the initial state to `new_state`.
  Returning `:error` or `{:error, reason}` fails the creating of experiment.
  """
  @callback init :: result

  @doc """
  Invoked when a participant loads the experiment page.

  Returning `{:ok, new_state}` changes the state to `new_state`.
  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback join(state :: term, id :: term) :: result

  @doc """
  Invoked when experiment is created.

  Returning `{:ok, new_state}` changes the state to `new_state`.
  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback handle_received(data :: term, received :: term) :: result

  @doc """
  Invoked when experiment is created.

  Returning `{:ok, new_state}` changes the state to `new_state`.
  Returning `:error` or `{:error, reason}` keeps the state.
  """
  @callback handle_received(data :: term, received :: term, id :: term) :: result

  @doc false
  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Xee.ThemeScript

      @doc false
      def init, do: {:ok, nil}
      def script_type, do: :data
      def install, do: :ok
      def handle_received(data, received) do
        {:error, "There is no matched `handle_received/2`. data = #{inspect data}, received = #{inspect received}"}
      end
      def handle_received(data, received, id) do
        {:error, "There is no matched `handle_received/3`. data = #{inspect data}, received = #{inspect received}, id = #{inspect id}"}
      end

      defoverridable [init: 0, install: 0, script_type: 0,
       handle_received: 2, handle_received: 3]
    end
  end
end
