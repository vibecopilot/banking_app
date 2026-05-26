require 'test_helper'

class ChecklistCronsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @checklist_cron = checklist_crons(:one)
  end

  test "should get index" do
    get checklist_crons_url
    assert_response :success
  end

  test "should get new" do
    get new_checklist_cron_url
    assert_response :success
  end

  test "should create checklist_cron" do
    assert_difference('ChecklistCron.count') do
      post checklist_crons_url, params: { checklist_cron: { checklist_id: @checklist_cron.checklist_id, expression: @checklist_cron.expression } }
    end

    assert_redirected_to checklist_cron_url(ChecklistCron.last)
  end

  test "should show checklist_cron" do
    get checklist_cron_url(@checklist_cron)
    assert_response :success
  end

  test "should get edit" do
    get edit_checklist_cron_url(@checklist_cron)
    assert_response :success
  end

  test "should update checklist_cron" do
    patch checklist_cron_url(@checklist_cron), params: { checklist_cron: { checklist_id: @checklist_cron.checklist_id, expression: @checklist_cron.expression } }
    assert_redirected_to checklist_cron_url(@checklist_cron)
  end

  test "should destroy checklist_cron" do
    assert_difference('ChecklistCron.count', -1) do
      delete checklist_cron_url(@checklist_cron)
    end

    assert_redirected_to checklist_crons_url
  end
end
