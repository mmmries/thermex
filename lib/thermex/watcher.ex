defmodule Thermex.Watcher do
  use GenServer
  require Logger

  def start_link(options \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  def init(nil) do
    :timer.send_interval(1_000, :check_for_devices)
    {:ok, nil}
  end

  def handle_info(:check_for_devices, state) do
    Logger.debug "I need to check for devices"
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.error "#{__MODULE__} received unexpected message", msg
    {:noreply, state}
  end
end
