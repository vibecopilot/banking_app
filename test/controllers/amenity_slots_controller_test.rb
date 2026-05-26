require 'test_helper'

class AmenitySlotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @amenity_slot = amenity_slots(:one)
  end

  test "should get index" do
    get amenity_slots_url
    assert_response :success
  end

  test "should get new" do
    get new_amenity_slot_url
    assert_response :success
  end

  test "should create amenity_slot" do
    assert_difference('AmenitySlot.count') do
      post amenity_slots_url, params: { amenity_slot: { amenity_id: @amenity_slot.amenity_id, end_hr: @amenity_slot.end_hr, end_min: @amenity_slot.end_min, start_hr: @amenity_slot.start_hr, start_min: @amenity_slot.start_min } }
    end

    assert_redirected_to amenity_slot_url(AmenitySlot.last)
  end

  test "should show amenity_slot" do
    get amenity_slot_url(@amenity_slot)
    assert_response :success
  end

  test "should get edit" do
    get edit_amenity_slot_url(@amenity_slot)
    assert_response :success
  end

  test "should update amenity_slot" do
    patch amenity_slot_url(@amenity_slot), params: { amenity_slot: { amenity_id: @amenity_slot.amenity_id, end_hr: @amenity_slot.end_hr, end_min: @amenity_slot.end_min, start_hr: @amenity_slot.start_hr, start_min: @amenity_slot.start_min } }
    assert_redirected_to amenity_slot_url(@amenity_slot)
  end

  test "should destroy amenity_slot" do
    assert_difference('AmenitySlot.count', -1) do
      delete amenity_slot_url(@amenity_slot)
    end

    assert_redirected_to amenity_slots_url
  end
end
