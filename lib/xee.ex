defmodule Xee do
  use Application

  @host_onetime_server_name :HostOnetime
  @participant_onetime_server_name :ParticipantOnetime

  def host_onetime, do: @host_onetime_server_name
  def participant_onetime, do: @participant_onetime_server_name

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
      # Here you could define other workers and supervisors as children
      # worker(Xee.Worker, [arg1, arg2, arg3]),
      worker(Onetime, [[name: @host_onetime_server_name]], id: :host),
      worker(Onetime, [[name: @participant_onetime_server_name]], id: :participant),
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
