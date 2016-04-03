[![Build Status](https://travis-ci.org/mmmries/thermex.svg?branch=master)](https://travis-ci.org/mmmries/thermex)
[![Hex Version](http://img.shields.io/hexpm/v/thermex.svg)](https://hex.pm/packages/thermex)

# Thermex

An OTP application that watches for temperature sensors and monitors their readings.

I use thermex to monitor temperature readings from [DS18B20](https://datasheets.maximintegrated.com/en/ds/DS18B20.pdf) sensors connected to a [raspberry pi](https://www.raspberrypi.org/).
These sensors use the 1-wire protocol which is supported by modern linux kernels.

## Usage

Add `thermex` as a hex dependency of your project and add it to the list of applications that needed to be started (see Installation instructions below).

Now in order ot receive the measurements you just need to subscriber to the [pg2](http://erlang.org/doc/man/pg2.html) group and start receiving measurements.

```elixir
:pg2.create(:thermex_measurements)
:pg2.join(:thermex_measurements, self())
receive do
  {serial_number, {:error, reason}, timestamp_milliseconds} ->
    # Deal with and error
  {serial_number, degrees_celsius, timestamp_milliseconds} ->
    # Do something with a successful temperature measurement
end
```

* `serial_number` is a string (binary)
* `timestamp_milliseconds` is an integer representing the posix time in milliseconds
* `degrees_celsius` is a float representing the number of degrees celsius

## Example

This is a sample GenServer that just accumulates measurements.

```elixir
defmodule Reporter do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(nil) do
    :pg2.create(:thermex_measurements)
    :pg2.join(:thermex_measurements, self())
    :timer.send_interval(5_000, :report_measurements)
    {:ok, %{measurements: []}}
  end

  def handle_info({_serial, {:error, _reason}, _timestamp}, state) do
    # ignore errors
    {:noreply, state}
  end

  def handle_info({_, _, _}=measurement, %{measurements: measurements}=state) do
    {:noreply, %{state | measurements: [measurement | measurements]}}
  end
end
```

## Sensors

When plugged in, the operating system will see the sensor and create a directory in `/sys/bus/w1/devices`.
The directory will be named after the serial number of the sensor.
Inside that directory there is a `w1_slave` file which gets checked and parsed by thermex.
Data can get corrupted on the wire in which case an error will be reported instead of a measurement.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add thermex to your list of dependencies in `mix.exs`:

        def deps do
          [{:thermex, "~> 0.1.0"}]
        end

  2. Ensure thermex is started before your application:

        def application do
          [applications: [:thermex]]
        end

