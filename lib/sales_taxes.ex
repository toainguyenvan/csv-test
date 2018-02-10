defmodule SalesTaxes do
  def read_orders(filename) do
    {:ok, file} = File.open(filename, [:read, :utf8])
    headers = _build_headers(IO.read(file, :line))
    orders = Enum.map(IO.stream(file, :line), &(_build_order(&1, headers)))
    File.close(file)

    orders
    |> calculate_orders
  end

  def calculate_orders(orders) do
    IO.puts "## OUTPUT:\nQuantity, Product, Price"
    Enum.each(orders, fn row -> 
      row
      |> calculate
      |> _display
    end)

    # Display the Total Sale and Taxes
    _sale_summary(orders)
  end

  def calculate(order) do
    tax = _get_product_type(order[:Product])
    price = order[:Price]*(1 + tax)

    # Rounding as the rule (rounded up nearest 0.05)
    actual_price = Float.round(price, 2)

    # Get the second decimal number
    second_decimal = rem(round(actual_price*100), 10)

    rounded_price = if (second_decimal >= 5 || second_decimal == 0), do: actual_price, else: _rounding_result(actual_price)
    rounded_price = Float.round(rounded_price, 2)

    # Caculate the sale tax and order price
    order_taxes = Float.round((rounded_price - order[:Price]), 2)*order[:Quantity]
    order_price = order[:Quantity]*rounded_price

    map = %{sale_record: [Quantity: order[:Quantity], Product: order[:Product], Price: rounded_price], order_taxes: order_taxes, order_price: order_price}
  end

  defp _display(map) do
    map
    IO.puts ("#{map.sale_record[:Quantity]}, #{map.sale_record[:Product]}, #{map.sale_record[:Price]}")
    # IO.puts ("#{map.order_taxes}\n#{map.order_price}")
  end

  defp _sale_summary(orders)  do
    orders
    |> Enum.map(&(calculate(&1)))
    |> Enum.map(fn order -> %{
      price: order.order_price,
      sale_taxes: order.order_taxes
    } end)

    # Calculate the Total Sale, Total Taxes
    |> Enum.reduce(%{price: 0, tax: 0}, fn %{price: p, sale_taxes: s}, %{price: sum_price, tax: sum_sale_taxes} -> %{price: p + sum_price, tax: s + sum_sale_taxes} end)
    |> _show_summary
  end

  defp _show_summary(result) do
    IO.puts "SALES TAXES: #{result.tax}\nTOTAL: #{result.price}"
  end

  defp _rounding_result(price) do
    first_decimal = rem(round(price*10), 10)
    integer_price = round(Float.floor(price))
    rounded_price = integer_price + first_decimal/10 + 0.05
  end

  defp _get_product_type(name) do
    tax = 0.00
    tax = if (name =~ "book" || name =~ "pill" || name =~ "chocolate"), do: 0.00, else: 0.10
    tax = tax + if (name =~ "imported"), do: 0.05, else: 0.00
    tax
  end

  defp _build_order(line, headers) do
    line
      |> _get_parts
      |> _cast_values(headers)
  end

  defp _build_headers(line) do
    line
      |> _get_parts
      |> Enum.map(&(String.to_atom(&1)))
  end

  defp _cast_values(values, types) do
    values
      |> Enum.zip(types)
      |> Enum.map(&(_cast_value(&1)))
  end

  defp _cast_value({value, :Quantity}), do: {:Quantity, String.to_integer(value)}
  defp _cast_value({value, :Product}), do: {:Product, value}
  defp _cast_value({value, :Price}), do: {:Price, String.to_float(value)}

  defp _get_parts(line) do
    line
      |> String.strip
      |> String.split(", ")
  end

end