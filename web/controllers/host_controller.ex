defmodule Xee.HostController do
  use Xee.Web, :controller

  plug Xee.AuthenticationPlug

  def index(conn, _params) do
    experiment = Xee.HostServer.get(get_session(conn, :current_user))
    render conn, "index.html", experiment: experiment
  end

  def experiment(conn, _params) do
    themes = Xee.ThemeServer.get_all
              |> Map.to_list
              |> Enum.map(fn {_key, value} -> value end)
    render conn, "experiment.html", csrf_token: get_csrf_token(), experiment_name: "", theme_num: "0", themes: themes, user_num: "1", startDateTime: "", endDateTime: "", showDescription: "true", id: Xee.TokenServer.generate_id
  end

  def create(conn, %{"experiment_name" => name, "theme" => theme, "user_num" => user_num, "startDateTime" => start_info, "endDateTime" => end_info, "showDescription" => show, "x_id" => x_id}) do
    if (name == nil || name == "") do
      conn
      |> put_flash(:error, "Make Experiment Error")
      |> redirect(to: "/host")
      |> halt
    else
      has   = Xee.HostServer.has?(get_session(conn, :current_user), x_id)
      exist = Xee.ExperimentServer.has?(x_id)
      unless (has || exist) do
        themes = Xee.ThemeServer.get_all
                  |> Map.to_list
                  |> Enum.map(fn {_key, value} -> value end)
        {val, _} = Integer.parse(theme)
        xtheme = Enum.at themes, val - 1
        Xee.ExperimentServer.create(x_id, %Xee.Experiment{theme_id: xtheme.id, script: xtheme.script, javascript: xtheme.javascript})
        uid = Xee.ExperimentServer.get(x_id)
        experiment_info = %{uid: uid, name: name, theme: theme, user_num: user_num, start_info: start_info, end_info: end_info, show: show, x_id: x_id}
        Xee.HostServer.register(get_session(conn, :current_user), x_id, experiment_info)
        conn
        |> put_flash(:info, "Made New Experiment : " <> name <> "(" <> theme <> ")")
        |> redirect(to: "/experiment/" <> x_id <> "/host")
        |> halt
      else
        themes = Xee.ThemeServer.get_all
                  |> Map.to_list
                  |> Enum.map(fn {_key, value} -> value end)
        conn
        |> put_flash(:error, "This ExperimentID is already being used.")
        |> render("experiment.html", csrf_token: get_csrf_token(), experiment_name: name, theme_num: theme, themes: themes, user_num: user_num, startDateTime: start_info, endDateTime: end_info, showDescription: show, id: Xee.TokenServer.generate_id)
      end
    end
  end
end
