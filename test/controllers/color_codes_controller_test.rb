require 'test_helper'

class ColorCodesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @color_code = color_codes(:one)
  end

  test "should get index" do
    get color_codes_url
    assert_response :success
  end

  test "should get new" do
    get new_color_code_url
    assert_response :success
  end

  test "should create color_code" do
    assert_difference('ColorCode.count') do
      post color_codes_url, params: { color_code: { code: @color_code.code } }
    end

    assert_redirected_to color_code_url(ColorCode.last)
  end

  test "should show color_code" do
    get color_code_url(@color_code)
    assert_response :success
  end

  test "should get edit" do
    get edit_color_code_url(@color_code)
    assert_response :success
  end

  test "should update color_code" do
    patch color_code_url(@color_code), params: { color_code: { code: @color_code.code } }
    assert_redirected_to color_code_url(@color_code)
  end

  test "should destroy color_code" do
    assert_difference('ColorCode.count', -1) do
      delete color_code_url(@color_code)
    end

    assert_redirected_to color_codes_url
  end
end
