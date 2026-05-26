require 'test_helper'

class RoleAccessesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @role_access = role_accesses(:one)
  end

  test "should get index" do
    get role_accesses_url
    assert_response :success
  end

  test "should get new" do
    get new_role_access_url
    assert_response :success
  end

  test "should create role_access" do
    assert_difference('RoleAccess.count') do
      post role_accesses_url, params: { role_access: { site_id: @role_access.site_id, title: @role_access.title } }
    end

    assert_redirected_to role_access_url(RoleAccess.last)
  end

  test "should show role_access" do
    get role_access_url(@role_access)
    assert_response :success
  end

  test "should get edit" do
    get edit_role_access_url(@role_access)
    assert_response :success
  end

  test "should update role_access" do
    patch role_access_url(@role_access), params: { role_access: { site_id: @role_access.site_id, title: @role_access.title } }
    assert_redirected_to role_access_url(@role_access)
  end

  test "should destroy role_access" do
    assert_difference('RoleAccess.count', -1) do
      delete role_access_url(@role_access)
    end

    assert_redirected_to role_accesses_url
  end
end
