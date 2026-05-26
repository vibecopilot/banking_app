require 'test_helper'

class StatusRestaurantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @status_restaurant = status_restaurants(:one)
  end

  test "should get index" do
    get status_restaurants_url
    assert_response :success
  end

  test "should get new" do
    get new_status_restaurant_url
    assert_response :success
  end

  test "should create status_restaurant" do
    assert_difference('StatusRestaurant.count') do
      post status_restaurants_url, params: { status_restaurant: { color: @status_restaurant.color, display_name: @status_restaurant.display_name, fixed_state: @status_restaurant.fixed_state, order: @status_restaurant.order, status: @status_restaurant.status } }
    end

    assert_redirected_to status_restaurant_url(StatusRestaurant.last)
  end

  test "should show status_restaurant" do
    get status_restaurant_url(@status_restaurant)
    assert_response :success
  end

  test "should get edit" do
    get edit_status_restaurant_url(@status_restaurant)
    assert_response :success
  end

  test "should update status_restaurant" do
    patch status_restaurant_url(@status_restaurant), params: { status_restaurant: { color: @status_restaurant.color, display_name: @status_restaurant.display_name, fixed_state: @status_restaurant.fixed_state, order: @status_restaurant.order, status: @status_restaurant.status } }
    assert_redirected_to status_restaurant_url(@status_restaurant)
  end

  test "should destroy status_restaurant" do
    assert_difference('StatusRestaurant.count', -1) do
      delete status_restaurant_url(@status_restaurant)
    end

    assert_redirected_to status_restaurants_url
  end
end
