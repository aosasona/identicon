defmodule Identicon do
  def main(text) do
    text
    |> create_hash
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_px_map
    |> draw_image
    |> save_to_drive(text)
  end

  def save_to_drive(image, text) do
    File.write("images/#{text}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, px_map: px_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(px_map, fn {start, stop} ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def create_hash(text) do
    hash =
      :crypto.hash(:md5, text)
      |> :binary.bin_to_list()

    %Identicon.Image{hash: hash}
  end

  def pick_color(%Identicon.Image{hash: [r, g, b | _rest]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  def build_grid(%Identicon.Image{hash: hash} = image) do
    grid =
      hash
      |> Enum.chunk_every(4)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _idx} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  def mirror_row([a, b | _rest] = row) do
    row ++ [b, a]
  end

  def build_px_map(%Identicon.Image{grid: grid} = image) do
    px_map =
      Enum.map(grid, fn {_, idx} ->
        x = rem(idx, 5) * 50
        y = div(idx, 5) * 50

        top_left = {x, y}
        bottom_right = {x + 50, y + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | px_map: px_map}
  end
end
