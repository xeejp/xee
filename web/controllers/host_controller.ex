defmodule Xee.HostController do
  use Xee.Web, :controller

  plug Xee.AuthenticationPlug

  def index(conn, _params) do
    user = conn.assigns[:host]
    experiment = Xee.HostServer.get(user.id)
    if experiment do
      experiment = Enum.map(experiment, fn(x) -> Xee.ExperimentServer.get_info(x) end)
    end
    render conn, "index.html", experiment: experiment
  end

  def experiment(conn, _params) do
    user = conn.assigns[:host]
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
              |> Enum.filter(fn theme -> Xee.Theme.granted?(theme, user.name) end)
    render conn, "experiment.html", csrf_token: get_csrf_token(), experiment_name: "", theme_id: hd(themes).id, themes: themes, user_num: "1", startDateTime: "", endDateTime: "", showDescription: "true", x_token: Xee.TokenServer.generate_id
  end

  def create(conn, %{"experiment_name" => name, "theme" => theme_id, "user_num" => user_num, "startDateTime" => start_info, "endDateTime" => end_info, "showDescription" => show, "x_token" => x_token}) do
    if (name == nil || name == "") do
      conn
      |> put_flash(:error, "Make Experiment Error")
      |> redirect(to: "/host")
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
        Xee.ExperimentServer.create(xid, xtheme.experiment, %{name: name, experiment: xtheme.experiment, theme: xtheme.name, user_num: user_num, start_info: start_info, end_info: end_info, show: show, x_token: x_token, xid: xid})
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
        |> render("experiment.html", csrf_token: get_csrf_token(), experiment_name: name, theme_id: theme_id, themes: themes, user_num: user_num, startDateTime: start_info, endDateTime: end_info, showDescription: show, x_token: Xee.TokenServer.generate_id)
      end
    end
  end
end
