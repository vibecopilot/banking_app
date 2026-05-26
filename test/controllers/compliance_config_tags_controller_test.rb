require 'test_helper'

class ComplianceConfigTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_config_tag = compliance_config_tags(:one)
  end

  test "should get index" do
    get compliance_config_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_config_tag_url
    assert_response :success
  end

  test "should create compliance_config_tag" do
    assert_difference('ComplianceConfigTag.count') do
      post compliance_config_tags_url, params: { compliance_config_tag: { compliance_config_id: @compliance_config_tag.compliance_config_id, compliance_tag_id: @compliance_config_tag.compliance_tag_id } }
    end

    assert_redirected_to compliance_config_tag_url(ComplianceConfigTag.last)
  end

  test "should show compliance_config_tag" do
    get compliance_config_tag_url(@compliance_config_tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_config_tag_url(@compliance_config_tag)
    assert_response :success
  end

  test "should update compliance_config_tag" do
    patch compliance_config_tag_url(@compliance_config_tag), params: { compliance_config_tag: { compliance_config_id: @compliance_config_tag.compliance_config_id, compliance_tag_id: @compliance_config_tag.compliance_tag_id } }
    assert_redirected_to compliance_config_tag_url(@compliance_config_tag)
  end

  test "should destroy compliance_config_tag" do
    assert_difference('ComplianceConfigTag.count', -1) do
      delete compliance_config_tag_url(@compliance_config_tag)
    end

    assert_redirected_to compliance_config_tags_url
  end
end
