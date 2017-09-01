defmodule Absinthe.Plug.GraphiQL.Assets do
  @moduledoc """
  """

  @config Application.get_env(:absinthe_plug, Absinthe.Plug.GraphiQL)
  @default_config [
    local_url_path: "/absinthe_graphiql",
    local_directory: "priv/static/absinthe_graphiql",
    local_source: ":package/:alias",
    remote_source: "https://cdn.jsdelivr.net/npm/:package@:version/:file",
  ]

  @react_version "15.6.1"
  
  @assets [
    {"whatwg-fetch", "2.0.3", [
      {"fetch.min.js", "fetch.js"},
    ]},
    {"react", @react_version, [
      {"dist/react.min.js", "react.js"},
    ]},
    {"react-dom", @react_version, [
      {"dist/react-dom.min.js", "react-dom.js"},
    ]},
    {"bootstrap", "3.3.7", [
      {"dist/css/bootstrap.min.css", "bootstrap.css"},
    ]},
    {"graphiql", "0.11.3", [
      "graphiql.css",
      {"graphiql.min.js", "graphiql.js"},
    ]},
    {"graphiql-workspace", "1.0.4", [
      "graphiql-workspace.css",
      {"graphiql-workspace.min.js", "graphiql-workspace.js"}
    ]},
    {"graphiql-subscriptions-fetcher", "0.0.2", [
      {"browser/client.js", "graphiql-subscriptions-fetcher.js"},
    ]},
    {"phoenix", "1.3.0", [
      {"priv/static/phoenix.min.js", "phoenix.js"},
    ]},
    {"absinthe-phoenix", "0.1.1", [
      {"browser/index.min.js", "absinthe-phoenix.js"},
    ]},
  ]

  def assets_config do
    case @config do
      nil ->
        @default_config
      config ->
        @default_config
        |> Keyword.merge(Keyword.get(config, :assets, []))
    end
  end

  def get_assets(source), do: reduce_assets(
    %{},
    &Map.put(
      &2,
      build_asset_path(:local_source, &1),
      asset_source_url(source, &1)
    )
  )

  def get_asset_mappings, do: reduce_assets(
    [],
    &(&2 ++ [{
      local_asset_path(&1),
      asset_source_url(:remote, &1)
    }])
  )

  defp reduce_assets(initial, reducer) do
    Enum.reduce(@assets, initial, fn {package, version, files}, acc ->
      Enum.reduce(files, acc, &reducer.({package, version, &1}, &2))
    end)
  end

  defp local_asset_path(asset), do: Path.join(
    assets_config()[:local_directory], build_asset_path(:local_source, asset))

  defp asset_source_url(:smart, asset) do
    if File.exists?(local_asset_path(asset)) do
      asset_source_url(:local, asset)
    else
      asset_source_url(:remote, asset)
    end
  end
  defp asset_source_url(:local, asset), do: Path.join(assets_config()[:local_url_path], build_asset_path(:local_source, asset))
  defp asset_source_url(:remote, asset), do: build_asset_path(:remote_source, asset)

  defp build_asset_path(source, {package, version, {real_path, aliased_path}}) do
    assets_config()[source]
    |> String.replace(":package", package)
    |> String.replace(":version", version)
    |> String.replace(":file", real_path)
    |> String.replace(":alias", aliased_path)
  end
  defp build_asset_path(source, {package, version, path}), do: build_asset_path(source, {package, version, {path, path}})
end
