require 'test_helper'

class MomTasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mom_task = mom_tasks(:one)
  end

  test "should get index" do
    get mom_tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_mom_task_url
    assert_response :success
  end

  test "should create mom_task" do
    assert_difference('MomTask.count') do
      post mom_tasks_url, params: { mom_task: { company_tag_id: @mom_task.company_tag_id, description: @mom_task.description, mom_detail_id: @mom_task.mom_detail_id, responsible_person_email: @mom_task.responsible_person_email, responsible_person_id: @mom_task.responsible_person_id, responsible_person_name: @mom_task.responsible_person_name, responsible_person_type: @mom_task.responsible_person_type, target_date: @mom_task.target_date } }
    end

    assert_redirected_to mom_task_url(MomTask.last)
  end

  test "should show mom_task" do
    get mom_task_url(@mom_task)
    assert_response :success
  end

  test "should get edit" do
    get edit_mom_task_url(@mom_task)
    assert_response :success
  end

  test "should update mom_task" do
    patch mom_task_url(@mom_task), params: { mom_task: { company_tag_id: @mom_task.company_tag_id, description: @mom_task.description, mom_detail_id: @mom_task.mom_detail_id, responsible_person_email: @mom_task.responsible_person_email, responsible_person_id: @mom_task.responsible_person_id, responsible_person_name: @mom_task.responsible_person_name, responsible_person_type: @mom_task.responsible_person_type, target_date: @mom_task.target_date } }
    assert_redirected_to mom_task_url(@mom_task)
  end

  test "should destroy mom_task" do
    assert_difference('MomTask.count', -1) do
      delete mom_task_url(@mom_task)
    end

    assert_redirected_to mom_tasks_url
  end
end
