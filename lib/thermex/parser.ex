defmodule Thermex.Parser do
  def parse(reading) do
    reading
    |> String.strip
    |> String.split("\n")
    |> parse_temperature
  end

  defp parse_temperature(["00 00 00 00 00 00 00 00 00 : crc=00"<>_, _line2]) do
    {:error, :untrusted_reading}
  end
  defp parse_temperature([<<_hex :: binary-size(36), "YES">>, line2]) do
    [_,temperature_str] = String.split(line2, "=")
    {temperature_int, ""} = Integer.parse(temperature_str)
    {:ok, temperature_int / 1000}
  end
  defp parse_temperature([<<_hex :: binary-size(36), "NO">>, _line2]) do
    {:error, :crc_not_matched}
  end
  defp parse_temperature([_,_]) do
    {:error, :unknown}
  end
end
