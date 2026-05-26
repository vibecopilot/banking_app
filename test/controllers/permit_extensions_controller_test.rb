require 'test_helper'

class PermitExtensionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_extension = permit_extensions(:one)
  end

  test "should get index" do
    get permit_extensions_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_extension_url
    assert_response :success
  end

  test "should create permit_extension" do
    assert_difference('PermitExtension.count') do
      post permit_extensions_url, params: { permit_extension: { assign_to_ids: @permit_extension.assign_to_ids, ext_date: @permit_extension.ext_date, ext_time: @permit_extension.ext_time, permit_id: @permit_extension.permit_id, reason: @permit_extension.reason, site_id: @permit_extension.site_id } }
    end

    assert_redirected_to permit_extension_url(PermitExtension.last)
  end

  test "should show permit_extension" do
    get permit_extension_url(@permit_extension)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_extension_url(@permit_extension)
    assert_response :success
  end

  test "should update permit_extension" do
    patch permit_extension_url(@permit_extension), params: { permit_extension: { assign_to_ids: @permit_extension.assign_to_ids, ext_date: @permit_extension.ext_date, ext_time: @permit_extension.ext_time, permit_id: @permit_extension.permit_id, reason: @permit_extension.reason, site_id: @permit_extension.site_id } }
    assert_redirected_to permit_extension_url(@permit_extension)
  end

  test "should destroy permit_extension" do
    assert_difference('PermitExtension.count', -1) do
      delete permit_extension_url(@permit_extension)
    end

    assert_redirected_to permit_extensions_url
  end
end
