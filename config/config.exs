# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

import_config "../apps/*/config/config.exs"

defmodule Xee.ThemeConfig do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      {:ok, pid} = Agent.start_link(fn -> %{module_themes: [], file_themes: []} end)
      var!(theme_config, Xee.ThemeConfig) = pid
    end
  end

  defmacro register_themes do
    quote do
      %{
        module_themes: module_themes,
        file_themes: file_themes
      } = Agent.get(var!(theme_config, Xee.ThemeConfig), fn map -> map end)
      config :xee, Xee.ThemeServer,
        file_themes: file_themes,
        module_themes: module_themes
    end
  end

  defmacro theme(name, params) do
    name = Macro.expand(name, __CALLER__)
    if is_atom(name) do
      quote do
        Agent.update(var!(theme_config, Xee.ThemeConfig), fn map ->
          Map.update!(map, :module_themes, fn themes -> [{unquote(name), unquote(params)} | themes] end)
        end)
      end
    else
      quote do
        Agent.update(var!(theme_config, Xee.ThemeConfig), fn map ->
          Map.update!(map, :file_themes, fn themes -> [{unquote(name), unquote(params)} | themes] end)
        end)
      end
    end
  end
end

config :xee, Xee.ThemeServer,
  module_themes: [],
  file_themes: []
import_config "themes.exs"
