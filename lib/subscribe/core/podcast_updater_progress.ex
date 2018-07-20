defmodule Subscribe.Core.PodcastUpdaterProgress do
  use GenServer
  require Logger

  def start_link() do
    Logger.info("Start GenServer: PodcastUpdaterProgress")
    GenServer.start_link(__MODULE__, %{total: 0, progress: 0}, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  @doc """
  Initialize progress bar with maximum value.
  """
  def start(total) do
    GenServer.call(__MODULE__, {:start, total})
  end

  @doc """
  Set progress to specific value.
  """
  def update(progress) do
    GenServer.call(__MODULE__, {:update, progress})
  end

  @doc """
  Increment progress by one.
  """
  def increment() do
    GenServer.call(__MODULE__, :increment)
  end

  def handle_call({:start, total}, _from, state) do
    {:reply, render(0, total), %{state | total: total, progress: 0}}
  end

  def handle_call({:update, progress}, _from, state) do
    {:reply, render(progress, state.total), %{state | progress: progress}}
  end

  def handle_call(:increment, _from, state) do
    progress = state.progress + 1

    {:reply, render(progress, state.total), %{state | progress: progress}}
  end

  defp render(current, total) do
    should_render?() && ProgressBar.render(current, total)
  end

  # use IEx.started?() to render in IEx only
  # use Application.get_env(:elixir, :ansi_enabled) to render in both IEx and mix
  defp should_render? do
    Application.get_env(:elixir, :ansi_enabled)
  end
end
