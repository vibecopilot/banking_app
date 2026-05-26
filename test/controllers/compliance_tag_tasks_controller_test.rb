require 'test_helper'

class ComplianceTagTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_tag_task = compliance_tag_tasks(:one)
  end

  test "should get index" do
    get compliance_tag_tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_tag_task_url
    assert_response :success
  end

  test "should create compliance_tag_task" do
    assert_difference('ComplianceTagTask.count') do
      post compliance_tag_tasks_url, params: { compliance_tag_task: { compliance_tag_id: @compliance_tag_task.compliance_tag_id, name: @compliance_tag_task.name, weightage: @compliance_tag_task.weightage } }
    end

    assert_redirected_to compliance_tag_task_url(ComplianceTagTask.last)
  end

  test "should show compliance_tag_task" do
    get compliance_tag_task_url(@compliance_tag_task)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_tag_task_url(@compliance_tag_task)
    assert_response :success
  end

  test "should update compliance_tag_task" do
    patch compliance_tag_task_url(@compliance_tag_task), params: { compliance_tag_task: { compliance_tag_id: @compliance_tag_task.compliance_tag_id, name: @compliance_tag_task.name, weightage: @compliance_tag_task.weightage } }
    assert_redirected_to compliance_tag_task_url(@compliance_tag_task)
  end

  test "should destroy compliance_tag_task" do
    assert_difference('ComplianceTagTask.count', -1) do
      delete compliance_tag_task_url(@compliance_tag_task)
    end

    assert_redirected_to compliance_tag_tasks_url
  end
end
