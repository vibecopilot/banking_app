require 'test_helper'

class AssetMeterTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @asset_meter_type = asset_meter_types(:one)
  end

  test "should get index" do
    get asset_meter_types_url
    assert_response :success
  end

  test "should get new" do
    get new_asset_meter_type_url
    assert_response :success
  end

  test "should create asset_meter_type" do
    assert_difference('AssetMeterType.count') do
      post asset_meter_types_url, params: { asset_meter_type: { active: @asset_meter_type.active, name: @asset_meter_type.name, unit_name: @asset_meter_type.unit_name, value: @asset_meter_type.value } }
    end

    assert_redirected_to asset_meter_type_url(AssetMeterType.last)
  end

  test "should show asset_meter_type" do
    get asset_meter_type_url(@asset_meter_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_asset_meter_type_url(@asset_meter_type)
    assert_response :success
  end

  test "should update asset_meter_type" do
    patch asset_meter_type_url(@asset_meter_type), params: { asset_meter_type: { active: @asset_meter_type.active, name: @asset_meter_type.name, unit_name: @asset_meter_type.unit_name, value: @asset_meter_type.value } }
    assert_redirected_to asset_meter_type_url(@asset_meter_type)
  end

  test "should destroy asset_meter_type" do
    assert_difference('AssetMeterType.count', -1) do
      delete asset_meter_type_url(@asset_meter_type)
    end

    assert_redirected_to asset_meter_types_url
  end
end
