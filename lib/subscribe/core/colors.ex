defmodule Subscribe.Colors do
  alias Subscribe.Core.Podcast
  alias Subscribe.Core.Image
  alias Subscribe.Colors

  defstruct [:dominant, :main, :dark]

  def from_podcast(%Podcast{} = podcast) do
    image = Image.create_from_url(podcast.cover_url)
    size = "540x540"
    path = Image.thumbnail_path(image, size)

    dominant =
      if File.exists?(path) do
        path
        |> OcvPhotoAnalyzer.analyze([:dominant])
        |> Map.get(:dominant)
      else
        []
      end

    %Colors{dominant: dominant}
  end

  def determine_main_color(colors) do
    %{colors | main: get_main_color(colors)}
  end

  def determine_dark_color(colors) do
    %{colors | dark: get_dark_color(colors)}
  end

  @doc """
  Gets first color that is dark enough for white background.

  ## Examples

      iex> get_dark_color %Subscribe.Colors{dominant: [%{b: 184, g: 161, r: 191}, %{b: 20, g: 150, r: 13}]}
      %{b: 20, g: 150, r: 13}

      iex> get_dark_color %Subscribe.Colors{dominant: [%{b: 184, g: 161, r: 191}]}
      %{b: 0, g: 0, r: 0}
  """
  def get_dark_color(%Colors{dominant: dominant}) do
    dominant
    |> Enum.filter(fn %{b: b, g: g, r: r} -> r + b + g < 170 * 3 end)
    |> List.first()
    |> case do
      nil -> %{b: 0, g: 0, r: 0}
      color -> color
    end
  end

  def get_main_color(%Colors{dominant: dominant}) when length(dominant) > 0 do
    List.first(dominant)
  end

  def get_main_color(_) do
    %{r: 255, g: 255, b: 255}
  end

  def to_rgb(%{r: r, g: g, b: b}) do
    "rgb(#{r}, #{g}, #{b})"
  end

  def to_rgb(colors) when is_list(colors) do
    Enum.map(colors, fn c -> to_rgb(c) end)
  end

  @doc """
  Removes blacks and whites from dominant colors.

  ## Examples

      iex> remove_blacks_and_whites %Subscribe.Colors{dominant: [%{b: 34, g: 61, r: 191}, %{b: 255, g: 255, r: 254}, %{b: 1, g: 1, r: 1}]}
      %Subscribe.Colors{dominant: [%{b: 34, g: 61, r: 191}]}
  """
  def remove_blacks_and_whites(%Colors{dominant: dominant} = colors) do
    interesting_colors =
      dominant
      |> without_blacks()
      |> without_whites()

    %{colors | dominant: interesting_colors}
  end

  @doc """
  Removes whites from colors.

  ## Examples

      iex> without_whites [%{b: 34, g: 61, r: 191}, %{b: 255, g: 255, r: 254}]
      [%{b: 34, g: 61, r: 191}]

      iex> without_whites [%{b: 34, g: 61, r: 191}]
      [%{b: 34, g: 61, r: 191}]

      iex> without_whites []
      []

  """
  def without_whites(colors) do
    threshold = 10
    Enum.filter(colors, fn %{b: b, g: g, r: r} -> r + g + b < 255 * 3 - threshold end)
  end

  @doc """
  Removes blacks from colors.

  ## Examples

      iex> without_blacks [%{b: 34, g: 61, r: 191}, %{b: 0, g: 0, r: 1}]
      [%{b: 34, g: 61, r: 191}]

      iex> without_blacks [%{b: 34, g: 61, r: 191}]
      [%{b: 34, g: 61, r: 191}]

      iex> without_blacks []
      []

  """
  def without_blacks(colors) do
    threshold = 10
    Enum.filter(colors, fn %{b: b, g: g, r: r} -> r + g + b > threshold end)
  end
end
