require 'test_helper'

class OtherProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @other_project = other_projects(:one)
  end

  test "should get index" do
    get other_projects_url
    assert_response :success
  end

  test "should get new" do
    get new_other_project_url
    assert_response :success
  end

  test "should create other_project" do
    assert_difference('OtherProject.count') do
      post other_projects_url, params: { other_project: { address: @other_project.address, company_id: @other_project.company_id, description: @other_project.description, title: @other_project.title } }
    end

    assert_redirected_to other_project_url(OtherProject.last)
  end

  test "should show other_project" do
    get other_project_url(@other_project)
    assert_response :success
  end

  test "should get edit" do
    get edit_other_project_url(@other_project)
    assert_response :success
  end

  test "should update other_project" do
    patch other_project_url(@other_project), params: { other_project: { address: @other_project.address, company_id: @other_project.company_id, description: @other_project.description, title: @other_project.title } }
    assert_redirected_to other_project_url(@other_project)
  end

  test "should destroy other_project" do
    assert_difference('OtherProject.count', -1) do
      delete other_project_url(@other_project)
    end

    assert_redirected_to other_projects_url
  end
end
