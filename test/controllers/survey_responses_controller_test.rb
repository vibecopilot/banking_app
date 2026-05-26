require 'test_helper'

class SurveyResponsesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get survey_responses_index_url
    assert_response :success
  end

  test "should get show" do
    get survey_responses_show_url
    assert_response :success
  end

end
