require 'test_helper'

class NoticeUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @notice_user = notice_users(:one)
  end

  test "should get index" do
    get notice_users_url
    assert_response :success
  end

  test "should get new" do
    get new_notice_user_url
    assert_response :success
  end

  test "should create notice_user" do
    assert_difference('NoticeUser.count') do
      post notice_users_url, params: { notice_user: { notice_id: @notice_user.notice_id, user_id: @notice_user.user_id } }
    end

    assert_redirected_to notice_user_url(NoticeUser.last)
  end

  test "should show notice_user" do
    get notice_user_url(@notice_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_notice_user_url(@notice_user)
    assert_response :success
  end

  test "should update notice_user" do
    patch notice_user_url(@notice_user), params: { notice_user: { notice_id: @notice_user.notice_id, user_id: @notice_user.user_id } }
    assert_redirected_to notice_user_url(@notice_user)
  end

  test "should destroy notice_user" do
    assert_difference('NoticeUser.count', -1) do
      delete notice_user_url(@notice_user)
    end

    assert_redirected_to notice_users_url
  end
end
