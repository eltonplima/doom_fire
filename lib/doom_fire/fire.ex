defmodule Fire do
  defstruct rows: nil, columns: nil, data: [], initial_value: 0

  def new(rows, columns, data \\ %{}, initial_value \\ 0) do
    width = rows * columns

    data =
      case length(Map.to_list(data)) do
        0 ->
          Enum.reduce(0..(width - 1), %{}, fn index, acc ->
            row = div(index, rows)
            col = rem(index, columns)
            Map.put(acc, {row, col}, initial_value)
          end)

        _ ->
          data
      end

    %__MODULE__{rows: rows, columns: columns, data: data}
  end

  def set_base_fire_intensity(
        %__MODULE__{rows: rows, columns: columns} = fire,
        intensity
      ) do
    base_row = rows - 1
    last_base_row_column = columns - 1

    fire =
      Enum.reduce(0..last_base_row_column, fire, fn column, fire ->
        data = Map.put(fire.data, {base_row, column}, intensity)
        %__MODULE__{rows: fire.rows, columns: fire.columns, data: data}
      end)

    fire
  end

  def burn(
        %__MODULE__{rows: rows} = fire,
        decay \\ 1
      ) do
    penultimate_row = rows - 2

    burn_rows(fire, penultimate_row, decay)
  end

  defp burn_rows(fire, start_row, decay) do
    Enum.reduce(start_row..0, fire, fn row, fire ->
      burn_cols(fire, row, decay)
    end)
  end

  defp burn_cols(%__MODULE__{columns: columns} = fire, row, decay) when is_function(decay) do
    Enum.reduce(0..(columns - 1), fire, fn col, fire ->
      parent_particle_row = row + 1
      parent_particle_coord = {parent_particle_row, col}
      parent_particle_intensity = Map.get(fire.data, parent_particle_coord)
      decay_value = decay.(parent_particle_intensity)

      target_particle_col =
        case col - decay_value do
          value when value < 0 -> columns - decay_value
          value -> value
        end

      target_particle_row = row
      target_particle_coord = {target_particle_row, target_particle_col}

      new_intensity =
        case parent_particle_intensity - decay_value do
          value when value < 0 -> 0
          value -> value
        end

      data =
        Map.put(
          fire.data,
          target_particle_coord,
          new_intensity
        )

      %__MODULE__{rows: fire.rows, columns: fire.columns, data: data}
    end)
  end

  defp burn_cols(%__MODULE__{columns: columns} = fire, row, decay) do
    Enum.reduce(0..(columns - 1), fire, fn col, fire ->
      parent_particle_row = row + 1
      parent_particle_coord = {parent_particle_row, col}
      particle_coord = {row, col}
      #      decay = :rand.uniform(36)

      parent_particle_intensity = Map.get(fire.data, parent_particle_coord)
      data = Map.put(fire.data, particle_coord, parent_particle_intensity - decay)
      %__MODULE__{rows: fire.rows, columns: fire.columns, data: data}
    end)
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

    # TODO: Realmente preciso implementar essa função para um map?
    def slice(fire) do
      data = Map.values(fire.data)
      size = length(data)
      {:ok, size, &Enumerable.List.slice(data, &1, &2, size)}
    end
  end
end
