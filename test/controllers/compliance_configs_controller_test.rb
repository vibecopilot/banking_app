require 'test_helper'

class ComplianceConfigsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_config = compliance_configs(:one)
  end

  test "should get index" do
    get compliance_configs_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_config_url
    assert_response :success
  end

  test "should create compliance_config" do
    assert_difference('ComplianceConfig.count') do
      post compliance_configs_url, params: { compliance_config: { assign_to_id: @compliance_config.assign_to_id, description: @compliance_config.description, due_in_days: @compliance_config.due_in_days, end_date: @compliance_config.end_date, frequency: @compliance_config.frequency, name: @compliance_config.name, priority: @compliance_config.priority, reviewer_id: @compliance_config.reviewer_id, site_id: @compliance_config.site_id, start_date: @compliance_config.start_date } }
    end

    assert_redirected_to compliance_config_url(ComplianceConfig.last)
  end

  test "should show compliance_config" do
    get compliance_config_url(@compliance_config)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_config_url(@compliance_config)
    assert_response :success
  end

  test "should update compliance_config" do
    patch compliance_config_url(@compliance_config), params: { compliance_config: { assign_to_id: @compliance_config.assign_to_id, description: @compliance_config.description, due_in_days: @compliance_config.due_in_days, end_date: @compliance_config.end_date, frequency: @compliance_config.frequency, name: @compliance_config.name, priority: @compliance_config.priority, reviewer_id: @compliance_config.reviewer_id, site_id: @compliance_config.site_id, start_date: @compliance_config.start_date } }
    assert_redirected_to compliance_config_url(@compliance_config)
  end

  test "should destroy compliance_config" do
    assert_difference('ComplianceConfig.count', -1) do
      delete compliance_config_url(@compliance_config)
    end

    assert_redirected_to compliance_configs_url
  end
end
