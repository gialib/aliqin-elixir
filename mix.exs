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
      {:poison, ">= 0.0.0"},
      {:httpoison, ">= 0.0.0"},
      {:hackney, ">= 0.0.0"}
    ]
  end

  defp description do
    "Aliqin For Elixir SDK, 阿里大于"
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["happy"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/gialib/aliqin-elixir"}
    ]
  end
end
