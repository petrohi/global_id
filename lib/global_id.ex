defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.     
  """

  use Bitwise

  @doc """
  64 bit non negative integer output   
  """
  @spec get_id() :: non_neg_integer
  def get_id do
    <<id::size(64)>> = get_id_binary()
    id
  end

  @doc """
  64 bit binary output   
  """
  @spec get_id_binary() :: binary
  def get_id_binary do
    # First 10 bits represent node id. Next 36 bits represent monotonic timestamp
    # with 2 ^ 10 = 1024 milliseconds resolution, which is sufficient for approximately
    # 2231 years starting from 1970. Remaining 18 bits represent a counter. Assuming
    # the maximum of 128,000 requests per second the maximum negative timestamp correction
    # is 2 ^ 10 = 1024 milliseconds. There must be > 2 ^ 11 = 2048 milliseconds between
    # the last get_id before the restart and the first get_id after the restart.

    <<
      node_id()::size(10),
      timestamp(10) |> monotonic()::size(36),
      get_counter(18)::size(18)
    >>
  end

  @doc """
  Initialize global unique id system   
  """
  @spec init() :: :ok
  def init do
    :counter =
      :ets.new(
        :counter,
        [
          :set,
          :public,
          :named_table
        ]
      )

    :ok
  end

  @spec get_counter(non_neg_integer) :: non_neg_integer
  def get_counter(res) do
    :ets.update_counter(
      :counter,
      :counter,
      # increment by 1 at tuple position 2 and wrap to 0 after 255
      {2, 1, (1 <<< res) - 1, 0},
      # initial tuple
      {:counter, -1}
    )
  end

  @spec monotonic(non_neg_integer) :: non_neg_integer
  def monotonic(value) do
    -:ets.update_counter(
      :counter,
      :monotonic,
      # set if new > current (-current > -new)
      {2, 0, -value, -value},
      # initial tuple
      {:monotonic, -value}
    )
  end

  @doc """
  Returns your node id as an integer.
  It will be greater than or equal to 0 and less than or equal to 1023.
  It is guaranteed to be globally unique. 
  """
  @spec node_id() :: non_neg_integer
  def node_id do
    1023
  end

  @doc """
  Returns timestamp since the epoch in milliseconds. 
  """
  @spec timestamp(non_neg_integer) :: non_neg_integer
  def timestamp(res) do
    {mega_secs, secs, micro_secs} = :os.timestamp()
    (mega_secs * 1_000_000_000 + secs * 1_000 + trunc(micro_secs / 1_000)) >>> res
  end
end
