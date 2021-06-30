defmodule DoomFireWeb.PageLive do
  use DoomFireWeb, :live_view
  @rows 10
  @columns 10
  @burn_interval 100
  @debug false
  @fire_colors_palette %{
    0 => %{
      r: 7,
      g: 7,
      b: 7
    },
    1 => %{
      r: 31,
      g: 7,
      b: 7
    },
    2 => %{
      r: 47,
      g: 15,
      b: 7
    },
    3 => %{
      r: 71,
      g: 15,
      b: 7
    },
    4 => %{
      r: 87,
      g: 23,
      b: 7
    },
    5 => %{
      r: 103,
      g: 31,
      b: 7
    },
    6 => %{
      r: 119,
      g: 31,
      b: 7
    },
    7 => %{
      r: 143,
      g: 39,
      b: 7
    },
    8 => %{
      r: 159,
      g: 47,
      b: 7
    },
    9 => %{
      r: 175,
      g: 63,
      b: 7
    },
    10 => %{
      r: 191,
      g: 71,
      b: 7
    },
    11 => %{
      r: 199,
      g: 71,
      b: 7
    },
    12 => %{
      r: 223,
      g: 79,
      b: 7
    },
    13 => %{
      r: 223,
      g: 87,
      b: 7
    },
    14 => %{
      r: 223,
      g: 87,
      b: 7
    },
    15 => %{
      r: 215,
      g: 95,
      b: 7
    },
    16 => %{
      r: 215,
      g: 95,
      b: 7
    },
    17 => %{
      r: 215,
      g: 103,
      b: 15
    },
    18 => %{
      r: 207,
      g: 111,
      b: 15
    },
    19 => %{
      r: 207,
      g: 119,
      b: 15
    },
    20 => %{
      r: 207,
      g: 127,
      b: 15
    },
    21 => %{
      r: 207,
      g: 135,
      b: 23
    },
    22 => %{
      r: 199,
      g: 135,
      b: 23
    },
    23 => %{
      r: 199,
      g: 143,
      b: 23
    },
    24 => %{
      r: 199,
      g: 151,
      b: 31
    },
    25 => %{
      r: 191,
      g: 159,
      b: 31
    },
    26 => %{
      r: 191,
      g: 159,
      b: 31
    },
    27 => %{
      r: 191,
      g: 167,
      b: 39
    },
    28 => %{
      r: 191,
      g: 167,
      b: 39
    },
    29 => %{
      r: 191,
      g: 175,
      b: 47
    },
    30 => %{
      r: 183,
      g: 175,
      b: 47
    },
    31 => %{
      r: 183,
      g: 183,
      b: 47
    },
    32 => %{
      r: 183,
      g: 183,
      b: 55
    },
    33 => %{
      r: 207,
      g: 207,
      b: 111
    },
    34 => %{
      r: 223,
      g: 223,
      b: 159
    },
    35 => %{
      r: 239,
      g: 239,
      b: 199
    },
    36 => %{
      r: 255,
      g: 255,
      b: 255
    }
  }

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: send(self(), :burn)

    fire = Fire.new(@rows, @columns) |> Fire.set_base_fire_intensity(36)

    {:ok, assign(socket, fire: fire, fire_colors_palette: @fire_colors_palette, debug: @debug)}
  end

  @impl true
  def handle_info(:burn, socket) do
    Process.send_after(self(), :burn, @burn_interval)

    decay_fun = fn parent_value ->
      case parent_value - :rand.uniform(@columns) do
        value when value < 0 -> 0
        value -> value
      end
    end

    fire = socket.assigns.fire
    fire = Fire.burn(fire, decay_fun)
    {:noreply, assign(socket, :fire, fire)}
  end
end
