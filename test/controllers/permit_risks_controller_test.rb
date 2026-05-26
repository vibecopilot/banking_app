require 'test_helper'

class PermitRisksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_risk = permit_risks(:one)
  end

  test "should get index" do
    get permit_risks_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_risk_url
    assert_response :success
  end

  test "should create permit_risk" do
    assert_difference('PermitRisk.count') do
      post permit_risks_url, params: { permit_risk: { activity_id: @permit_risk.activity_id, hazard_category_id: @permit_risk.hazard_category_id, permit_type_id: @permit_risk.permit_type_id, risk_description: @permit_risk.risk_description, sub_activity_id: @permit_risk.sub_activity_id } }
    end

    assert_redirected_to permit_risk_url(PermitRisk.last)
  end

  test "should show permit_risk" do
    get permit_risk_url(@permit_risk)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_risk_url(@permit_risk)
    assert_response :success
  end

  test "should update permit_risk" do
    patch permit_risk_url(@permit_risk), params: { permit_risk: { activity_id: @permit_risk.activity_id, hazard_category_id: @permit_risk.hazard_category_id, permit_type_id: @permit_risk.permit_type_id, risk_description: @permit_risk.risk_description, sub_activity_id: @permit_risk.sub_activity_id } }
    assert_redirected_to permit_risk_url(@permit_risk)
  end

  test "should destroy permit_risk" do
    assert_difference('PermitRisk.count', -1) do
      delete permit_risk_url(@permit_risk)
    end

    assert_redirected_to permit_risks_url
  end
end
