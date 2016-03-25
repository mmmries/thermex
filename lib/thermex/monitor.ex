defmodule Thermex.Monitor do
  use GenServer
  require Logger
  @check_interval 500

  def start_link(sensor_file) do
    GenServer.start_link(__MODULE__, sensor_file)
  end

  def init(sensor_file) do
    {:ok, sensor_file, @check_interval}
  end

  def handle_info(:timeout, sensor_file) do
    IO.puts "time to check #{sensor_file}"
    {:noreply, sensor_file, @check_interval}
  end
  def handle_info(msg, sensor_file) do
    Logger.error("#{__MODULE__} received an unexpected message", msg)
    {:noreply, sensor_file, @check_interval}
  end
end
