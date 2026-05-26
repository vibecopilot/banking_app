require 'test_helper'

class MomAttendeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mom_attendee = mom_attendees(:one)
  end

  test "should get index" do
    get mom_attendees_url
    assert_response :success
  end

  test "should get new" do
    get new_mom_attendee_url
    assert_response :success
  end

  test "should create mom_attendee" do
    assert_difference('MomAttendee.count') do
      post mom_attendees_url, params: { mom_attendee: { attendees_id: @mom_attendee.attendees_id, attendees_type: @mom_attendee.attendees_type, company_tag_name: @mom_attendee.company_tag_name, email: @mom_attendee.email, mom_detail_id: @mom_attendee.mom_detail_id, name: @mom_attendee.name, organization: @mom_attendee.organization, role: @mom_attendee.role } }
    end

    assert_redirected_to mom_attendee_url(MomAttendee.last)
  end

  test "should show mom_attendee" do
    get mom_attendee_url(@mom_attendee)
    assert_response :success
  end

  test "should get edit" do
    get edit_mom_attendee_url(@mom_attendee)
    assert_response :success
  end

  test "should update mom_attendee" do
    patch mom_attendee_url(@mom_attendee), params: { mom_attendee: { attendees_id: @mom_attendee.attendees_id, attendees_type: @mom_attendee.attendees_type, company_tag_name: @mom_attendee.company_tag_name, email: @mom_attendee.email, mom_detail_id: @mom_attendee.mom_detail_id, name: @mom_attendee.name, organization: @mom_attendee.organization, role: @mom_attendee.role } }
    assert_redirected_to mom_attendee_url(@mom_attendee)
  end

  test "should destroy mom_attendee" do
    assert_difference('MomAttendee.count', -1) do
      delete mom_attendee_url(@mom_attendee)
    end

    assert_redirected_to mom_attendees_url
  end
end
