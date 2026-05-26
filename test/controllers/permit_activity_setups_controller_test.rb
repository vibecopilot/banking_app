require 'test_helper'

class PermitActivitySetupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_activity_setup = permit_activity_setups(:one)
  end

  test "should get index" do
    get permit_activity_setups_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_activity_setup_url
    assert_response :success
  end

  test "should create permit_activity_setup" do
    assert_difference('PermitActivitySetup.count') do
      post permit_activity_setups_url, params: { permit_activity_setup: { name: @permit_activity_setup.name, permit_type_id: @permit_activity_setup.permit_type_id, site_id: @permit_activity_setup.site_id } }
    end

    assert_redirected_to permit_activity_setup_url(PermitActivitySetup.last)
  end

  test "should show permit_activity_setup" do
    get permit_activity_setup_url(@permit_activity_setup)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_activity_setup_url(@permit_activity_setup)
    assert_response :success
  end

  test "should update permit_activity_setup" do
    patch permit_activity_setup_url(@permit_activity_setup), params: { permit_activity_setup: { name: @permit_activity_setup.name, permit_type_id: @permit_activity_setup.permit_type_id, site_id: @permit_activity_setup.site_id } }
    assert_redirected_to permit_activity_setup_url(@permit_activity_setup)
  end

  test "should destroy permit_activity_setup" do
    assert_difference('PermitActivitySetup.count', -1) do
      delete permit_activity_setup_url(@permit_activity_setup)
    end

    assert_redirected_to permit_activity_setups_url
  end
end
