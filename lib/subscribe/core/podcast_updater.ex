defmodule Subscribe.Core.PodcastUpdater do
  use GenServer

  alias Subscribe.Core
  alias Subscribe.Core.Podcast
  alias Subscribe.Core.PodcastUpdaterProgress, as: Progress

  require Logger

  def start_link() do
    Logger.info("Start GenServer: PodcastUpdater")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  def update_podcasts() do
    GenServer.cast(__MODULE__, :update_podcasts)
  end

  def handle_cast(:update_podcasts, state) do
    time_start = DateTime.utc_now()

    podcasts = Core.list_podcasts()
    total = length(podcasts)

    Progress.start(total)

    _update_podcasts(podcasts)

    time_stop = DateTime.utc_now()
    duration = DateTime.diff(time_stop, time_start)

    Logger.info("Updated #{total} podcasts in #{format_seconds(duration)}")

    {:noreply, state}
  end

  defp _update_podcasts(podcasts) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    supervisor
    |> Task.Supervisor.async_stream_nolink(
      podcasts,
      __MODULE__,
      :update_podcast,
      [],
      max_concurrency: 10,
      timeout: :timer.minutes(5),
      on_timeout: :kill_task
    )
    |> Enum.to_list()
    |> Enum.filter(fn
      {:error, _} -> true
      _ -> false
    end)
    |> Enum.each(fn {code, info} ->
      Logger.warn(fn -> "Error when updating Podcast: #{code} #{inspect(info)}" end)
    end)

    Supervisor.stop(supervisor)
  end

  def update_podcast(podcast) do
    result = Podcast.refresh_data(podcast)
    Progress.increment()
    result
  end

  def format_seconds(seconds) do
    Time.new(0, 0, 0)
    |> elem(1)
    |> Time.add(seconds, :second)
    |> Time.to_erl()
    |> case do
      {0, 0, s} -> "#{s}s"
      {0, m, s} -> "#{m}m #{s}s"
      {h, m, s} -> "#{h}h #{m}m #{s}s"
    end
  end
end
