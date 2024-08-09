defmodule CounterGenserverTest do
  use ExUnit.Case
  doctest CounterGenserver

  test "greets the world" do
    assert CounterGenserver.hello() == :world
  end
end
