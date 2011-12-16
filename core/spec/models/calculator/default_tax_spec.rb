require 'spec_helper'

describe Spree::Calculator::DefaultTax do
  let!(:tax_category) { Factory(:tax_category, :tax_rates => []) }
  let!(:rate) { mock_model(Spree::TaxRate, :tax_category => tax_category, :amount => 0.05) }
  let!(:calculator) { Spree::Calculator::DefaultTax.new(:calculable => rate) }
  let!(:order) { Factory(:order) }
  let!(:product_1) { Factory(:product) }
  let!(:product_2) { Factory(:product) }
  let!(:line_item_1) { stub_model(Spree::LineItem, :product => product_1, :price => 10) }
  let!(:line_item_2) { stub_model(Spree::LineItem, :product => product_2, :price => 5) }

  context "#compute" do
    context "when given an order" do
      before do
        order.stub :line_items => [line_item_1, line_item_2]
      end

      context "when no line items match the tax category" do
        before do
          product_1.tax_category = nil
          product_2.tax_category = nil
        end

        it "should be 0" do
          calculator.compute(order).should == 0
        end
      end

      context "when one item matches the tax category" do
        before do
          product_1.tax_category = tax_category
          product_2.tax_category = nil
        end

        it "should be equal to the item total * rate" do
          calculator.compute(order).should == 10.5
        end
      end

      context "when more than one item matches the tax category" do
        it "should be equal to the sum of the item totals * rate" do
          calculator.compute(order).should == 15.75
        end
      end
    end

    context "when given a line item" do
      context "when the variant matches the tax category" do
        it "should be equal to the item total * rate" do
          calculator.compute(line_item_1).should == 10.5
        end
      end

      context "when the variant does not match the tax category" do
        before do
          line_item_2.product.tax_category = nil
        end

        it "should be 0" do
          calculator.compute(line_item_2).should == 0
        end
      end
    end
  end
end