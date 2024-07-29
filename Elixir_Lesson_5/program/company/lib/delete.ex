defmodule Delete do
  @moduledoc """
  This module provides a function for deleting Employee data from a JSON file.

  ## Special Symbols
  - `defmodule`: Defines a new module
  - `@moduledoc`: Provides documentation for the module
  """

  alias Company.Employee

  @doc """
  Deletes an Employee struct from the JSON file by ID.

  ## Parameters
  - `id`: Integer, the ID of the employee to be deleted
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the delete operation is successful
  - `{:error, term()}` if an error occurs

  ## Special Symbols
  - `@doc`: Provides documentation for the function
  - `@spec`: Specifies the function's type specification
  - `def`: Defines a public function
  - `\\\\`: Default argument separator
  - `|>`: The pipe operator

  ## Examples
      iex> Delete.delete_employee(1)
      :ok
  """
  @spec delete_employee(integer(), String.t()) :: :ok | {:error, term()}
  def delete_employee(id, filename \\ "employees.json") do
    employees = read_employees(filename)
    updated_employees =
      Enum.reject(employees, &(&1.id == id))

    json_data = Jason.encode!(updated_employees, pretty: true)
    case File.write(filename, json_data) do
      :ok -> :ok
      error -> {:error, error}
    end
  end

  @doc """
  Reads existing employees from the JSON file.

  ## Parameters
  - `filename`: String, the name of the JSON file to read from

  ## Returns
  - List of Employee structs

  ## Special Symbols
  - `@doc`: Provides documentation for the function
  - `@spec`: Specifies the function's type specification
  - `defp`: Defines a private function
  - `case`: Pattern matches on the result of an expression

  ## Examples
      iex> Delete.read_employees("employees.json")
      [%Company.Employee{...}, ...]
  """
  @spec read_employees(String.t()) :: [Employee.t()]
  defp read_employees(filename) do
    case File.read(filename) do
      {:ok, contents} ->
        Jason.decode!(contents, keys: :atoms)
        |> Enum.map(&struct(Employee, &1))
      {:error, :enoent} -> []
    end
  end
end
