require 'test_helper'

class ComplianceTrackersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_tracker = compliance_trackers(:one)
  end

  test "should get index" do
    get compliance_trackers_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_tracker_url
    assert_response :success
  end

  test "should create compliance_tracker" do
    assert_difference('ComplianceTracker.count') do
      post compliance_trackers_url, params: { compliance_tracker: { compliance_config_id: @compliance_tracker.compliance_config_id, site_id: @compliance_tracker.site_id, status: @compliance_tracker.status, submitted_by_id: @compliance_tracker.submitted_by_id, submitted_on: @compliance_tracker.submitted_on } }
    end

    assert_redirected_to compliance_tracker_url(ComplianceTracker.last)
  end

  test "should show compliance_tracker" do
    get compliance_tracker_url(@compliance_tracker)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_tracker_url(@compliance_tracker)
    assert_response :success
  end

  test "should update compliance_tracker" do
    patch compliance_tracker_url(@compliance_tracker), params: { compliance_tracker: { compliance_config_id: @compliance_tracker.compliance_config_id, site_id: @compliance_tracker.site_id, status: @compliance_tracker.status, submitted_by_id: @compliance_tracker.submitted_by_id, submitted_on: @compliance_tracker.submitted_on } }
    assert_redirected_to compliance_tracker_url(@compliance_tracker)
  end

  test "should destroy compliance_tracker" do
    assert_difference('ComplianceTracker.count', -1) do
      delete compliance_tracker_url(@compliance_tracker)
    end

    assert_redirected_to compliance_trackers_url
  end
end
