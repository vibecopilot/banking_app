require 'test_helper'

class CamBillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cam_bill = cam_bills(:one)
  end

  test "should get index" do
    get cam_bills_url
    assert_response :success
  end

  test "should get new" do
    get new_cam_bill_url
    assert_response :success
  end

  test "should create cam_bill" do
    assert_difference('CamBill.count') do
      post cam_bills_url, params: { cam_bill: { bill_date: @cam_bill.bill_date, created_by: @cam_bill.created_by, due_date: @cam_bill.due_date, sub_amount: @cam_bill.sub_amount, total_amount: @cam_bill.total_amount, unit_id: @cam_bill.unit_id, user_id: @cam_bill.user_id } }
    end

    assert_redirected_to cam_bill_url(CamBill.last)
  end

  test "should show cam_bill" do
    get cam_bill_url(@cam_bill)
    assert_response :success
  end

  test "should get edit" do
    get edit_cam_bill_url(@cam_bill)
    assert_response :success
  end

  test "should update cam_bill" do
    patch cam_bill_url(@cam_bill), params: { cam_bill: { bill_date: @cam_bill.bill_date, created_by: @cam_bill.created_by, due_date: @cam_bill.due_date, sub_amount: @cam_bill.sub_amount, total_amount: @cam_bill.total_amount, unit_id: @cam_bill.unit_id, user_id: @cam_bill.user_id } }
    assert_redirected_to cam_bill_url(@cam_bill)
  end

  test "should destroy cam_bill" do
    assert_difference('CamBill.count', -1) do
      delete cam_bill_url(@cam_bill)
    end

    assert_redirected_to cam_bills_url
  end
end
