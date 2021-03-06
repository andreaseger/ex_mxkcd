defmodule MXkcd.Mixfile do
  use Mix.Project

  def project do
    [app: :m_xkcd,
     version: "0.0.1",
     elixir: "~> 0.15.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.4.1"},
      {:timex, "~> 0.12.4"}, # date/time handling
      {:poison, "~> 1.0.1"}, # json library
      {:extwitter, "~> 0.1.3"}
    ]
  end
end
