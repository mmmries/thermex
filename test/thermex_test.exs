defmodule ThermexTest do
  use ExUnit.Case
  doctest Thermex

  test "receiving measurements" do
    :pg2.create(:thermex_measurements)
    :pg2.join(:thermex_measurements, self)
    assert_receive {"a123", temperature, timestamp}, 5_000
    assert_in_delta temperature, 21.312, 0.001
    assert_in_delta timestamp, :os.system_time(:milli_seconds), 10
  end
end
