require 'test_helper'

class BlockedDaysControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blocked_day = blocked_days(:one)
  end

  test "should get index" do
    get blocked_days_url
    assert_response :success
  end

  test "should get new" do
    get new_blocked_day_url
    assert_response :success
  end

  test "should create blocked_day" do
    assert_difference('BlockedDay.count') do
      post blocked_days_url, params: { blocked_day: { booking_allowed: @blocked_day.booking_allowed, order_allowed: @blocked_day.order_allowed, reason: @blocked_day.reason, restaurant_id: @blocked_day.restaurant_id, start_date: @blocked_day.start_date, start_date: @blocked_day.start_date } }
    end

    assert_redirected_to blocked_day_url(BlockedDay.last)
  end

  test "should show blocked_day" do
    get blocked_day_url(@blocked_day)
    assert_response :success
  end

  test "should get edit" do
    get edit_blocked_day_url(@blocked_day)
    assert_response :success
  end

  test "should update blocked_day" do
    patch blocked_day_url(@blocked_day), params: { blocked_day: { booking_allowed: @blocked_day.booking_allowed, order_allowed: @blocked_day.order_allowed, reason: @blocked_day.reason, restaurant_id: @blocked_day.restaurant_id, start_date: @blocked_day.start_date, start_date: @blocked_day.start_date } }
    assert_redirected_to blocked_day_url(@blocked_day)
  end

  test "should destroy blocked_day" do
    assert_difference('BlockedDay.count', -1) do
      delete blocked_day_url(@blocked_day)
    end

    assert_redirected_to blocked_days_url
  end
end
