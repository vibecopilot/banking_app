require 'test_helper'

class ReceiptSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @receipt_setup = receipt_setups(:one)
  end

  test "should get index" do
    get receipt_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_receipt_setup_url
    assert_response :success
  end

  test "should create receipt_setup" do
    assert_difference('ReceiptSetup.count') do
      post receipt_setups_url, params: { receipt_setup: { auto_generate: @receipt_setup.auto_generate, created_by: @receipt_setup.created_by, next_number: @receipt_setup.next_number, prefix: @receipt_setup.prefix, receipt_number: @receipt_setup.receipt_number, site_id: @receipt_setup.site_id } }
    end

    assert_redirected_to receipt_setup_url(ReceiptSetup.last)
  end

  test "should show receipt_setup" do
    get receipt_setup_url(@receipt_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_receipt_setup_url(@receipt_setup)
    assert_response :success
  end

  test "should update receipt_setup" do
    patch receipt_setup_url(@receipt_setup), params: { receipt_setup: { auto_generate: @receipt_setup.auto_generate, created_by: @receipt_setup.created_by, next_number: @receipt_setup.next_number, prefix: @receipt_setup.prefix, receipt_number: @receipt_setup.receipt_number, site_id: @receipt_setup.site_id } }
    assert_redirected_to receipt_setup_url(@receipt_setup)
  end

  test "should destroy receipt_setup" do
    assert_difference('ReceiptSetup.count', -1) do
      delete receipt_setup_url(@receipt_setup)
    end

    assert_redirected_to receipt_setups_url
  end
end
