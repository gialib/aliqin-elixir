defmodule Aliqin.Mixfile do
  use Mix.Project

  def project do
    [
      app: :aliqin,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      applications: [:httpoison, :timex]
    ]
  end

  defp deps do
    [
      {:timex, "~> 3.0"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:poison, github: "devinus/poison", override: true},
      {:httpoison, github: "edgurgel/httpoison", override: true},
      {:hackney, "1.7.1", manager: :rebar3, override: true}
    ]
  end

  defp description do
    "Aliqin For Elixir SDK, 阿里大于"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "CHANGELOG*", "LICENSE*"],
      maintainers: ["happy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gialib/aliqin"}
    ]
  end
end
