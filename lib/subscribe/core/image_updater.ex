defmodule Subscribe.Core.ImageUpdater do
  use GenServer

  alias Subscribe.Core.Image

  require Logger

  def start_link() do
    Logger.info("Starting ImageUpdater GenServer")
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  def fetch_url(url) do
    GenServer.cast(__MODULE__, {:fetch_url, url})
  end

  @impl true
  def handle_cast({:fetch_url, url}, state) do
    url
    |> Image.create_from_url()
    |> Image.download()
    |> Image.generate_thumbnails()

    {:noreply, state}
  end
end
