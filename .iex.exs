global_settings = "~/.iex.exs"
if File.exists?(global_settings), do: Code.require_file(global_settings)

Application.put_env(:elixir, :ansi_enabled, true)

IEx.configure(
  colors: [
    eval_result: [:cyan, :bright],
    eval_error: [[:red, :bright, "\n▶▶▶\n"]],
    eval_info: [:yellow, :bright]
  ],
  default_prompt:
    [
      # cursor ⇒ column 1
      "\e[G",
      :green,
      "%prefix",
      :magenta,
      "|",
      :green,
      "%counter",
      " ",
      :magenta,
      "▶",
      :reset
    ]
    |> IO.ANSI.format()
    |> IO.chardata_to_string()
)

import Ecto.Query, warn: false

alias Subscribe.Repo
alias Subscribe.FeedParser
alias Subscribe.Core.{Episode, Podcast, FeedFetcher, PodcastUpdaterProgress, PodcastUpdater}

IO.puts("Useful commands:")
IO.puts("  PodcastUpdater.update_podcasts()")
IO.puts("  Subscribe.Repo.get(Podcast, 1) |> Podcast.refresh_data()")
