require 'test_helper'

class Api::V1::GroupedDashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_grouped_dashboard_index_url
    assert_response :success
  end

  test "should get site_dashboard" do
    get api_v1_grouped_dashboard_site_dashboard_url
    assert_response :success
  end

  test "should get drilldown" do
    get api_v1_grouped_dashboard_drilldown_url
    assert_response :success
  end

end
