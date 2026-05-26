require 'test_helper'

class ChecklistUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checklist_user = checklist_users(:one)
  end

  test "should get index" do
    get checklist_users_url
    assert_response :success
  end

  test "should get new" do
    get new_checklist_user_url
    assert_response :success
  end

  test "should create checklist_user" do
    assert_difference('ChecklistUser.count') do
      post checklist_users_url, params: { checklist_user: { checklist_id: @checklist_user.checklist_id, resource_id: @checklist_user.resource_id, resource_type: @checklist_user.resource_type, user_id: @checklist_user.user_id } }
    end

    assert_redirected_to checklist_user_url(ChecklistUser.last)
  end

  test "should show checklist_user" do
    get checklist_user_url(@checklist_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_checklist_user_url(@checklist_user)
    assert_response :success
  end

  test "should update checklist_user" do
    patch checklist_user_url(@checklist_user), params: { checklist_user: { checklist_id: @checklist_user.checklist_id, resource_id: @checklist_user.resource_id, resource_type: @checklist_user.resource_type, user_id: @checklist_user.user_id } }
    assert_redirected_to checklist_user_url(@checklist_user)
  end

  test "should destroy checklist_user" do
    assert_difference('ChecklistUser.count', -1) do
      delete checklist_user_url(@checklist_user)
    end

    assert_redirected_to checklist_users_url
  end
end
