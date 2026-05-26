require 'test_helper'

class EventUsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_user = event_users(:one)
  end

  test "should get index" do
    get event_users_url
    assert_response :success
  end

  test "should get new" do
    get new_event_user_url
    assert_response :success
  end

  test "should create event_user" do
    assert_difference('EventUser.count') do
      post event_users_url, params: { event_user: { event_id: @event_user.event_id, rsvp: @event_user.rsvp, user_id: @event_user.user_id } }
    end

    assert_redirected_to event_user_url(EventUser.last)
  end

  test "should show event_user" do
    get event_user_url(@event_user)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_user_url(@event_user)
    assert_response :success
  end

  test "should update event_user" do
    patch event_user_url(@event_user), params: { event_user: { event_id: @event_user.event_id, rsvp: @event_user.rsvp, user_id: @event_user.user_id } }
    assert_redirected_to event_user_url(@event_user)
  end

  test "should destroy event_user" do
    assert_difference('EventUser.count', -1) do
      delete event_user_url(@event_user)
    end

    assert_redirected_to event_users_url
  end
end
