require 'test_helper'

class AmenityBookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @amenity_booking = amenity_bookings(:one)
  end

  test "should get index" do
    get amenity_bookings_url
    assert_response :success
  end

  test "should get new" do
    get new_amenity_booking_url
    assert_response :success
  end

  test "should create amenity_booking" do
    assert_difference('AmenityBooking.count') do
      post amenity_bookings_url, params: { amenity_booking: { amenity_id: @amenity_booking.amenity_id, amenity_slot_id: @amenity_booking.amenity_slot_id, booking_date: @amenity_booking.booking_date, site_id: @amenity_booking.site_id, user_id: @amenity_booking.user_id } }
    end

    assert_redirected_to amenity_booking_url(AmenityBooking.last)
  end

  test "should show amenity_booking" do
    get amenity_booking_url(@amenity_booking)
    assert_response :success
  end

  test "should get edit" do
    get edit_amenity_booking_url(@amenity_booking)
    assert_response :success
  end

  test "should update amenity_booking" do
    patch amenity_booking_url(@amenity_booking), params: { amenity_booking: { amenity_id: @amenity_booking.amenity_id, amenity_slot_id: @amenity_booking.amenity_slot_id, booking_date: @amenity_booking.booking_date, site_id: @amenity_booking.site_id, user_id: @amenity_booking.user_id } }
    assert_redirected_to amenity_booking_url(@amenity_booking)
  end

  test "should destroy amenity_booking" do
    assert_difference('AmenityBooking.count', -1) do
      delete amenity_booking_url(@amenity_booking)
    end

    assert_redirected_to amenity_bookings_url
  end
end
