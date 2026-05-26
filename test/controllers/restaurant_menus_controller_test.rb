require 'test_helper'

class RestaurantMenusControllerTest < ActionDispatch::IntegrationTest
  setup do
    @restaurant_menu = restaurant_menus(:one)
  end

  test "should get index" do
    get restaurant_menus_url
    assert_response :success
  end

  test "should get new" do
    get new_restaurant_menu_url
    assert_response :success
  end

  test "should create restaurant_menu" do
    assert_difference('RestaurantMenu.count') do
      post restaurant_menus_url, params: { restaurant_menu: { active: @restaurant_menu.active, category_id: @restaurant_menu.category_id, description: @restaurant_menu.description, name: @restaurant_menu.name, price: @restaurant_menu.price, restaurant_id: @restaurant_menu.restaurant_id, sku: @restaurant_menu.sku, sub_category_id: @restaurant_menu.sub_category_id } }
    end

    assert_redirected_to restaurant_menu_url(RestaurantMenu.last)
  end

  test "should show restaurant_menu" do
    get restaurant_menu_url(@restaurant_menu)
    assert_response :success
  end

  test "should get edit" do
    get edit_restaurant_menu_url(@restaurant_menu)
    assert_response :success
  end

  test "should update restaurant_menu" do
    patch restaurant_menu_url(@restaurant_menu), params: { restaurant_menu: { active: @restaurant_menu.active, category_id: @restaurant_menu.category_id, description: @restaurant_menu.description, name: @restaurant_menu.name, price: @restaurant_menu.price, restaurant_id: @restaurant_menu.restaurant_id, sku: @restaurant_menu.sku, sub_category_id: @restaurant_menu.sub_category_id } }
    assert_redirected_to restaurant_menu_url(@restaurant_menu)
  end

  test "should destroy restaurant_menu" do
    assert_difference('RestaurantMenu.count', -1) do
      delete restaurant_menu_url(@restaurant_menu)
    end

    assert_redirected_to restaurant_menus_url
  end
end
