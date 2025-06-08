defmodule Genoblend.Genservers.GenesManager do
  use GenServer
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_opts) do
    Logger.info("GameRoomsManager started")
    {:ok, %{rooms: [], room_waiting_for_players: []}}
  end
end
