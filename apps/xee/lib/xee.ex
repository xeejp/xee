defmodule Xee do
  use Application

  @channel_onetime_server_name :ChannelOnetime

  def channel_token_onetime, do: @channel_onetime_server_name

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(Xee.Endpoint, []),
      # Start the Ecto repository
      worker(Xee.Repo, []),
      worker(Xee.ThemeServer, []),
      worker(Xee.HostServer, []),
      worker(Xee.TokenServer, []),
      worker(Xee.ExperimentServer, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Xee.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Xee.Endpoint.config_change(changed, removed)
    :ok
  end
end
