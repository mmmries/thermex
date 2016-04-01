defmodule Thermex.ParserTest do
  use ExUnit.Case, async: true
  import Thermex.Parser, only: [parse: 1]

  test "parses valid readings and returns the degrees celsius" do
    assert {:ok, temp} = parse("55 01 4b 46 7f ff 0b 10 d0 : crc=d0 YES\n55 01 4b 46 7f ff 0b 10 d0 t=21312\n")
    assert_in_delta temp, 21.312, 0.001
  end

  test "returns an error when the CRC doesn't match" do
    assert {:error, :crc_not_matched} == parse("ff ff ff ff ff ff ff ff ff : crc=c9 NO\n53 01 4b 46 7f ff 0d 10 e9 t=-62\n")
  end

  # This test covers an edge case where a sensor wire that gets unplugged
  # will read as all 0's for a period of time before the operating system
  # notices that the sensor is gone. During this time period the CRC will match
  # because the sum of 0's is always 0, but we don't want to accept these readings
  test "returns an error when the reading is all 0's" do
    assert {:error, :untrusted_reading} == parse("00 00 00 00 00 00 00 00 00 : crc=00 YES\n00 00 00 00 00 00 00 00 00 t=0\n")
  end
end
