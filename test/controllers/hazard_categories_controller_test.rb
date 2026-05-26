require 'test_helper'

class HazardCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hazard_category = hazard_categories(:one)
  end

  test "should get index" do
    get hazard_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_hazard_category_url
    assert_response :success
  end

  test "should create hazard_category" do
    assert_difference('HazardCategory.count') do
      post hazard_categories_url, params: { hazard_category: { activity_id: @hazard_category.activity_id, description: @hazard_category.description, name: @hazard_category.name, site_id: @hazard_category.site_id, sub_activity_id: @hazard_category.sub_activity_id } }
    end

    assert_redirected_to hazard_category_url(HazardCategory.last)
  end

  test "should show hazard_category" do
    get hazard_category_url(@hazard_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_hazard_category_url(@hazard_category)
    assert_response :success
  end

  test "should update hazard_category" do
    patch hazard_category_url(@hazard_category), params: { hazard_category: { activity_id: @hazard_category.activity_id, description: @hazard_category.description, name: @hazard_category.name, site_id: @hazard_category.site_id, sub_activity_id: @hazard_category.sub_activity_id } }
    assert_redirected_to hazard_category_url(@hazard_category)
  end

  test "should destroy hazard_category" do
    assert_difference('HazardCategory.count', -1) do
      delete hazard_category_url(@hazard_category)
    end

    assert_redirected_to hazard_categories_url
  end
end
