require 'test_helper'

class IncidenceTagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @incidence_tag = incidence_tags(:one)
  end

  test "should get index" do
    get incidence_tags_url
    assert_response :success
  end

  test "should get new" do
    get new_incidence_tag_url
    assert_response :success
  end

  test "should create incidence_tag" do
    assert_difference('IncidenceTag.count') do
      post incidence_tags_url, params: { incidence_tag: { active: @incidence_tag.active, comment: @incidence_tag.comment, name: @incidence_tag.name, parent_id: @incidence_tag.parent_id, resource_id: @incidence_tag.resource_id, resource_type: @incidence_tag.resource_type, tag_type: @incidence_tag.tag_type } }
    end

    assert_redirected_to incidence_tag_url(IncidenceTag.last)
  end

  test "should show incidence_tag" do
    get incidence_tag_url(@incidence_tag)
    assert_response :success
  end

  test "should get edit" do
    get edit_incidence_tag_url(@incidence_tag)
    assert_response :success
  end

  test "should update incidence_tag" do
    patch incidence_tag_url(@incidence_tag), params: { incidence_tag: { active: @incidence_tag.active, comment: @incidence_tag.comment, name: @incidence_tag.name, parent_id: @incidence_tag.parent_id, resource_id: @incidence_tag.resource_id, resource_type: @incidence_tag.resource_type, tag_type: @incidence_tag.tag_type } }
    assert_redirected_to incidence_tag_url(@incidence_tag)
  end

  test "should destroy incidence_tag" do
    assert_difference('IncidenceTag.count', -1) do
      delete incidence_tag_url(@incidence_tag)
    end

    assert_redirected_to incidence_tags_url
  end
end
