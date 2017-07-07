defmodule ChatexClient.InputReaderTest do
  use ExUnit.Case
  doctest ChatexClient.InputReader

  test "get_credentials reads username and key_phrase from App env" do
    assert {"username", "pass"} == ChatexClient.InputReader.get_credentials
  end
end
