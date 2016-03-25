defmodule Thermex.Monitor do
  use GenServer
  require Logger
  @check_interval 500

  def start_link(sensor_file) do
    GenServer.start_link(__MODULE__, sensor_file)
  end

  def init(sensor_file) do
    serial_number = parse_serial_number_from_filename(sensor_file)
    {:ok, %{path: sensor_file, serial: serial_number}, @check_interval}
  end

  def handle_info(:timeout, %{path: path, serial: serial}=state) do
    Logger.debug("temperature update for #{serial}: #{inspect read_temperature(path)}")
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
    lines = filename
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.take(2)

    {temperature, _} = parse_temperature(List.first(lines), List.last(lines)) 
    temperature / 1000
  end

  defp parse_temperature(first_string, second_string) do
    cond do 
      String.ends_with?(first_string, "YES") ->
        String.split(second_string, "=") 
        |> List.last 
        |> Integer.parse 
      true ->
        nil
    end
  end
end
