defmodule SalesTaxes do
  def read_orders(filename) do
    {:ok, file} = File.open(filename, [:read, :utf8])
    headers = _build_headers(IO.read(file, :line))
    orders = Enum.map(IO.stream(file, :line), &(_build_order(&1, headers)))
    File.close(file)

    orders
    |> _calculate_order
  end

  defp _calculate_order(orders) do
    Enum.each(orders, fn row -> 
      # tax = if (row[:Product] === "book" || row[:Product] === "food" || row[:Product] === "medical"), do: 0.1, else: 0
      # IO.inspect tax
      tax = _get_product_type(row[:Product])
      # IO.puts "Quantity, Product, Price"
      price = row[:Price]*(1 + tax)
      # actual_price = Float.round(Float.floor(price, 3), 2)

      # Rounding as the rule (rounded up nearest 0.05)
      actual_price = Float.round(price, 2)

      # Get the second decimal number
      second_decimal = rem(round(actual_price*100), 10)

      rounded_price = if (second_decimal >= 5 || second_decimal == 0), do: actual_price, else: _rounding_result(actual_price)
      IO.puts("1, #{row[:Product]}, #{Float.round(rounded_price, 2)}")
    end)
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
      |> String.split(",")
  end

end