defmodule AliceWikiTest do
  use ExUnit.Case
  doctest AliceWiki

  test "greets the world" do
    assert AliceWiki.hello() == :world
  end
end
