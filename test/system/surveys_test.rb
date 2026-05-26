require "application_system_test_case"

class SurveysTest < ApplicationSystemTestCase
  setup do
    @survey = surveys(:one)
  end

  test "visiting the index" do
    visit surveys_url
    assert_selector "h1", text: "Surveys"
  end

  test "creating a Survey" do
    visit surveys_url
    click_on "New Survey"

    fill_in "Created by", with: @survey.created_by_id
    fill_in "Description", with: @survey.description
    fill_in "End date", with: @survey.end_date
    fill_in "Start date", with: @survey.start_date
    fill_in "Status", with: @survey.status
    fill_in "Survey title", with: @survey.survey_title
    click_on "Create Survey"

    assert_text "Survey was successfully created"
    click_on "Back"
  end

  test "updating a Survey" do
    visit surveys_url
    click_on "Edit", match: :first

    fill_in "Created by", with: @survey.created_by_id
    fill_in "Description", with: @survey.description
    fill_in "End date", with: @survey.end_date
    fill_in "Start date", with: @survey.start_date
    fill_in "Status", with: @survey.status
    fill_in "Survey title", with: @survey.survey_title
    click_on "Update Survey"

    assert_text "Survey was successfully updated"
    click_on "Back"
  end

  test "destroying a Survey" do
    visit surveys_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Survey was successfully destroyed"
  end
end
