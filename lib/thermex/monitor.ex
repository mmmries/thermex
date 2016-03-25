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
    Logger.debug("temperature update: #{inspect read_temperature(sensor_file)}")
    {:noreply, sensor_file, @check_interval}
  end
  def handle_info(msg, sensor_file) do
    Logger.error("#{__MODULE__} received an unexpected message", msg)
    {:noreply, sensor_file, @check_interval}
  end

  defp read_temperature(filename) do
    lines = filename
    |> File.stream!
    |> Stream.map(&String.strip/1)
    |> Enum.take(2)

    {temperature, _} = parse_temperature(List.first(lines), List.last(lines)) 
    {filename, temperature / 1000 }
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
