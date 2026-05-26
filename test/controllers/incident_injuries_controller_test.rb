require 'test_helper'

class IncidentInjuriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incident_injury = incident_injuries(:one)
  end

  test "should get index" do
    get incident_injuries_url
    assert_response :success
  end

  test "should get new" do
    get new_incident_injury_url
    assert_response :success
  end

  test "should create incident_injury" do
    assert_difference('IncidentInjury.count') do
      post incident_injuries_url, params: { incident_injury: { company_name: @incident_injury.company_name, incident_id: @incident_injury.incident_id, injury_number: @incident_injury.injury_number, injury_type: @incident_injury.injury_type, lost_time: @incident_injury.lost_time, mobile: @incident_injury.mobile, name: @incident_injury.name, who_got_injured_id: @incident_injury.who_got_injured_id } }
    end

    assert_redirected_to incident_injury_url(IncidentInjury.last)
  end

  test "should show incident_injury" do
    get incident_injury_url(@incident_injury)
    assert_response :success
  end

  test "should get edit" do
    get edit_incident_injury_url(@incident_injury)
    assert_response :success
  end

  test "should update incident_injury" do
    patch incident_injury_url(@incident_injury), params: { incident_injury: { company_name: @incident_injury.company_name, incident_id: @incident_injury.incident_id, injury_number: @incident_injury.injury_number, injury_type: @incident_injury.injury_type, lost_time: @incident_injury.lost_time, mobile: @incident_injury.mobile, name: @incident_injury.name, who_got_injured_id: @incident_injury.who_got_injured_id } }
    assert_redirected_to incident_injury_url(@incident_injury)
  end

  test "should destroy incident_injury" do
    assert_difference('IncidentInjury.count', -1) do
      delete incident_injury_url(@incident_injury)
    end

    assert_redirected_to incident_injuries_url
  end
end
