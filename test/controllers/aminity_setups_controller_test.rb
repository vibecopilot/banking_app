require 'test_helper'

class AminitySetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aminity_setup = aminity_setups(:one)
  end

  test "should get index" do
    get aminity_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_aminity_setup_url
    assert_response :success
  end

  test "should create aminity_setup" do
    assert_difference('AminitySetup.count') do
      post aminity_setups_url, params: { aminity_setup: { aminity_id: @aminity_setup.aminity_id, end_time: @aminity_setup.end_time, name: @aminity_setup.name, site_id: @aminity_setup.site_id, slot_frequency: @aminity_setup.slot_frequency, start_time: @aminity_setup.start_time, unit_id: @aminity_setup.unit_id } }
    end

    assert_redirected_to aminity_setup_url(AminitySetup.last)
  end

  test "should show aminity_setup" do
    get aminity_setup_url(@aminity_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_aminity_setup_url(@aminity_setup)
    assert_response :success
  end

  test "should update aminity_setup" do
    patch aminity_setup_url(@aminity_setup), params: { aminity_setup: { aminity_id: @aminity_setup.aminity_id, end_time: @aminity_setup.end_time, name: @aminity_setup.name, site_id: @aminity_setup.site_id, slot_frequency: @aminity_setup.slot_frequency, start_time: @aminity_setup.start_time, unit_id: @aminity_setup.unit_id } }
    assert_redirected_to aminity_setup_url(@aminity_setup)
  end

  test "should destroy aminity_setup" do
    assert_difference('AminitySetup.count', -1) do
      delete aminity_setup_url(@aminity_setup)
    end

    assert_redirected_to aminity_setups_url
  end
end
