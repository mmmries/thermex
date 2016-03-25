defmodule Thermex.MonitorSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def ensure_monitor_running_for(sensor_file) do
    child = worker(Thermex.Monitor, [sensor_file], restart: :transient, id: String.to_atom(sensor_file))
    Supervisor.start_child(__MODULE__, child)
  end

  def init([]) do
    supervise([], strategy: :one_for_one)
  end
end
