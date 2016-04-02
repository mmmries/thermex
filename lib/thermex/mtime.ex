defmodule Thermex.Mtime do
  require Record
  Record.defrecord :file_info, Record.extract(:file_info, from_lib: "kernel/include/file.hrl")

  def check(filepath) do
    with {:ok, file_info} <- :file.read_file_info(filepath, time: :posix),
    do: {:ok, file_info(file_info, :mtime)}
  end
end
