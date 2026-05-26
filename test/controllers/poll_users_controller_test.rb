require 'test_helper'

class PollUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll_user = poll_users(:one)
  end

  test "should get index" do
    get poll_users_url
    assert_response :success
  end

  test "should get new" do
    get new_poll_user_url
    assert_response :success
  end

  test "should create poll_user" do
    assert_difference('PollUser.count') do
      post poll_users_url, params: { poll_user: { poll_id: @poll_user.poll_id, user_id: @poll_user.user_id } }
    end

    assert_redirected_to poll_user_url(PollUser.last)
  end

  test "should show poll_user" do
    get poll_user_url(@poll_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_poll_user_url(@poll_user)
    assert_response :success
  end

  test "should update poll_user" do
    patch poll_user_url(@poll_user), params: { poll_user: { poll_id: @poll_user.poll_id, user_id: @poll_user.user_id } }
    assert_redirected_to poll_user_url(@poll_user)
  end

  test "should destroy poll_user" do
    assert_difference('PollUser.count', -1) do
      delete poll_user_url(@poll_user)
    end

    assert_redirected_to poll_users_url
  end
end
