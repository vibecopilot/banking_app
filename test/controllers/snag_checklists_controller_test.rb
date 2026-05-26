require 'test_helper'

class SnagChecklistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @snag_checklist = snag_checklists(:one)
  end

  test "should get index" do
    get snag_checklists_url
    assert_response :success
  end

  test "should get new" do
    get new_snag_checklist_url
    assert_response :success
  end

  test "should create snag_checklist" do
    assert_difference('SnagChecklist.count') do
      post snag_checklists_url, params: { snag_checklist: { active: @snag_checklist.active, check_type: @snag_checklist.check_type, company_id: @snag_checklist.company_id, name: @snag_checklist.name, resource_id: @snag_checklist.resource_id, resource_type: @snag_checklist.resource_type, site_id: @snag_checklist.site_id, snag_audit_category_id: @snag_checklist.snag_audit_category_id, snag_audit_sub_category_id: @snag_checklist.snag_audit_sub_category_id, user_id: @snag_checklist.user_id } }
    end

    assert_redirected_to snag_checklist_url(SnagChecklist.last)
  end

  test "should show snag_checklist" do
    get snag_checklist_url(@snag_checklist)
    assert_response :success
  end

  test "should get edit" do
    get edit_snag_checklist_url(@snag_checklist)
    assert_response :success
  end

  test "should update snag_checklist" do
    patch snag_checklist_url(@snag_checklist), params: { snag_checklist: { active: @snag_checklist.active, check_type: @snag_checklist.check_type, company_id: @snag_checklist.company_id, name: @snag_checklist.name, resource_id: @snag_checklist.resource_id, resource_type: @snag_checklist.resource_type, site_id: @snag_checklist.site_id, snag_audit_category_id: @snag_checklist.snag_audit_category_id, snag_audit_sub_category_id: @snag_checklist.snag_audit_sub_category_id, user_id: @snag_checklist.user_id } }
    assert_redirected_to snag_checklist_url(@snag_checklist)
  end

  test "should destroy snag_checklist" do
    assert_difference('SnagChecklist.count', -1) do
      delete snag_checklist_url(@snag_checklist)
    end

    assert_redirected_to snag_checklists_url
  end
end
