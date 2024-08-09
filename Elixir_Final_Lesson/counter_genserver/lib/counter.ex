defmodule Counter do
  use GenServer
  def initialize do
    # Start the controller process
    {:ok, controller_pid} = GenServer.start_link(__MODULE__, {:controller, self()}, name: :controller)

    # Start the counter process
    {:ok, counter_pid} = GenServer.start_link(__MODULE__, {:counter, controller_pid}, name: :counter)

    # Start the counting process
    GenServer.cast(:counter, :start_counting)
  end

  # Initialize the server state
  def init({:controller, main_process}) do
    # Initialize the state for the controller
    {:ok, %{role: :controller, main_process: main_process}}
  end

  def init({:counter, controller_pid}) do
    # Initialize the state for the counter
    {:ok, %{role: :counter, controller_pid: controller_pid, count: 0}}
  end

  # Handle cast for the counter process
  def handle_cast(:start_counting, %{role: :counter} = state) do
    # Schedule the increment action every second
    Process.send_after(self(), :increment, 1000)
    {:noreply, state}
  end

  # Handle the increment message for the counter
  def handle_info(:increment, %{role: :counter, controller_pid: controller_pid, count: count} = state) do
    # Increment the counter
    new_count = count + 1

    # Send the updated counter value to the controller
    GenServer.cast(controller_pid, {:update_count, new_count})

    # Schedule the next increment
    Process.send_after(self(), :increment, 1000)

    # Update the state with the new count
    {:noreply, %{state | count: new_count}}
  end

  # Handle cast for the controller process
  def handle_cast({:update_count, count}, %{role: :controller} = state) do
    # Display the counter value
    IO.puts("Counter Value: #{count}")
    {:noreply, state}
  end
end

Counter.initialize()
