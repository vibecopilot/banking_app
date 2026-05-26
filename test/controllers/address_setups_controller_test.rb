require 'test_helper'

class AddressSetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @address_setup = address_setups(:one)
  end

  test "should get index" do
    get address_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_address_setup_url
    assert_response :success
  end

  test "should create address_setup" do
    assert_difference('AddressSetup.count') do
      post address_setups_url, params: { address_setup: { address: @address_setup.address, building_id: @address_setup.building_id, cheque_in_favour_of: @address_setup.cheque_in_favour_of, email_address: @address_setup.email_address, fax_number: @address_setup.fax_number, gst_number: @address_setup.gst_number, pan_number: @address_setup.pan_number, phone_number: @address_setup.phone_number, registration_no: @address_setup.registration_no, state: @address_setup.state, title: @address_setup.title } }
    end

    assert_redirected_to address_setup_url(AddressSetup.last)
  end

  test "should show address_setup" do
    get address_setup_url(@address_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_address_setup_url(@address_setup)
    assert_response :success
  end

  test "should update address_setup" do
    patch address_setup_url(@address_setup), params: { address_setup: { address: @address_setup.address, building_id: @address_setup.building_id, cheque_in_favour_of: @address_setup.cheque_in_favour_of, email_address: @address_setup.email_address, fax_number: @address_setup.fax_number, gst_number: @address_setup.gst_number, pan_number: @address_setup.pan_number, phone_number: @address_setup.phone_number, registration_no: @address_setup.registration_no, state: @address_setup.state, title: @address_setup.title } }
    assert_redirected_to address_setup_url(@address_setup)
  end

  test "should destroy address_setup" do
    assert_difference('AddressSetup.count', -1) do
      delete address_setup_url(@address_setup)
    end

    assert_redirected_to address_setups_url
  end
end
