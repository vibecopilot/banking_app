require 'test_helper'

class InventoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inventory = inventories(:one)
  end

  test "should get index" do
    get inventories_url
    assert_response :success
  end

  test "should get new" do
    get new_inventory_url
    assert_response :success
  end

  test "should create inventory" do
    assert_difference('Inventory.count') do
      post inventories_url, params: { inventory: { active: @inventory.active, asset_group_id: @inventory.asset_group_id, asset_id: @inventory.asset_id, asset_sub_group_id: @inventory.asset_sub_group_id, cgst_rate: @inventory.cgst_rate, code: @inventory.code, cost: @inventory.cost, criticality: @inventory.criticality, expiry_date: @inventory.expiry_date, hsn_id: @inventory.hsn_id, igst_rate: @inventory.igst_rate, inventory_type: @inventory.inventory_type, min_order_level: @inventory.min_order_level, min_stock_level: @inventory.min_stock_level, name: @inventory.name, quantity: @inventory.quantity, serial_number: @inventory.serial_number, sgst_rate: @inventory.sgst_rate, unit: @inventory.unit } }
    end

    assert_redirected_to inventory_url(Inventory.last)
  end

  test "should show inventory" do
    get inventory_url(@inventory)
    assert_response :success
  end

  test "should get edit" do
    get edit_inventory_url(@inventory)
    assert_response :success
  end

  test "should update inventory" do
    patch inventory_url(@inventory), params: { inventory: { active: @inventory.active, asset_group_id: @inventory.asset_group_id, asset_id: @inventory.asset_id, asset_sub_group_id: @inventory.asset_sub_group_id, cgst_rate: @inventory.cgst_rate, code: @inventory.code, cost: @inventory.cost, criticality: @inventory.criticality, expiry_date: @inventory.expiry_date, hsn_id: @inventory.hsn_id, igst_rate: @inventory.igst_rate, inventory_type: @inventory.inventory_type, min_order_level: @inventory.min_order_level, min_stock_level: @inventory.min_stock_level, name: @inventory.name, quantity: @inventory.quantity, serial_number: @inventory.serial_number, sgst_rate: @inventory.sgst_rate, unit: @inventory.unit } }
    assert_redirected_to inventory_url(@inventory)
  end

  test "should destroy inventory" do
    assert_difference('Inventory.count', -1) do
      delete inventory_url(@inventory)
    end

    assert_redirected_to inventories_url
  end
end
