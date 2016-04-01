defmodule Thermex.Monitor do
  use GenServer
  require Logger
  @check_interval 500
  @pg2_group :thermex_measurements

  def start_link(sensor_file) do
    GenServer.start_link(__MODULE__, sensor_file)
  end

  def init(sensor_file) do
    serial_number = parse_serial_number_from_filename(sensor_file)
    :pg2.create(@pg2_group)
    {:ok, %{path: sensor_file, serial: serial_number}, @check_interval}
  end

  def handle_info(:timeout, %{path: path, serial: serial}=state) do
    case read_temperature(path) do
      {:ok, temperature} ->
        publish_to_group({serial, temperature, :os.system_time(:milli_seconds)})
      {:error, error} ->
        publish_to_group({serial, {:error, error}, :os.system_time(:milli_seconds)})
    end
    {:noreply, state, @check_interval}
  end
  def handle_info(msg, state) do
    Logger.error("#{__MODULE__} received an unexpected message", msg)
    {:noreply, state, @check_interval}
  end

  defp parse_serial_number_from_filename(sensor_file) do
    "28-"<>serial = sensor_file
                    |> Path.dirname
                    |> Path.basename
    serial
  end

  defp read_temperature(filename) do
    filename
    |> File.read!
    |> Thermex.Parser.parse
  end

  def publish_to_group(payload) do
    for pid <- :pg2.get_members(@pg2_group) do
      send(pid, payload)
    end
  end
end
