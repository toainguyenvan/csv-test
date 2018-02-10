defmodule SalesTaxesTest do
	use ExUnit.Case

	doctest SalesTaxes
  
	test "Order Book" do
		input = [Quantity: 1, Product: "book", Price: 14.99]
		expeted = %{sale_record: [Quantity: 1, Product: "book", Price: 14.99], order_taxes: 0, order_price: 14.99}
		
		assert SalesTaxes.calculate(input) == expeted
	end

	test "Order Imported Book" do
		input = [Quantity: 1, Product: "imported book", Price: 10.0]
		expeted = %{sale_record: [Quantity: 1, Product: "imported book", Price: 10.5], order_taxes: 0.5, order_price: 10.5}
		
		assert SalesTaxes.calculate(input) == expeted
	end

	test "Order perfume" do
		input = [Quantity: 1, Product: "perfume", Price: 10.0]
		expeted = %{sale_record: [Quantity: 1, Product: "perfume", Price: 11.0], order_taxes: 1.0, order_price: 11}
		
		assert SalesTaxes.calculate(input) == expeted
	end

	test "Order imported perfume (Rounded nearest 0.05)" do
		input = [Quantity: 1, Product: "imported perfume", Price: 47.5]
		expeted = %{sale_record: [Quantity: 1, Product: "imported perfume", Price: 54.65], order_taxes: 7.15, order_price: 54.65}
		
		assert SalesTaxes.calculate(input) == expeted
	end

	test "Order imported music CD (Rounded normal)" do
		input = [Quantity: 1, Product: "imported perfume", Price: 27.99]
		expeted = %{sale_record: [Quantity: 1, Product: "imported perfume", Price: 32.19], order_taxes: 4.2, order_price: 32.19}
		
		assert SalesTaxes.calculate(input) == expeted
	end
  end
  