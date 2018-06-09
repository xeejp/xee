defmodule XeeWeb.Router do
  use XeeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :js do
    plug :accepts, ["js"]
  end

  scope "/", XeeWeb do
    pipe_through :js
    get "/experiment/:xid/participant.js", ExperimentController, :participant_script
    get "/experiment/:xid/host.js", ExperimentController, :host_script
    get "/theme/:theme_id/description.js", ThemeController, :description_script
  end

  scope "/", XeeWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about

    # registration page
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create

    # login page
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    get "/logout", SessionController, :delete

    # theme page
    get "/explore/:page", ThemeController, :explore
    get "/theme/:theme_id", ThemeController, :theme

    # experiment page
    get "/experiment", ExperimentController, :shortcut
    get "/experiment/:xid", ExperimentController, :index
    get "/experiment/:xid/host", ExperimentController, :host
    get "/experiment/:xid/host/:id", ExperimentController, :control
    get "/experiment/host/:id", ExperimentController, :control
  end

  scope "/host", XeeWeb do
    pipe_through :browser # Use the default browser stack
    get "/", HostController, :index
    get "/index", HostController, :index
    post "/remove", HostController, :remove
    get "/experiment", HostController, :experiment
    post "/experiment/create", HostController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", XeeWeb do
  #   pipe_through :api
  # end
end
