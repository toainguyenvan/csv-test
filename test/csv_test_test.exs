defmodule CsvTestTest do
  use ExUnit.Case
  doctest CsvTest

  test "greets the world" do
    assert CsvTest.hello() == :world
  end
end
