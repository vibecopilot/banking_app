require 'test_helper'

class PermitTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_type = permit_types(:one)
  end

  test "should get index" do
    get permit_types_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_type_url
    assert_response :success
  end

  test "should create permit_type" do
    assert_difference('PermitType.count') do
      post permit_types_url, params: { permit_type: { name: @permit_type.name, site_id: @permit_type.site_id } }
    end

    assert_redirected_to permit_type_url(PermitType.last)
  end

  test "should show permit_type" do
    get permit_type_url(@permit_type)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_type_url(@permit_type)
    assert_response :success
  end

  test "should update permit_type" do
    patch permit_type_url(@permit_type), params: { permit_type: { name: @permit_type.name, site_id: @permit_type.site_id } }
    assert_redirected_to permit_type_url(@permit_type)
  end

  test "should destroy permit_type" do
    assert_difference('PermitType.count', -1) do
      delete permit_type_url(@permit_type)
    end

    assert_redirected_to permit_types_url
  end
end
