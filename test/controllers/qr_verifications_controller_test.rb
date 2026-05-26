require 'test_helper'

class QrVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @qr_verification = qr_verifications(:one)
  end

  test "should get index" do
    get qr_verifications_url
    assert_response :success
  end

  test "should get new" do
    get new_qr_verification_url
    assert_response :success
  end

  test "should create qr_verification" do
    assert_difference('QrVerification.count') do
      post qr_verifications_url, params: { qr_verification: { checked_in: @qr_verification.checked_in, checked_in_at: @qr_verification.checked_in_at, checked_in_by_id: @qr_verification.checked_in_by_id, code: @qr_verification.code, expected_time: @qr_verification.expected_time, generated_by_id: @qr_verification.generated_by_id, notes: @qr_verification.notes, purpose: @qr_verification.purpose, site_id: @qr_verification.site_id, valid_till: @qr_verification.valid_till } }
    end

    assert_redirected_to qr_verification_url(QrVerification.last)
  end

  test "should show qr_verification" do
    get qr_verification_url(@qr_verification)
    assert_response :success
  end

  test "should get edit" do
    get edit_qr_verification_url(@qr_verification)
    assert_response :success
  end

  test "should update qr_verification" do
    patch qr_verification_url(@qr_verification), params: { qr_verification: { checked_in: @qr_verification.checked_in, checked_in_at: @qr_verification.checked_in_at, checked_in_by_id: @qr_verification.checked_in_by_id, code: @qr_verification.code, expected_time: @qr_verification.expected_time, generated_by_id: @qr_verification.generated_by_id, notes: @qr_verification.notes, purpose: @qr_verification.purpose, site_id: @qr_verification.site_id, valid_till: @qr_verification.valid_till } }
    assert_redirected_to qr_verification_url(@qr_verification)
  end

  test "should destroy qr_verification" do
    assert_difference('QrVerification.count', -1) do
      delete qr_verification_url(@qr_verification)
    end

    assert_redirected_to qr_verifications_url
  end
end
