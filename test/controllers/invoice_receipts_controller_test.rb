require 'test_helper'

class InvoiceReceiptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @invoice_receipt = invoice_receipts(:one)
  end

  test "should get index" do
    get invoice_receipts_url
    assert_response :success
  end

  test "should get new" do
    get new_invoice_receipt_url
    assert_response :success
  end

  test "should create invoice_receipt" do
    assert_difference('InvoiceReceipt.count') do
      post invoice_receipts_url, params: { invoice_receipt: { address_id: @invoice_receipt.address_id, amount_received: @invoice_receipt.amount_received, bank_name: @invoice_receipt.bank_name, branch_name: @invoice_receipt.branch_name, building_id: @invoice_receipt.building_id, invoice_number: @invoice_receipt.invoice_number, notes: @invoice_receipt.notes, payment_date: @invoice_receipt.payment_date, payment_mode: @invoice_receipt.payment_mode, receipt_date: @invoice_receipt.receipt_date, receipt_number: @invoice_receipt.receipt_number, transaction_or_cheque_number: @invoice_receipt.transaction_or_cheque_number, unit_id: @invoice_receipt.unit_id } }
    end

    assert_redirected_to invoice_receipt_url(InvoiceReceipt.last)
  end

  test "should show invoice_receipt" do
    get invoice_receipt_url(@invoice_receipt)
    assert_response :success
  end

  test "should get edit" do
    get edit_invoice_receipt_url(@invoice_receipt)
    assert_response :success
  end

  test "should update invoice_receipt" do
    patch invoice_receipt_url(@invoice_receipt), params: { invoice_receipt: { address_id: @invoice_receipt.address_id, amount_received: @invoice_receipt.amount_received, bank_name: @invoice_receipt.bank_name, branch_name: @invoice_receipt.branch_name, building_id: @invoice_receipt.building_id, invoice_number: @invoice_receipt.invoice_number, notes: @invoice_receipt.notes, payment_date: @invoice_receipt.payment_date, payment_mode: @invoice_receipt.payment_mode, receipt_date: @invoice_receipt.receipt_date, receipt_number: @invoice_receipt.receipt_number, transaction_or_cheque_number: @invoice_receipt.transaction_or_cheque_number, unit_id: @invoice_receipt.unit_id } }
    assert_redirected_to invoice_receipt_url(@invoice_receipt)
  end

  test "should destroy invoice_receipt" do
    assert_difference('InvoiceReceipt.count', -1) do
      delete invoice_receipt_url(@invoice_receipt)
    end

    assert_redirected_to invoice_receipts_url
  end
end
