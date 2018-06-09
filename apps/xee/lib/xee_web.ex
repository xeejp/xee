defmodule XeeWeb do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use XeeWeb, :controller
      use XeeWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: XeeWeb
      use Ecto.Schema

      alias Xee.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]

      import XeeWeb.Router.Helpers
    end
  end

  def view do
    quote do
      use Phoenix.View, root: "lib/xee_web/templates",
                        namespace: XeeWeb

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import XeeWeb.Router.Helpers
      import XeeWeb.ErrorHelpers
      import XeeWeb.Gettext
      import Xee.Session, only: [current_user: 1, logged_in?: 1]
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel

      alias Xee.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]

    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
