defmodule InventoryManager do
  defstruct inventory: [], cart: []

  # Añadir un nuevo producto al inventario
  def add_product(%InventoryManager{inventory: inventory} = manager, name, price, stock) do
    id = Enum.count(inventory) + 1
    product = %{id: id, name: name, price: price, stock: stock}
    %{manager | inventory: inventory ++ [product]}
  end

  # Listar todos los productos en el inventario
  def list_products(%InventoryManager{inventory: inventory}) do
    Enum.each(inventory, fn product ->
      IO.puts("ID: #{product.id} | Nombre: #{product.name} | Precio: $#{product.price} | Stock: #{product.stock}")
    end)
  end

  # Aumentar el stock de un producto existente
  def increase_stock(%InventoryManager{inventory: inventory} = manager, id, quantity) do
    updated_inventory = Enum.map(inventory, fn product ->
      if product.id == id do
        %{product | stock: product.stock + quantity}
      else
        product
      end
    end)

    %{manager | inventory: updated_inventory}
  end

  # Vender un producto y añadirlo al carrito
  def sell_product(%InventoryManager{inventory: inventory, cart: cart} = manager, id, quantity) do
    updated_inventory = Enum.map(inventory, fn product ->
      if product.id == id do
        if product.stock >= quantity do
          %{product | stock: product.stock - quantity}
        else
          IO.puts("Stock insuficiente para el producto: #{product.name}")
          product
        end
      else
        product
      end
    end)

    # Añadir al carrito
    new_cart =
      if Enum.any?(inventory, fn product -> product.id == id && product.stock >= quantity end) do
        cart ++ [{id, quantity}]
      else
        cart
      end

    %{manager | inventory: updated_inventory, cart: new_cart}
  end

  # Ver el carrito de compras
  def view_cart(%InventoryManager{inventory: inventory, cart: cart}) do
    total_cost =
      Enum.reduce(cart, 0.0, fn {id, quantity}, acc ->
        product = Enum.find(inventory, fn p -> p.id == id end)
        cost = product.price * quantity
        IO.puts("Producto: #{product.name} | Cantidad: #{quantity} | Costo: $#{cost}")
        acc + cost
      end)

    IO.puts("Costo total: $#{total_cost}")
  end

  # Realizar el cobro y vaciar el carrito
  def checkout(%InventoryManager{} = manager) do
    view_cart(manager)
    IO.puts("Compra realizada con éxito. El carrito se ha vaciado.")
    %{manager | cart: []}
  end

  # Función principal de ejecución
  def run do
    manager = %InventoryManager{}
    loop(manager)
  end

  # Bucle de interacción con el usuario
  defp loop(manager) do
    IO.puts("""
    Gestor de Inventario
    1. Agregar Producto
    2. Listar Productos
    3. Aumentar Stock
    4. Vender Producto
    5. Ver Carrito
    6. Checkout
    7. Salir
    """)

    IO.write("Seleccione una opción: ")
    option = IO.gets("") |> String.trim() |> String.to_integer()

    case option do
      1 ->
        IO.write("Ingrese el nombre del producto: ")
        name = IO.gets("") |> String.trim()

        IO.write("Ingrese el precio del producto: ")
        price = IO.gets("") |> String.trim() |> String.to_float()

        IO.write("Ingrese la cantidad en stock del producto: ")
        stock = IO.gets("") |> String.trim() |> String.to_integer()

        manager = add_product(manager, name, price, stock)
        loop(manager)

      2 ->
        list_products(manager)
        loop(manager)

      3 ->
        IO.write("Ingrese el ID del producto para aumentar el stock: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()

        IO.write("Ingrese la cantidad a aumentar: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()

        manager = increase_stock(manager, id, quantity)
        loop(manager)

      4 ->
        IO.write("Ingrese el ID del producto a vender: ")
        id = IO.gets("") |> String.trim() |> String.to_integer()

        IO.write("Ingrese la cantidad a vender: ")
        quantity = IO.gets("") |> String.trim() |> String.to_integer()

        manager = sell_product(manager, id, quantity)
        loop(manager)

      5 ->
        view_cart(manager)
        loop(manager)

      6 ->
        manager = checkout(manager)
        loop(manager)

      7 ->
        IO.puts("¡Adiós!")
        :ok

      _ ->
        IO.puts("Opción no válida.")
        loop(manager)
    end
  end
end

# Ejecutar el gestor de inventario
InventoryManager.run()
