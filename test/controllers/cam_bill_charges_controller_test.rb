require 'test_helper'

class CamBillChargesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cam_bill_charge = cam_bill_charges(:one)
  end

  test "should get index" do
    get cam_bill_charges_url
    assert_response :success
  end

  test "should get new" do
    get new_cam_bill_charge_url
    assert_response :success
  end

  test "should create cam_bill_charge" do
    assert_difference('CamBillCharge.count') do
      post cam_bill_charges_url, params: { cam_bill_charge: { cam_bill_id: @cam_bill_charge.cam_bill_id, cgst_amount: @cam_bill_charge.cgst_amount, charge_amount: @cam_bill_charge.charge_amount, charge_id: @cam_bill_charge.charge_id, description: @cam_bill_charge.description, igst_amount: @cam_bill_charge.igst_amount, sgst_amount: @cam_bill_charge.sgst_amount, sub_amount: @cam_bill_charge.sub_amount } }
    end

    assert_redirected_to cam_bill_charge_url(CamBillCharge.last)
  end

  test "should show cam_bill_charge" do
    get cam_bill_charge_url(@cam_bill_charge)
    assert_response :success
  end

  test "should get edit" do
    get edit_cam_bill_charge_url(@cam_bill_charge)
    assert_response :success
  end

  test "should update cam_bill_charge" do
    patch cam_bill_charge_url(@cam_bill_charge), params: { cam_bill_charge: { cam_bill_id: @cam_bill_charge.cam_bill_id, cgst_amount: @cam_bill_charge.cgst_amount, charge_amount: @cam_bill_charge.charge_amount, charge_id: @cam_bill_charge.charge_id, description: @cam_bill_charge.description, igst_amount: @cam_bill_charge.igst_amount, sgst_amount: @cam_bill_charge.sgst_amount, sub_amount: @cam_bill_charge.sub_amount } }
    assert_redirected_to cam_bill_charge_url(@cam_bill_charge)
  end

  test "should destroy cam_bill_charge" do
    assert_difference('CamBillCharge.count', -1) do
      delete cam_bill_charge_url(@cam_bill_charge)
    end

    assert_redirected_to cam_bill_charges_url
  end
end
