defmodule FlowersTest do
  use ExUnit.Case

  test "it can parse variables from left side of equation" do
    assert Flowers.parse_variables("🌺+🌺-🌼") == {["🌺", "🌺", "🌼"], ["+", "+", "-"]}
  end

  test "🌺 == 20" do
    left = "🌺+🌺+🌺"
    right = 60
    assert Flowers.solve_for_variable(left, right) == {"🌺", 20}
  end

  test "it adds known variable values to a map of knowns" do
    left = "🌺+🌺+🌺"
    right = 60
    knowns = Flowers.solve(%{}, left, right)
    assert knowns == %{"🌺" => 20}
  end

  test "it uses knowns to solve current equation" do
    left = "🌺+🌸+🌸"
    right = 30
    knowns = %{"🌺" => 20}
    new_knowns = Flowers.solve(knowns, left, right)
    assert new_knowns == %{"🌺" => 20, "🌸" => 5}
  end

  test "it can solve the puzzle" do
    eq0 = {"🌺+🌺+🌺", 60}
    eq1 = {"🌺+🌸+🌸", 30}
    eq2 = {"🌸-🌻-🌻", 3}

    all_knowns = [eq0, eq1, eq2]
                 |> Enum.reduce(%{}, fn({left, right}, knowns) ->
                   IO.puts("Finding knowns for #{left} = #{right}")
                   new_knowns = Flowers.solve(knowns, left, right)
                   IO.inspect(new_knowns)
                   new_knowns
                 end)

    final_left = "🌻+🌺+🌸"
    answer = Flowers.solve_final(all_knowns, final_left)
    assert answer == 26
    IO.puts("Answer to #{final_left} = #{answer}")
  end
end
