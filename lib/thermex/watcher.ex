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
    Logger.debug "I need to check for devices at #{base_path}"
    Logger.debug "okay, lets look at #{inspect look_for_sensor_files}"
    {:noreply, state}
  end
  def handle_info(msg, state) do
    Logger.error "#{__MODULE__} received unexpected message", msg
    {:noreply, state}
  end

  defp base_path do
    Application.get_env(:thermex, :base_path)
  end
  defp look_for_sensor_files do
    with {:ok, dirs} <- File.ls(base_path),
                dirs <- Enum.filter(dirs, &( String.starts_with?(&1, "28-") )),
    do: Enum.map(dirs, fn(dir)-> Path.join([base_path, dir, "w1_slave"]) end)
  end
end
