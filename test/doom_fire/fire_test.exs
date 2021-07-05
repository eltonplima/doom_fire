defmodule FireTest do
  use ExUnit.Case, async: true

  test "default initial value" do
    rows = 2
    columns = 2

    assert %Fire{
             rows: rows,
             columns: columns,
             data: %{{0, 0} => 0, {0, 1} => 0, {1, 0} => 0, {1, 1} => 0},
             initial_value: 0
           } ==
             Fire.new(rows, columns)
  end

  test "ignore default initial value if data is filled" do
    rows = 2
    columns = 2
    data = %{{0, 0} => 1, {0, 1} => 2, {1, 0} => 3, {1, 1} => 4}

    assert %Fire{rows: rows, columns: columns, data: data, initial_value: 0} ==
             Fire.new(rows, columns, data)
  end

  test "Enumerable.count implementation" do
    assert 100 = Enum.count(Fire.new(10, 10))
  end

  test "Enumerable.reduce implementation" do
    assert 200 = Enum.reduce(Fire.new(10, 10), 0, fn _, acc -> acc + 2 end)
  end

  test "Enumerable.member? implementation" do
    rows = 2
    columns = 2
    data = %{{0, 0} => 1, {0, 1} => 2, {1, 0} => 3, {1, 1} => 4}

    assert Enum.member?(Fire.new(rows, columns, data), 3)
  end

  test "Enumerable.slice implementation" do
    rows = 2
    columns = 2
    data = %{{0, 0} => 1, {0, 1} => 2, {1, 0} => 3, {1, 1} => 4}
    assert [2, 3] == Enum.slice(Fire.new(rows, columns, data), 1..2)
  end

  test "set_base_fire_intensity" do
    fire = Fire.new(2, 2) |> Fire.set_base_fire_intensity(99)
    expected = %{{0, 0} => 0, {0, 1} => 0, {1, 0} => 99, {1, 1} => 99}
    assert expected == fire.data
  end

  test "burn 2x2" do
    decay_fun = fn -> 1 end
    fire = Fire.new(2, 2) |> Fire.set_base_fire_intensity(99) |> Fire.burn(decay_fun)

    expected = %{
      {0, 0} => 98,
      {0, 1} => 98,
      {1, 0} => 99,
      {1, 1} => 99
    }

    assert expected == fire.data
  end

  test "burn 3x3" do
    decay_fun = fn -> 1 end
    fire = Fire.new(3, 3) |> Fire.set_base_fire_intensity(99) |> Fire.burn(decay_fun)

    expected = %{
      {0, 0} => 97,
      {0, 1} => 97,
      {0, 2} => 97,
      {1, 0} => 98,
      {1, 1} => 98,
      {1, 2} => 98,
      {2, 0} => 99,
      {2, 1} => 99,
      {2, 2} => 99
    }

    assert expected == fire.data
  end
end
