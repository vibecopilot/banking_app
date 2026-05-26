require 'test_helper'

class AssetMeasuresControllerTest < ActionDispatch::IntegrationTest
  setup do
    @asset_measure = asset_measures(:one)
  end

  test "should get index" do
    get asset_measures_url
    assert_response :success
  end

  test "should get new" do
    get new_asset_measure_url
    assert_response :success
  end

  test "should create asset_measure" do
    assert_difference('AssetMeasure.count') do
      post asset_measures_url, params: { asset_measure: { active: @asset_measure.active, alert_above: @asset_measure.alert_above, alert_below: @asset_measure.alert_below, asset_id: @asset_measure.asset_id, check_previous_reading: @asset_measure.check_previous_reading, cloned: @asset_measure.cloned, max_value: @asset_measure.max_value, meter_tag: @asset_measure.meter_tag, meter_unit_id: @asset_measure.meter_unit_id, min_value: @asset_measure.min_value, multiplier_factor: @asset_measure.multiplier_factor, name: @asset_measure.name, unit_type: @asset_measure.unit_type } }
    end

    assert_redirected_to asset_measure_url(AssetMeasure.last)
  end

  test "should show asset_measure" do
    get asset_measure_url(@asset_measure)
    assert_response :success
  end

  test "should get edit" do
    get edit_asset_measure_url(@asset_measure)
    assert_response :success
  end

  test "should update asset_measure" do
    patch asset_measure_url(@asset_measure), params: { asset_measure: { active: @asset_measure.active, alert_above: @asset_measure.alert_above, alert_below: @asset_measure.alert_below, asset_id: @asset_measure.asset_id, check_previous_reading: @asset_measure.check_previous_reading, cloned: @asset_measure.cloned, max_value: @asset_measure.max_value, meter_tag: @asset_measure.meter_tag, meter_unit_id: @asset_measure.meter_unit_id, min_value: @asset_measure.min_value, multiplier_factor: @asset_measure.multiplier_factor, name: @asset_measure.name, unit_type: @asset_measure.unit_type } }
    assert_redirected_to asset_measure_url(@asset_measure)
  end

  test "should destroy asset_measure" do
    assert_difference('AssetMeasure.count', -1) do
      delete asset_measure_url(@asset_measure)
    end

    assert_redirected_to asset_measures_url
  end
end
