require 'test_helper'

class SnagAnswersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @snag_answer = snag_answers(:one)
  end

  test "should get index" do
    get snag_answers_url
    assert_response :success
  end

  test "should get new" do
    get new_snag_answer_url
    assert_response :success
  end

  test "should create snag_answer" do
    assert_difference('SnagAnswer.count') do
      post snag_answers_url, params: { snag_answer: { ans_descr: @snag_answer.ans_descr, answer_mode: @snag_answer.answer_mode, answer_type: @snag_answer.answer_type, checklist_id: @snag_answer.checklist_id, comments: @snag_answer.comments, company_id: @snag_answer.company_id, quest_option_id: @snag_answer.quest_option_id, question_id: @snag_answer.question_id, user_id: @snag_answer.user_id } }
    end

    assert_redirected_to snag_answer_url(SnagAnswer.last)
  end

  test "should show snag_answer" do
    get snag_answer_url(@snag_answer)
    assert_response :success
  end

  test "should get edit" do
    get edit_snag_answer_url(@snag_answer)
    assert_response :success
  end

  test "should update snag_answer" do
    patch snag_answer_url(@snag_answer), params: { snag_answer: { ans_descr: @snag_answer.ans_descr, answer_mode: @snag_answer.answer_mode, answer_type: @snag_answer.answer_type, checklist_id: @snag_answer.checklist_id, comments: @snag_answer.comments, company_id: @snag_answer.company_id, quest_option_id: @snag_answer.quest_option_id, question_id: @snag_answer.question_id, user_id: @snag_answer.user_id } }
    assert_redirected_to snag_answer_url(@snag_answer)
  end

  test "should destroy snag_answer" do
    assert_difference('SnagAnswer.count', -1) do
      delete snag_answer_url(@snag_answer)
    end

    assert_redirected_to snag_answers_url
  end
end
