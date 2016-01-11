defmodule Xee.HostController do
  use Xee.Web, :controller

  plug Xee.AuthenticationPlug

  def index(conn, _params) do
    user = Integer.to_string(get_session(conn, :current_user))
    experiment = Xee.HostServer.get(user)
    if experiment do
      experiment = Enum.map(experiment, fn(x) -> Xee.ExperimentServer.get_info(x) end)
    end
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
      user = Integer.to_string(get_session(conn, :current_user))
      has   = Xee.HostServer.has?(user, x_id)
      exist = Xee.ExperimentServer.has?(x_id)
      unless (has || exist) do
        themes = Xee.ThemeServer.get_all
                  |> Map.to_list
                  |> Enum.map(fn {_key, value} -> value end)
        {val, _} = Integer.parse(theme)
        xtheme = Enum.at(themes, val - 1)
        Xee.ExperimentServer.create(x_id, %Xee.Experiment{theme_id: xtheme.id, script: xtheme.script, javascript: xtheme.javascript},
        %{name: name, theme: xtheme.name, user_num: user_num, start_info: start_info, end_info: end_info, show: show, x_id: x_id})
        Xee.HostServer.register(user, x_id)
        conn
        |> put_flash(:info, "Made New Experiment : " <> name <> "(" <> xtheme.name <> ")")
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
