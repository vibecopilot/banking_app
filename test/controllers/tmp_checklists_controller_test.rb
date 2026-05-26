require 'test_helper'

class TmpChecklistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tmp_checklist = tmp_checklists(:one)
  end

  test "should get index" do
    get tmp_checklists_url
    assert_response :success
  end

  test "should get new" do
    get new_tmp_checklist_url
    assert_response :success
  end

  test "should create tmp_checklist" do
    assert_difference('TmpChecklist.count') do
      post tmp_checklists_url, params: { tmp_checklist: { ctype: @tmp_checklist.ctype, frequency: @tmp_checklist.frequency, occurs: @tmp_checklist.occurs, patrolling_id: @tmp_checklist.patrolling_id, site_id: @tmp_checklist.site_id, tmp_name: @tmp_checklist.tmp_name, user_id: @tmp_checklist.user_id, weightage_enabled: @tmp_checklist.weightage_enabled } }
    end

    assert_redirected_to tmp_checklist_url(TmpChecklist.last)
  end

  test "should show tmp_checklist" do
    get tmp_checklist_url(@tmp_checklist)
    assert_response :success
  end

  test "should get edit" do
    get edit_tmp_checklist_url(@tmp_checklist)
    assert_response :success
  end

  test "should update tmp_checklist" do
    patch tmp_checklist_url(@tmp_checklist), params: { tmp_checklist: { ctype: @tmp_checklist.ctype, frequency: @tmp_checklist.frequency, occurs: @tmp_checklist.occurs, patrolling_id: @tmp_checklist.patrolling_id, site_id: @tmp_checklist.site_id, tmp_name: @tmp_checklist.tmp_name, user_id: @tmp_checklist.user_id, weightage_enabled: @tmp_checklist.weightage_enabled } }
    assert_redirected_to tmp_checklist_url(@tmp_checklist)
  end

  test "should destroy tmp_checklist" do
    assert_difference('TmpChecklist.count', -1) do
      delete tmp_checklist_url(@tmp_checklist)
    end

    assert_redirected_to tmp_checklists_url
  end
end
