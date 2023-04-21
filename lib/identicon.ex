defmodule Identicon do
  def main(text) do
    text
    |> create_hash
    |> pick_color
    |> build_grid
    |> filter_odd_squares
  end

  defp create_hash(text) do
    hash =
      :crypto.hash(:md5, text)
      |> :binary.bin_to_list()

    %Identicon.Image{hash: hash}
  end

  defp pick_color(%Identicon.Image{hash: [r, g, b | _rest]} = image) do
    %Identicon.Image{image | color: {r, g, b}}
  end

  defp build_grid(%Identicon.Image{hash: hash} = image) do
    grid =
      hash
      |> Enum.chunk_every(4)
      |> Enum.map(&mirror_row/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: grid}
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid =
      Enum.filter(grid, fn {code, _idx} ->
        rem(code, 2) == 0
      end)

    %Identicon.Image{image | grid: grid}
  end

  defp mirror_row([a, b | _rest] = row) do
    row ++ [b, a]
  end
end
