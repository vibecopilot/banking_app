require 'test_helper'

class AminitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @aminity = aminities(:one)
  end

  test "should get index" do
    get aminities_url
    assert_response :success
  end

  test "should get new" do
    get new_aminity_url
    assert_response :success
  end

  test "should create aminity" do
    assert_difference('Aminity.count') do
      post aminities_url, params: { aminity: { cost: @aminity.cost, cost: @aminity.cost, name: @aminity.name, site_id: @aminity.site_id } }
    end

    assert_redirected_to aminity_url(Aminity.last)
  end

  test "should show aminity" do
    get aminity_url(@aminity)
    assert_response :success
  end

  test "should get edit" do
    get edit_aminity_url(@aminity)
    assert_response :success
  end

  test "should update aminity" do
    patch aminity_url(@aminity), params: { aminity: { cost: @aminity.cost, cost: @aminity.cost, name: @aminity.name, site_id: @aminity.site_id } }
    assert_redirected_to aminity_url(@aminity)
  end

  test "should destroy aminity" do
    assert_difference('Aminity.count', -1) do
      delete aminity_url(@aminity)
    end

    assert_redirected_to aminities_url
  end
end
