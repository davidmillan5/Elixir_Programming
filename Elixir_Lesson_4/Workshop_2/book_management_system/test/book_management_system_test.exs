defmodule BookManagementSystemTest do
  use ExUnit.Case
  doctest BookManagementSystem

  test "greets the world" do
    assert BookManagementSystem.hello() == :world
  end
end
