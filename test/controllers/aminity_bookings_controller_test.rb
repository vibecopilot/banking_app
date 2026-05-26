require 'test_helper'

class AminityBookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aminity_booking = aminity_bookings(:one)
  end

  test "should get index" do
    get aminity_bookings_url
    assert_response :success
  end

  test "should get new" do
    get new_aminity_booking_url
    assert_response :success
  end

  test "should create aminity_booking" do
    assert_difference('AminityBooking.count') do
      post aminity_bookings_url, params: { aminity_booking: { aminity_id: @aminity_booking.aminity_id, cancellation_policy: @aminity_booking.cancellation_policy, comment: @aminity_booking.comment, created_by_id: @aminity_booking.created_by_id, date: @aminity_booking.date, payment_method: @aminity_booking.payment_method, status: @aminity_booking.status, terms_and_conditions: @aminity_booking.terms_and_conditions, user_id: @aminity_booking.user_id } }
    end

    assert_redirected_to aminity_booking_url(AminityBooking.last)
  end

  test "should show aminity_booking" do
    get aminity_booking_url(@aminity_booking)
    assert_response :success
  end

  test "should get edit" do
    get edit_aminity_booking_url(@aminity_booking)
    assert_response :success
  end

  test "should update aminity_booking" do
    patch aminity_booking_url(@aminity_booking), params: { aminity_booking: { aminity_id: @aminity_booking.aminity_id, cancellation_policy: @aminity_booking.cancellation_policy, comment: @aminity_booking.comment, created_by_id: @aminity_booking.created_by_id, date: @aminity_booking.date, payment_method: @aminity_booking.payment_method, status: @aminity_booking.status, terms_and_conditions: @aminity_booking.terms_and_conditions, user_id: @aminity_booking.user_id } }
    assert_redirected_to aminity_booking_url(@aminity_booking)
  end

  test "should destroy aminity_booking" do
    assert_difference('AminityBooking.count', -1) do
      delete aminity_booking_url(@aminity_booking)
    end

    assert_redirected_to aminity_bookings_url
  end
end
