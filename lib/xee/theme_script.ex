defmodule Xee.ThemeScript do
  @moduledoc """
  A behaviour module for implementing the theme script.

  ## Examples

      def YourTheme do
        use Xee.ThemeScript

        require_file "other_file1.exs"

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
      import unquote(__MODULE__)
      @behaviour unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :require_file, accumulate: true)
      @before_compile unquote(__MODULE__)

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

  defmacro __before_compile__(_env) do
    quote do
      def require_files, do: @require_file
    end
  end

  defmacro require_file(file) do
    quote do
      @require_file unquote(file)
    end
  end
end
