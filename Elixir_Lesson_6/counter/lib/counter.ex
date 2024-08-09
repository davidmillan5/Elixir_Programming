defmodule Counter do
  @moduledoc """
  A module for demonstrating concurrent processes in Elixir.

  The `Counter` module starts two processes: a counter process and a
  controller process. The counter process increments a counter every
  second and sends the updated value to the controller process, which
  then receives and displays the counter value.
  """

  @doc """
  Initializes the counter and controller processes.

  ## Examples

      iex> Counter.initialize()
      # Starts the counter and controller processes.
  """
  def initialize do
    # Spawn the controller process
    controller_pid = spawn(fn -> controller_process() end)
    # Spawn the counter process and pass the controller process PID
    spawn(fn -> counter_process(0, controller_pid) end)
  end

  @doc """
  The counter process function.

  Increments the counter every second and sends the updated value to
  the controller process.

  ## Parameters

    - `count`: The current count value.
    - `controller_pid`: The PID of the controller process.

  ## Examples

      iex> Counter.counter_process(0, self())
      # Increments the counter and sends the value to the controller process.
  """
  defp counter_process(count, controller_pid) do
    # Increment the counter
    new_count = count + 1

    # Send the new counter value to the controller process
    send(controller_pid, {:counter_value, new_count})

    # Wait for 1 second
    :timer.sleep(1000)

    # Recursively call the counter_process function with the new counter value
    counter_process(new_count, controller_pid)
  end

  @doc """
  The controller process function.

  Receives and displays the counter value sent by the counter process.

  ## Examples

      iex> Counter.controller_process()
      # Receives and displays counter values
  """
  defp controller_process do
    # Receive messages in a loop
    receive do
      {:counter_value, value} ->
        # Display the received counter value
        IO.puts("Counter value: #{value}")

        # Continue receiving messages
        controller_process()
    end
  end
end
