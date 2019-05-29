defmodule GlobalId do
  @moduledoc """
  GlobalId module contains an implementation of a guaranteed globally unique id system.     
  """

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
    # First 10 bits represent node id. Next 46 bits represent epoch in milliseconds, 
    # which is sufficient for approximately 2231 years starting from 1970. Remaining
    # 8 bits represent a counter, which wraps at 255, allowing up to 255,000 requests
    # per second. This will generate unique ids assuming that there is at least 1
    # millisecond between last get_id before the restart and first get_id after the
    # restart.

    <<
      node_id()::size(10),
      timestamp()::size(46),
      get_counter()::size(8)
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

  @spec get_counter() :: non_neg_integer
  def get_counter do
    # :ets.update_counter provides an efficient way to update one or more 
    # counters, without the trouble of having to look up an object, update
    # the object by incrementing an element, and insert the resulting object
    # into the table again. The operation is guaranteed to be atomic and 
    # isolated.

    :ets.update_counter(
      :counter,
      :counter,
      # increment by 1 at tuple position 2 and wrap to 0 after 255
      {2, 1, 255, 0},
      # initial tuple
      {:counter, -1}
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
  @spec timestamp() :: non_neg_integer
  def timestamp do
    {mega_secs, secs, micro_secs} = :os.timestamp()
    mega_secs * 1_000_000_000 + secs * 1_000 + trunc(micro_secs / 1_000)
  end
end
