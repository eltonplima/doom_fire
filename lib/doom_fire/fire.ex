defmodule Fire do
  defstruct rows: nil, columns: nil, data: [], initial_value: 0

  def new(rows, columns, initial_value \\ 0) do
    width = rows * columns

    data =
      Enum.reduce(0..(width - 1), %{}, fn index, acc ->
        row = div(index, rows)
        col = rem(index, columns)
        Map.put(acc, {row, col}, initial_value)
      end)

    %__MODULE__{rows: rows, columns: columns, data: data}
  end

  def set_base_fire_intensity(%__MODULE__{rows: rows, columns: columns} = fire, intensity) do
    base_row = rows - 1
    last_column_from_base_row = columns - 1

    fire =
      Enum.reduce(0..last_column_from_base_row, fire, fn column, fire ->
        data = Map.put(fire.data, {base_row, column}, intensity)
        %__MODULE__{rows: fire.rows, columns: fire.columns, data: data}
      end)

    fire
  end

  def burn(%__MODULE__{rows: rows} = fire, decay_fun) do
    penultimate_row = rows - 2

    burn_rows(fire, penultimate_row, decay_fun)
  end

  defp burn_rows(fire, start_row, decay_fun) do
    Enum.reduce(start_row..0, fire, fn row, fire ->
      burn_cols(fire, row, decay_fun)
    end)
  end

  defp burn_cols(%__MODULE__{columns: columns} = fire, row, decay_fun)
       when is_function(decay_fun) do
    Enum.reduce(0..(columns - 1), fire, fn col, fire ->
      parent_particle_intensity = get_parent_particle_intensity(fire, row, col)
      decay_value = decay_fun.()

      target_particle_coord = calculate_target_particle_coords(fire, row, col, decay_value)
      new_intensity = calculate_particle_intensity(parent_particle_intensity, decay_value)
      set_particle_intensity(fire, target_particle_coord, new_intensity)
    end)
  end

  defp get_parent_particle_coord(row, col) do
    parent_particle_row = row + 1
    {parent_particle_row, col}
  end

  defp get_parent_particle_intensity(fire, row, col) do
    parent_particle_coord = get_parent_particle_coord(row, col)
    Map.get(fire.data, parent_particle_coord)
  end

  defp calculate_target_particle_coords(
         %__MODULE__{columns: columns},
         row,
         col,
         decay_value
       ) do
    target_particle_col =
      case col - decay_value do
        value when value < 0 -> columns - decay_value
        value -> value
      end

    target_particle_row = row
    {target_particle_row, target_particle_col}
  end

  defp calculate_particle_intensity(parent_particle_intensity, decay_value) do
    case parent_particle_intensity - decay_value do
      value when value < 0 -> 0
      value -> value
    end
  end

  defp set_particle_intensity(fire, target_particle_coord, intensity) do
    data =
      Map.put(
        fire.data,
        target_particle_coord,
        intensity
      )

    %__MODULE__{rows: fire.rows, columns: fire.columns, data: data}
  end

  defimpl Enumerable do
    def count(fire) do
      {:ok, Enum.count(fire.data)}
    end

    def reduce(fire, acc, fun) do
      Enumerable.Map.reduce(fire.data, acc, fun)
    end

    def member?(fire, other) do
      data = Map.values(fire.data)
      {:ok, Enum.member?(data, other)}
    end

    # TODO: Realmente preciso implementar essa fun????o para um map?
    def slice(fire) do
      data = Map.values(fire.data)
      size = length(data)
      {:ok, size, &Enumerable.List.slice(data, &1, &2, size)}
    end
  end
end
