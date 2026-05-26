require 'test_helper'

class ComplaintModesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get complaint_modes_index_url
    assert_response :success
  end

  test "should get create" do
    get complaint_modes_create_url
    assert_response :success
  end

  test "should get edit" do
    get complaint_modes_edit_url
    assert_response :success
  end

end
