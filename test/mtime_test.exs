defmodule Thermex.MtimeTest do
  use ExUnit.Case, async: true
  import Thermex.Mtime, only: [check: 1]

  test "returns the posix mtime of a filepath" do
    assert {:ok, posix} = check(Path.join(__DIR__, "mtime_test.exs"))
    assert is_integer(posix)
  end

  test "returns an error message for invalid filepaths" do
    assert {:error, :enoent} == check("/fake/file.path")
  end
end
