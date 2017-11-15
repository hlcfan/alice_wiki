defmodule AliceWiki.Mixfile do
  use Mix.Project

  def project do
    [
      app: :alice_wiki,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      # applications: [:alice_wiki]
      mod: {
      Alice, %{
        handlers: [
          # Alice.Handlers.Random,
          # Alice.Handlers.AgainstHumanity,
          Alice.Handlers.AliceWiki
        ]
      }
    }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:alice, "~> 0.3"},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
