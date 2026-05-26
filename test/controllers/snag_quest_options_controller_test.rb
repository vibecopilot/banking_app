require 'test_helper'

class SnagQuestOptionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @snag_quest_option = snag_quest_options(:one)
  end

  test "should get index" do
    get snag_quest_options_url
    assert_response :success
  end

  test "should get new" do
    get new_snag_quest_option_url
    assert_response :success
  end

  test "should create snag_quest_option" do
    assert_difference('SnagQuestOption.count') do
      post snag_quest_options_url, params: { snag_quest_option: { active: @snag_quest_option.active, company_id: @snag_quest_option.company_id, option_type: @snag_quest_option.option_type, qname: @snag_quest_option.qname, question_id: @snag_quest_option.question_id } }
    end

    assert_redirected_to snag_quest_option_url(SnagQuestOption.last)
  end

  test "should show snag_quest_option" do
    get snag_quest_option_url(@snag_quest_option)
    assert_response :success
  end

  test "should get edit" do
    get edit_snag_quest_option_url(@snag_quest_option)
    assert_response :success
  end

  test "should update snag_quest_option" do
    patch snag_quest_option_url(@snag_quest_option), params: { snag_quest_option: { active: @snag_quest_option.active, company_id: @snag_quest_option.company_id, option_type: @snag_quest_option.option_type, qname: @snag_quest_option.qname, question_id: @snag_quest_option.question_id } }
    assert_redirected_to snag_quest_option_url(@snag_quest_option)
  end

  test "should destroy snag_quest_option" do
    assert_difference('SnagQuestOption.count', -1) do
      delete snag_quest_option_url(@snag_quest_option)
    end

    assert_redirected_to snag_quest_options_url
  end
end
