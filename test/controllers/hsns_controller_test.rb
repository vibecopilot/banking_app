require 'test_helper'

class HsnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hsn = hsns(:one)
  end

  test "should get index" do
    get hsns_url
    assert_response :success
  end

  test "should get new" do
    get new_hsn_url
    assert_response :success
  end

  test "should create hsn" do
    assert_difference('Hsn.count') do
      post hsns_url, params: { hsn: { active: @hsn.active, category: @hsn.category, cgst_rate: @hsn.cgst_rate, code: @hsn.code, company_id: @hsn.company_id, created_by: @hsn.created_by, hsn_type: @hsn.hsn_type, igst_rate: @hsn.igst_rate, sgst_rate: @hsn.sgst_rate, type: @hsn.type, updated_by: @hsn.updated_by } }
    end

    assert_redirected_to hsn_url(Hsn.last)
  end

  test "should show hsn" do
    get hsn_url(@hsn)
    assert_response :success
  end

  test "should get edit" do
    get edit_hsn_url(@hsn)
    assert_response :success
  end

  test "should update hsn" do
    patch hsn_url(@hsn), params: { hsn: { active: @hsn.active, category: @hsn.category, cgst_rate: @hsn.cgst_rate, code: @hsn.code, company_id: @hsn.company_id, created_by: @hsn.created_by, hsn_type: @hsn.hsn_type, igst_rate: @hsn.igst_rate, sgst_rate: @hsn.sgst_rate, type: @hsn.type, updated_by: @hsn.updated_by } }
    assert_redirected_to hsn_url(@hsn)
  end

  test "should destroy hsn" do
    assert_difference('Hsn.count', -1) do
      delete hsn_url(@hsn)
    end

    assert_redirected_to hsns_url
  end
end
