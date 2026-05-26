require 'test_helper'

class TicketLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket_log = ticket_logs(:one)
  end

  test "should get index" do
    get ticket_logs_url
    assert_response :success
  end

  test "should get new" do
    get new_ticket_log_url
    assert_response :success
  end

  test "should create ticket_log" do
    assert_difference('TicketLog.count') do
      post ticket_logs_url, params: { ticket_log: { created_by_id: @ticket_log.created_by_id, log_type: @ticket_log.log_type, remarks: @ticket_log.remarks, status: @ticket_log.status, ticket_id: @ticket_log.ticket_id } }
    end

    assert_redirected_to ticket_log_url(TicketLog.last)
  end

  test "should show ticket_log" do
    get ticket_log_url(@ticket_log)
    assert_response :success
  end

  test "should get edit" do
    get edit_ticket_log_url(@ticket_log)
    assert_response :success
  end

  test "should update ticket_log" do
    patch ticket_log_url(@ticket_log), params: { ticket_log: { created_by_id: @ticket_log.created_by_id, log_type: @ticket_log.log_type, remarks: @ticket_log.remarks, status: @ticket_log.status, ticket_id: @ticket_log.ticket_id } }
    assert_redirected_to ticket_log_url(@ticket_log)
  end

  test "should destroy ticket_log" do
    assert_difference('TicketLog.count', -1) do
      delete ticket_log_url(@ticket_log)
    end

    assert_redirected_to ticket_logs_url
  end
end
