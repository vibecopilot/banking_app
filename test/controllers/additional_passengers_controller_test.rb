require 'test_helper'

class AdditionalPassengersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @additional_passenger = additional_passengers(:one)
  end

  test "should get index" do
    get additional_passengers_url
    assert_response :success
  end

  test "should get new" do
    get new_additional_passenger_url
    assert_response :success
  end

  test "should create additional_passenger" do
    assert_difference('AdditionalPassenger.count') do
      post additional_passengers_url, params: { additional_passenger: { flight_request_id: @additional_passenger.flight_request_id, gender: @additional_passenger.gender, name: @additional_passenger.name } }
    end

    assert_redirected_to additional_passenger_url(AdditionalPassenger.last)
  end

  test "should show additional_passenger" do
    get additional_passenger_url(@additional_passenger)
    assert_response :success
  end

  test "should get edit" do
    get edit_additional_passenger_url(@additional_passenger)
    assert_response :success
  end

  test "should update additional_passenger" do
    patch additional_passenger_url(@additional_passenger), params: { additional_passenger: { flight_request_id: @additional_passenger.flight_request_id, gender: @additional_passenger.gender, name: @additional_passenger.name } }
    assert_redirected_to additional_passenger_url(@additional_passenger)
  end

  test "should destroy additional_passenger" do
    assert_difference('AdditionalPassenger.count', -1) do
      delete additional_passenger_url(@additional_passenger)
    end

    assert_redirected_to additional_passengers_url
  end
end
