defmodule BinToInt do
  def from_little_to_big(to_convert) do
    from_little_to_big(to_convert, <<>>)
  end

  def from_little_to_big(<<>>, result) do
    result
  end

  def from_little_to_big(<<little :: 64-little, rest :: binary>>, result) do
    from_little_to_big(rest, result <> <<little :: 64-big>>)
  end

  def from_big_to_little(to_convert) do
    from_big_to_little(to_convert, <<>>)
  end

  def from_big_to_little(<<>>, result) do
    result
  end

  def from_big_to_little(<<big :: 64-big, rest :: binary>>, result) do
    from_big_to_little(rest, result <> <<big :: 64-little>>)
  end
end
