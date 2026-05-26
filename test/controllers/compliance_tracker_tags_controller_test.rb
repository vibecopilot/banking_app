require 'test_helper'

class ComplianceTrackerTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_tracker_tag = compliance_tracker_tags(:one)
  end

  test "should get index" do
    get compliance_tracker_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_tracker_tag_url
    assert_response :success
  end

  test "should create compliance_tracker_tag" do
    assert_difference('ComplianceTrackerTag.count') do
      post compliance_tracker_tags_url, params: { compliance_tracker_tag: { comment: @compliance_tracker_tag.comment, compliance_tag_id: @compliance_tracker_tag.compliance_tag_id, compliance_tag_task_id: @compliance_tracker_tag.compliance_tag_task_id, compliance_tracker_id: @compliance_tracker_tag.compliance_tracker_id, observation: @compliance_tracker_tag.observation, recommendtion: @compliance_tracker_tag.recommendtion, submitted_by_id: @compliance_tracker_tag.submitted_by_id, submitted_on: @compliance_tracker_tag.submitted_on } }
    end

    assert_redirected_to compliance_tracker_tag_url(ComplianceTrackerTag.last)
  end

  test "should show compliance_tracker_tag" do
    get compliance_tracker_tag_url(@compliance_tracker_tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_tracker_tag_url(@compliance_tracker_tag)
    assert_response :success
  end

  test "should update compliance_tracker_tag" do
    patch compliance_tracker_tag_url(@compliance_tracker_tag), params: { compliance_tracker_tag: { comment: @compliance_tracker_tag.comment, compliance_tag_id: @compliance_tracker_tag.compliance_tag_id, compliance_tag_task_id: @compliance_tracker_tag.compliance_tag_task_id, compliance_tracker_id: @compliance_tracker_tag.compliance_tracker_id, observation: @compliance_tracker_tag.observation, recommendtion: @compliance_tracker_tag.recommendtion, submitted_by_id: @compliance_tracker_tag.submitted_by_id, submitted_on: @compliance_tracker_tag.submitted_on } }
    assert_redirected_to compliance_tracker_tag_url(@compliance_tracker_tag)
  end

  test "should destroy compliance_tracker_tag" do
    assert_difference('ComplianceTrackerTag.count', -1) do
      delete compliance_tracker_tag_url(@compliance_tracker_tag)
    end

    assert_redirected_to compliance_tracker_tags_url
  end
end
