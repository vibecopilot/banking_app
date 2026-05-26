require 'test_helper'

class DeletedUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @deleted_user = deleted_users(:one)
  end

  test "should get index" do
    get deleted_users_url
    assert_response :success
  end

  test "should get new" do
    get new_deleted_user_url
    assert_response :success
  end

  test "should create deleted_user" do
    assert_difference('DeletedUser.count') do
      post deleted_users_url, params: { deleted_user: { email: @deleted_user.email, first_name: @deleted_user.first_name, last_name: @deleted_user.last_name, mobile: @deleted_user.mobile } }
    end

    assert_redirected_to deleted_user_url(DeletedUser.last)
  end

  test "should show deleted_user" do
    get deleted_user_url(@deleted_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_deleted_user_url(@deleted_user)
    assert_response :success
  end

  test "should update deleted_user" do
    patch deleted_user_url(@deleted_user), params: { deleted_user: { email: @deleted_user.email, first_name: @deleted_user.first_name, last_name: @deleted_user.last_name, mobile: @deleted_user.mobile } }
    assert_redirected_to deleted_user_url(@deleted_user)
  end

  test "should destroy deleted_user" do
    assert_difference('DeletedUser.count', -1) do
      delete deleted_user_url(@deleted_user)
    end

    assert_redirected_to deleted_users_url
  end
end
