defmodule Workshop1Test do
  use ExUnit.Case
  doctest Workshop1

  test "greets the world" do
    assert Workshop1.hello() == :world
  end
end
