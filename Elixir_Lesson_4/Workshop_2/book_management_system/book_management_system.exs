# Define the Book module
defmodule Book do
  defstruct [:title, :isbn, :author, :quantity, :available, :borrowed, :publisher, :publication_date, :language]

  def new(title, isbn, author, quantity, publisher, publication_date, language) do
    %Book{
      title: title,
      isbn: isbn,
      author: author,
      quantity: quantity,
      available: quantity > 0,
      borrowed: 0,
      publisher: publisher,
      publication_date: publication_date,
      language: language
    }
  end

  def display(%Book{
        title: title,
        isbn: isbn,
        author: author,
        quantity: quantity,
        borrowed: borrowed,
        publisher: publisher,
        publication_date: publication_date,
        language: language
      }) do
    """
    Title: #{title},
    ISBN: #{isbn},
    Author: #{author},
    Quantity: #{quantity},
    Borrowed: #{borrowed},
    Publisher: #{publisher},
    Publication Date: #{publication_date},
    Language: #{language}
    """
  end
end

# Define the User module
defmodule User do
  defstruct [:id, :name, :borrowed_books]

  def new(id, name) do
    %User{id: id, name: name, borrowed_books: []}
  end
end

# Define the Library module
defmodule Library do
  defstruct [:books, :users]

  def new do
    %Library{books: [], users: []}
  end

  def add_book(%Library{books: books} = library, book) do
    updated_books = [book | books]
    %Library{library | books: updated_books}
  end

  def list_books(%Library{books: books}) do
    books
  end

  def check_availability(%Library{books: books}, isbn) do
    case Enum.find(books, fn %Book{isbn: b_isbn} -> b_isbn == isbn end) do
      %Book{available: true} -> {:ok, true}
      %Book{} -> {:ok, false}
      nil -> {:error, :not_found}
    end
  end

  def register_user(%Library{users: users} = library, user) do
    updated_users = [user | users]
    %Library{library | users: updated_users}
  end

  def list_users(%Library{users: users}) do
    users
  end

  def borrow_book(%Library{books: books, users: users} = library, user_id, isbn) do
    {book, remaining_books} = List.pop_at(books, Enum.find_index(books, fn %Book{isbn: b_isbn} -> b_isbn == isbn end))
    case book do
      %Book{available: true, quantity: qty} = book ->
        updated_book = %Book{book | quantity: qty - 1, borrowed: book.borrowed + 1, available: qty - 1 > 0}
        updated_user = update_user_borrowed_books(users, user_id, isbn)
        updated_library = %Library{library | books: [updated_book | remaining_books], users: updated_user}
        {:ok, updated_library}

      _ -> {:error, :not_available, library}
    end
  end

  defp update_user_borrowed_books(users, user_id, isbn) do
    Enum.map(users, fn
      %User{id: ^user_id} = user ->
        %User{user | borrowed_books: [isbn | user.borrowed_books]}

      user ->
        user
    end)
  end

  def return_book(%Library{books: books, users: users} = library, user_id, isbn) do
    {book, remaining_books} = List.pop_at(books, Enum.find_index(books, fn %Book{isbn: b_isbn} -> b_isbn == isbn end))
    case book do
      %Book{borrowed: borrowed, quantity: qty} = book ->
        updated_book = %Book{book | quantity: qty + 1, borrowed: borrowed - 1, available: true}
        updated_user = update_user_returned_books(users, user_id, isbn)
        updated_library = %Library{library | books: [updated_book | remaining_books], users: updated_user}
        {:ok, updated_library}

      _ -> {:error, :not_found, library}
    end
  end

  defp update_user_returned_books(users, user_id, isbn) do
    Enum.map(users, fn
      %User{id: ^user_id} = user ->
        %User{user | borrowed_books: List.delete(user.borrowed_books, isbn)}

      user ->
        user
    end)
  end

  def list_loaned_books(%Library{users: users, books: books}, user_id) do
    case Enum.find(users, fn %User{id: u_id} -> u_id == user_id end) do
      %User{borrowed_books: borrowed_books} ->
        Enum.filter(books, fn %Book{isbn: b_isbn} -> b_isbn in borrowed_books end)

      _ -> []
    end
  end
end

# Example Usage
defmodule Main do
  def run do
    # Create a new library
    library = Library.new()

    # Create some books
    book1 = Book.new("Elixir in Action", "9781617295027", "Sasa Juric", 5, "Manning", ~D[2021-01-01], "English")
    book2 = Book.new("Programming Elixir", "9781680506620", "Dave Thomas", 3, "Pragmatic Bookshelf", ~D[2019-11-01], "English")

    # Add books to the library
    library = Library.add_book(library, book1)
    library = Library.add_book(library, book2)

    # Create a user
    user = User.new("user1", "Alice")

    # Register the user
    library = Library.register_user(library, user)

    # Check availability of a book
    {:ok, true} = Library.check_availability(library, "9781617295027")

    # Borrow a book
    {:ok, library} = Library.borrow_book(library, "user1", "9781617295027")

    # List all borrowed books for a user
    borrowed_books = Library.list_loaned_books(library, "user1")
    IO.inspect(borrowed_books)

    # Return a book
    {:ok, library} = Library.return_book(library, "user1", "9781617295027")

    # List all books after returning
    books = Library.list_books(library)
    IO.inspect(books)
  end
end

# Run the example
Main.run()
