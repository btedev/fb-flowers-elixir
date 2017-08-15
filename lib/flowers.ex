defmodule Flowers do
  @moduledoc """
  Solves FB puzzle
  """

  def solve_final(knowns, left) do
    {vars, _ops} = parse_variables(left)

    vars
    |> Enum.reduce(0, fn(var, acc) ->
      val = Map.fetch!(knowns, var)
      acc + val
    end)
  end

  def solve_for_variable(vars, ops, right) when is_list(vars) do
    case Enum.uniq(vars) |> Enum.count do
      1 ->
        var = Enum.at(vars, 0)
        op = Enum.at(ops, 0)

        val = case op == "+" do
          true -> div(right, Enum.count(vars))
          false -> div(right, Enum.count(vars)) * -1
        end

        {var, val}

      _ -> :error
    end
  end

  def solve_for_variable(left, right) do
    {vars, ops} = parse_variables(left)
    solve_for_variable(vars, ops, right)
  end

  @doc """
  Parse left side of equation into a tuple
  containing a list of variables and a list of operands.
  "a+b-c" becomes {["a","b","c"], ["+","+","-"]}
  Note: first variable is assumed to be a + (not overengineering to fit hypotheticals).
  """
  def parse_variables(string) do
    {vars, ops} = String.graphemes(string)
                  |> Enum.with_index
                  |> Enum.reduce({[], ["+"]}, fn({grapheme, idx}, {v_list, o_list}) ->
                    case rem(idx ,2) do
                      0 -> {[grapheme | v_list], o_list}
                      _ -> {v_list, [grapheme | o_list]}
                    end
                  end)

    {Enum.reverse(vars), Enum.reverse(ops)}
  end

  @doc """
  Solves equation when some knowns are known.
  """
  def solve(knowns, left, right) do
    {vars, ops}                    = parse_variables(left)
    subbed_vars                    = substitute_knowns(vars, knowns)
    {new_vars, new_ops, new_right} = simplify(subbed_vars, ops, right)
    {new_known, new_val}           = solve_for_variable(new_vars, new_ops, new_right)
    Map.put(knowns, new_known, new_val)
  end

  @doc """
  Replaces variables with integers by lookup in knowns map.
  """
  def substitute_knowns(vars, knowns) do
    vars
    |> Enum.map(fn(var) ->
      case Map.fetch(knowns, var) do
        {:ok, val} -> val
        :error -> var
      end
    end)
  end

  @doc """
  Refactor both sides of the equation by adding integers
  from left side to right.
  """
  def simplify(vars, ops, right) do
    {tmp_vars, new_right} = vars
                            |> Enum.with_index
                            |> Enum.map_reduce(right, fn({var, idx}, acc) ->
                              case Kernel.is_integer(var) do
                                true ->
                                  op = Enum.at(ops, idx)

                                  new_acc = case op do
                                  "+" -> acc - var
                                  "-" -> acc + var
                                  end

                                  {nil, new_acc}

                                  false -> {var, acc}
                              end
                            end)

    # Remove nil variables and corresponding operands.
    {new_vars, new_ops} = tmp_vars
     |> Enum.with_index
     |> Enum.reduce({[], []}, fn({var, idx}, {var_list, op_list}) ->
        case var == nil do
          true -> {var_list, op_list}
          false -> {[var | var_list], [Enum.at(ops, idx) | op_list]}
        end
     end)

     {Enum.reverse(new_vars), Enum.reverse(new_ops), new_right}
  end
end
