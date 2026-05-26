require 'test_helper'

class MeterReadingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @meter_reading = meter_readings(:one)
  end

  test "should get index" do
    get meter_readings_url
    assert_response :success
  end

  test "should get new" do
    get new_meter_reading_url
    assert_response :success
  end

  test "should create meter_reading" do
    assert_difference('MeterReading.count') do
      post meter_readings_url, params: { meter_reading: { closing: @meter_reading.closing, consumption: @meter_reading.consumption, meter_id: @meter_reading.meter_id, opening: @meter_reading.opening, parameter: @meter_reading.parameter } }
    end

    assert_redirected_to meter_reading_url(MeterReading.last)
  end

  test "should show meter_reading" do
    get meter_reading_url(@meter_reading)
    assert_response :success
  end

  test "should get edit" do
    get edit_meter_reading_url(@meter_reading)
    assert_response :success
  end

  test "should update meter_reading" do
    patch meter_reading_url(@meter_reading), params: { meter_reading: { closing: @meter_reading.closing, consumption: @meter_reading.consumption, meter_id: @meter_reading.meter_id, opening: @meter_reading.opening, parameter: @meter_reading.parameter } }
    assert_redirected_to meter_reading_url(@meter_reading)
  end

  test "should destroy meter_reading" do
    assert_difference('MeterReading.count', -1) do
      delete meter_reading_url(@meter_reading)
    end

    assert_redirected_to meter_readings_url
  end
end
