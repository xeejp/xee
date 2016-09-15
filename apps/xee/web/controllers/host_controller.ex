defmodule Xee.HostController do
  use Xee.Web, :controller
  require Logger
  plug Xee.AuthenticationPlug

  def index(conn, _params) do
    user = conn.assigns[:host]
    experiment = Xee.HostServer.get(user.id)
    if experiment do
      experiment = Enum.map(experiment, fn(x) -> Xee.ExperimentServer.get_info(x) end)
    end
    render conn, "index.html", csrf_token: get_csrf_token(), experiment: experiment
  end

  def remove(conn, %{"xid" => xid}) do
    user = conn.assigns[:host]
    %{x_token: token} = Xee.ExperimentServer.get_info(xid)
    pid = Xee.ExperimentServer.get(xid)
    Xee.ExperimentServer.remove(xid)
    Xee.TokenServer.drop(token)
    Xee.HostServer.drop(user.id, xid)
    Xee.Experiment.stop(pid)
    conn
    |> redirect(to: "/host")
    |> halt
  end

  def experiment(conn, params) do
    user = conn.assigns[:host]
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
              |> Enum.filter(fn theme -> Xee.Theme.granted?(theme, user.name) end)
    if length(themes) == 0 do
      conn
      |> put_flash(:error, "There are no themes")
      |> redirect(to: "/host")
      |> halt
    else
      theme_id = Map.get(params, "theme_id", nil) || hd(themes).id
      render conn, "experiment.html", csrf_token: get_csrf_token(), experiment_name: "", theme_id: theme_id, themes: themes, x_token: Xee.TokenServer.generate_id
    end
  end

  def create(conn, %{"experiment_name" => name, "theme" => theme_id, "x_token" => x_token}) do
    if (String.length(name) == 0 || String.length(x_token) == 0) do
      conn
      |> put_flash(:error, "All fields are required")
      |> redirect(to: "/host/experiment?theme_id=#{theme_id}")
      |> halt
    else
      user = conn.assigns[:host]
      unless (Xee.TokenServer.has?(x_token)) do
        xid = Xee.TokenGenerator.generate
        themes = Xee.ThemeServer.get_all
                  |> Map.to_list
                  |> Enum.map(fn {_key, value} -> value end)
                  |> Enum.filter(fn theme -> Xee.Theme.granted?(theme, user.name) end)
        xtheme = Xee.ThemeServer.get(theme_id)
        true = Xee.Theme.granted?(xtheme, user.name)
        Xee.TokenServer.register(x_token, xid)
        Xee.ExperimentServer.create(xid, xtheme.experiment, %{name: name, experiment: xtheme.experiment, theme: xtheme.name, x_token: x_token, xid: xid})
        Xee.HostServer.register(user.id, xid)
        conn
        |> redirect(to: "/experiment/" <> xid <> "/host")
        |> halt
      else
        themes = Xee.ThemeServer.get_all
                  |> Map.to_list
                  |> Enum.map(fn {_key, value} -> value end)
                  |> Enum.filter(fn theme -> Xee.Theme.granted?(theme, user.name) end)
        conn
        |> put_flash(:error, "This ExperimentID is already being used.")
        |> render("experiment.html", csrf_token: get_csrf_token(), experiment_name: name, theme_id: theme_id, themes: themes, x_token: Xee.TokenServer.generate_id)
      end
    end
  end
end