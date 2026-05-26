require 'test_helper'

class TravelAllowanceRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @travel_allowance_request = travel_allowance_requests(:one)
  end

  test "should get index" do
    get travel_allowance_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_travel_allowance_request_url
    assert_response :success
  end

  test "should create travel_allowance_request" do
    assert_difference('TravelAllowanceRequest.count') do
      post travel_allowance_requests_url, params: { travel_allowance_request: { amount_spent: @travel_allowance_request.amount_spent, approval_status: @travel_allowance_request.approval_status, date_of_expense: @travel_allowance_request.date_of_expense, description_of_expense: @travel_allowance_request.description_of_expense, employee_id: @travel_allowance_request.employee_id, employee_name: @travel_allowance_request.employee_name, expense_category: @travel_allowance_request.expense_category, manager_approval: @travel_allowance_request.manager_approval, reimbursement_amount: @travel_allowance_request.reimbursement_amount, reimbursement_confirmation_email: @travel_allowance_request.reimbursement_confirmation_email, reimbursement_method: @travel_allowance_request.reimbursement_method } }
    end

    assert_redirected_to travel_allowance_request_url(TravelAllowanceRequest.last)
  end

  test "should show travel_allowance_request" do
    get travel_allowance_request_url(@travel_allowance_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_travel_allowance_request_url(@travel_allowance_request)
    assert_response :success
  end

  test "should update travel_allowance_request" do
    patch travel_allowance_request_url(@travel_allowance_request), params: { travel_allowance_request: { amount_spent: @travel_allowance_request.amount_spent, approval_status: @travel_allowance_request.approval_status, date_of_expense: @travel_allowance_request.date_of_expense, description_of_expense: @travel_allowance_request.description_of_expense, employee_id: @travel_allowance_request.employee_id, employee_name: @travel_allowance_request.employee_name, expense_category: @travel_allowance_request.expense_category, manager_approval: @travel_allowance_request.manager_approval, reimbursement_amount: @travel_allowance_request.reimbursement_amount, reimbursement_confirmation_email: @travel_allowance_request.reimbursement_confirmation_email, reimbursement_method: @travel_allowance_request.reimbursement_method } }
    assert_redirected_to travel_allowance_request_url(@travel_allowance_request)
  end

  test "should destroy travel_allowance_request" do
    assert_difference('TravelAllowanceRequest.count', -1) do
      delete travel_allowance_request_url(@travel_allowance_request)
    end

    assert_redirected_to travel_allowance_requests_url
  end
end
