require 'test_helper'

class SnagQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @snag_question = snag_questions(:one)
  end

  test "should get index" do
    get snag_questions_url
    assert_response :success
  end

  test "should get new" do
    get new_snag_question_url
    assert_response :success
  end

  test "should create snag_question" do
    assert_difference('SnagQuestion.count') do
      post snag_questions_url, params: { snag_question: { active: @snag_question.active, checklist_id: @snag_question.checklist_id, company_id: @snag_question.company_id, descr: @snag_question.descr, img_mandatory: @snag_question.img_mandatory, qnumber: @snag_question.qnumber, qtype: @snag_question.qtype, quest_mandatory: @snag_question.quest_mandatory, user_id: @snag_question.user_id } }
    end

    assert_redirected_to snag_question_url(SnagQuestion.last)
  end

  test "should show snag_question" do
    get snag_question_url(@snag_question)
    assert_response :success
  end

  test "should get edit" do
    get edit_snag_question_url(@snag_question)
    assert_response :success
  end

  test "should update snag_question" do
    patch snag_question_url(@snag_question), params: { snag_question: { active: @snag_question.active, checklist_id: @snag_question.checklist_id, company_id: @snag_question.company_id, descr: @snag_question.descr, img_mandatory: @snag_question.img_mandatory, qnumber: @snag_question.qnumber, qtype: @snag_question.qtype, quest_mandatory: @snag_question.quest_mandatory, user_id: @snag_question.user_id } }
    assert_redirected_to snag_question_url(@snag_question)
  end

  test "should destroy snag_question" do
    assert_difference('SnagQuestion.count', -1) do
      delete snag_question_url(@snag_question)
    end

    assert_redirected_to snag_questions_url
  end
end
