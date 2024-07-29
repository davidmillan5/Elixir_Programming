defmodule Update do
  @moduledoc """
  This module provides a function for updating Employee data in a JSON file.

  ## Special Symbols
  - `defmodule`: Defines a new module
  - `@moduledoc`: Provides documentation for the module
  """

  alias Company.Employee

  @doc """
  Updates an existing Employee struct in the JSON file.

  ## Parameters
  - `employee`: An `%Company.Employee{}` struct with updated attributes. The employee must have an ID.
  - `filename`: String, the name of the JSON file to write to (optional, default: "employees.json")

  ## Returns
  - `:ok` if the update operation is successful
  - `{:error, term()}` if an error occurs

  ## Special Symbols
  - `@doc`: Provides documentation for the function
  - `@spec`: Specifies the function's type specification
  - `def`: Defines a public function
  - `\\\\`: Default argument separator
  - `%Employee{}`: Pattern matches an Employee struct
  - `|>`: The pipe operator

  ## Examples
      iex> employee = Company.Employee.new("Jane Doe", "Manager", id: 1)
      iex> Update.update_employee(employee)
      :ok
  """
  @spec update_employee(Employee.t(), String.t()) :: :ok | {:error, term()}
  def update_employee(%Employee{id: id} = updated_employee, filename \\ "employees.json") do
    employees = read_employees(filename)
    updated_employees =
      employees
      |> Enum.map(fn
        %Employee{id: ^id} -> updated_employee
        employee -> employee
      end)

    json_data = Jason.encode!(updated_employees, pretty: true)
    File.write(filename, json_data)
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
      iex> Update.read_employees("employees.json")
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
