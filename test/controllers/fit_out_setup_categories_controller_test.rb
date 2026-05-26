require 'test_helper'

class FitOutSetupCategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get fit_out_setup_categories_index_url
    assert_response :success
  end

  test "should get show" do
    get fit_out_setup_categories_show_url
    assert_response :success
  end

  test "should get new" do
    get fit_out_setup_categories_new_url
    assert_response :success
  end

  test "should get edit" do
    get fit_out_setup_categories_edit_url
    assert_response :success
  end

  test "should get create" do
    get fit_out_setup_categories_create_url
    assert_response :success
  end

  test "should get update" do
    get fit_out_setup_categories_update_url
    assert_response :success
  end

  test "should get destroy" do
    get fit_out_setup_categories_destroy_url
    assert_response :success
  end

end
