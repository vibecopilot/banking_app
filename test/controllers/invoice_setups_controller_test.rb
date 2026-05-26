require 'test_helper'

class InvoiceSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice_setup = invoice_setups(:one)
  end

  test "should get index" do
    get invoice_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_setup_url
    assert_response :success
  end

  test "should create invoice_setup" do
    assert_difference('InvoiceSetup.count') do
      post invoice_setups_url, params: { invoice_setup: { auto_generate: @invoice_setup.auto_generate, created_by: @invoice_setup.created_by, next_number: @invoice_setup.next_number, prefix: @invoice_setup.prefix, site_id: @invoice_setup.site_id } }
    end

    assert_redirected_to invoice_setup_url(InvoiceSetup.last)
  end

  test "should show invoice_setup" do
    get invoice_setup_url(@invoice_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_setup_url(@invoice_setup)
    assert_response :success
  end

  test "should update invoice_setup" do
    patch invoice_setup_url(@invoice_setup), params: { invoice_setup: { auto_generate: @invoice_setup.auto_generate, created_by: @invoice_setup.created_by, next_number: @invoice_setup.next_number, prefix: @invoice_setup.prefix, site_id: @invoice_setup.site_id } }
    assert_redirected_to invoice_setup_url(@invoice_setup)
  end

  test "should destroy invoice_setup" do
    assert_difference('InvoiceSetup.count', -1) do
      delete invoice_setup_url(@invoice_setup)
    end

    assert_redirected_to invoice_setups_url
  end
end
