require 'test_helper'

class ParkingConfigurationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parking_configuration = parking_configurations(:one)
  end

  test "should get index" do
    get parking_configurations_url
    assert_response :success
  end

  test "should get new" do
    get new_parking_configuration_url
    assert_response :success
  end

  test "should create parking_configuration" do
    assert_difference('ParkingConfiguration.count') do
      post parking_configurations_url, params: { parking_configuration: { building_id: @parking_configuration.building_id, floor_id: @parking_configuration.floor_id, name: @parking_configuration.name, vehicle_type: @parking_configuration.vehicle_type } }
    end

    assert_redirected_to parking_configuration_url(ParkingConfiguration.last)
  end

  test "should show parking_configuration" do
    get parking_configuration_url(@parking_configuration)
    assert_response :success
  end

  test "should get edit" do
    get edit_parking_configuration_url(@parking_configuration)
    assert_response :success
  end

  test "should update parking_configuration" do
    patch parking_configuration_url(@parking_configuration), params: { parking_configuration: { building_id: @parking_configuration.building_id, floor_id: @parking_configuration.floor_id, name: @parking_configuration.name, vehicle_type: @parking_configuration.vehicle_type } }
    assert_redirected_to parking_configuration_url(@parking_configuration)
  end

  test "should destroy parking_configuration" do
    assert_difference('ParkingConfiguration.count', -1) do
      delete parking_configuration_url(@parking_configuration)
    end

    assert_redirected_to parking_configurations_url
  end
end
