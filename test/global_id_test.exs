defmodule GlobalIdTest do
  use ExUnit.Case
  use Bitwise

  setup do
    GlobalId.init()
  end

  test "global_id_under_rate_limit" do
    ids =
      0..10
      |> Enum.map(fn _ ->
        Process.sleep(1 <<< 10)

        0..((1 <<< 18) - 1)
        |> Enum.map(fn _ ->
          GlobalId.get_id()
        end)
      end)
      |> Enum.concat()

    unique_ids =
      ids
      |> Enum.uniq()

    assert length(ids) === length(unique_ids)
  end

  test "global_id_over_rate_limit" do
    ids =
      0..10
      |> Enum.map(fn _ ->
        Process.sleep(1 <<< 10)

        0..(1 <<< 18)
        |> Enum.map(fn _ ->
          GlobalId.get_id()
        end)
      end)
      |> Enum.concat()

    unique_ids =
      ids
      |> Enum.uniq()

    assert length(ids) > length(unique_ids)
  end
end
