require 'test_helper'

class AminitySlotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aminity_slot = aminity_slots(:one)
  end

  test "should get index" do
    get aminity_slots_url
    assert_response :success
  end

  test "should get new" do
    get new_aminity_slot_url
    assert_response :success
  end

  test "should create aminity_slot" do
    assert_difference('AminitySlot.count') do
      post aminity_slots_url, params: { aminity_slot: { aminity_id: @aminity_slot.aminity_id, end_time: @aminity_slot.end_time, start_time: @aminity_slot.start_time } }
    end

    assert_redirected_to aminity_slot_url(AminitySlot.last)
  end

  test "should show aminity_slot" do
    get aminity_slot_url(@aminity_slot)
    assert_response :success
  end

  test "should get edit" do
    get edit_aminity_slot_url(@aminity_slot)
    assert_response :success
  end

  test "should update aminity_slot" do
    patch aminity_slot_url(@aminity_slot), params: { aminity_slot: { aminity_id: @aminity_slot.aminity_id, end_time: @aminity_slot.end_time, start_time: @aminity_slot.start_time } }
    assert_redirected_to aminity_slot_url(@aminity_slot)
  end

  test "should destroy aminity_slot" do
    assert_difference('AminitySlot.count', -1) do
      delete aminity_slot_url(@aminity_slot)
    end

    assert_redirected_to aminity_slots_url
  end
end
