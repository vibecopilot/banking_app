require 'test_helper'

class ShareWithsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @share_with = share_withs(:one)
  end

  test "should get index" do
    get share_withs_url
    assert_response :success
  end

  test "should get new" do
    get new_share_with_url
    assert_response :success
  end

  test "should create share_with" do
    assert_difference('ShareWith.count') do
      post share_withs_url, params: { share_with: { document_id: @share_with.document_id, folder_id: @share_with.folder_id, shared_by: @share_with.shared_by, user_id: @share_with.user_id } }
    end

    assert_redirected_to share_with_url(ShareWith.last)
  end

  test "should show share_with" do
    get share_with_url(@share_with)
    assert_response :success
  end

  test "should get edit" do
    get edit_share_with_url(@share_with)
    assert_response :success
  end

  test "should update share_with" do
    patch share_with_url(@share_with), params: { share_with: { document_id: @share_with.document_id, folder_id: @share_with.folder_id, shared_by: @share_with.shared_by, user_id: @share_with.user_id } }
    assert_redirected_to share_with_url(@share_with)
  end

  test "should destroy share_with" do
    assert_difference('ShareWith.count', -1) do
      delete share_with_url(@share_with)
    end

    assert_redirected_to share_withs_url
  end
end
