require 'test_helper'

class ParkingSlotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @parking_slot = parking_slots(:one)
  end

  test "should get index" do
    get parking_slots_url
    assert_response :success
  end

  test "should get new" do
    get new_parking_slot_url
    assert_response :success
  end

  test "should create parking_slot" do
    assert_difference('ParkingSlot.count') do
      post parking_slots_url, params: { parking_slot: { end_hr: @parking_slot.end_hr, end_min: @parking_slot.end_min, site_id: @parking_slot.site_id, start_hr: @parking_slot.start_hr, start_min: @parking_slot.start_min } }
    end

    assert_redirected_to parking_slot_url(ParkingSlot.last)
  end

  test "should show parking_slot" do
    get parking_slot_url(@parking_slot)
    assert_response :success
  end

  test "should get edit" do
    get edit_parking_slot_url(@parking_slot)
    assert_response :success
  end

  test "should update parking_slot" do
    patch parking_slot_url(@parking_slot), params: { parking_slot: { end_hr: @parking_slot.end_hr, end_min: @parking_slot.end_min, site_id: @parking_slot.site_id, start_hr: @parking_slot.start_hr, start_min: @parking_slot.start_min } }
    assert_redirected_to parking_slot_url(@parking_slot)
  end

  test "should destroy parking_slot" do
    assert_difference('ParkingSlot.count', -1) do
      delete parking_slot_url(@parking_slot)
    end

    assert_redirected_to parking_slots_url
  end
end
