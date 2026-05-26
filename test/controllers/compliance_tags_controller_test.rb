require 'test_helper'

class ComplianceTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @compliance_tag = compliance_tags(:one)
  end

  test "should get index" do
    get compliance_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_compliance_tag_url
    assert_response :success
  end

  test "should create compliance_tag" do
    assert_difference('ComplianceTag.count') do
      post compliance_tags_url, params: { compliance_tag: { company_id: @compliance_tag.company_id, critical: @compliance_tag.critical, name: @compliance_tag.name, nature: @compliance_tag.nature, parent_id: @compliance_tag.parent_id, resource_id: @compliance_tag.resource_id, resource_type: @compliance_tag.resource_type, risk: @compliance_tag.risk, tag_type: @compliance_tag.tag_type } }
    end

    assert_redirected_to compliance_tag_url(ComplianceTag.last)
  end

  test "should show compliance_tag" do
    get compliance_tag_url(@compliance_tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_compliance_tag_url(@compliance_tag)
    assert_response :success
  end

  test "should update compliance_tag" do
    patch compliance_tag_url(@compliance_tag), params: { compliance_tag: { company_id: @compliance_tag.company_id, critical: @compliance_tag.critical, name: @compliance_tag.name, nature: @compliance_tag.nature, parent_id: @compliance_tag.parent_id, resource_id: @compliance_tag.resource_id, resource_type: @compliance_tag.resource_type, risk: @compliance_tag.risk, tag_type: @compliance_tag.tag_type } }
    assert_redirected_to compliance_tag_url(@compliance_tag)
  end

  test "should destroy compliance_tag" do
    assert_difference('ComplianceTag.count', -1) do
      delete compliance_tag_url(@compliance_tag)
    end

    assert_redirected_to compliance_tags_url
  end
end
