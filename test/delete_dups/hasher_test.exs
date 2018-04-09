defmodule DeleteDups.HasherTest do
  use ExUnit.Case
  doctest DeleteDups.Hasher
  import DeleteDups.Hasher

  @helpers_path Path.absname("./test/support")

  test "returns same hash for same file" do
    assert hash("#{@helpers_path}/tests_helper.txt") == hash("#{@helpers_path}/tests_helper (same content).txt")
  end

  test "returns different hash for different files" do
    assert hash("#{@helpers_path}/tests_helper.txt") != hash("#{@helpers_path}/tests_helper (different content).txt")
  end
end
