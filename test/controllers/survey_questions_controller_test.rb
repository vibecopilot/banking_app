require 'test_helper'

class SurveyQuestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get survey_questions_index_url
    assert_response :success
  end

  test "should get show" do
    get survey_questions_show_url
    assert_response :success
  end

end
