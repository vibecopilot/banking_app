require 'test_helper'

class MomDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mom_detail = mom_details(:one)
  end

  test "should get index" do
    get mom_details_url
    assert_response :success
  end

  test "should get new" do
    get new_mom_detail_url
    assert_response :success
  end

  test "should create mom_detail" do
    assert_difference('MomDetail.count') do
      post mom_details_url, params: { mom_detail: { active: @mom_detail.active, company_tag_name: @mom_detail.company_tag_name, created_by_id: @mom_detail.created_by_id, meeting_date: @mom_detail.meeting_date, title: @mom_detail.title } }
    end

    assert_redirected_to mom_detail_url(MomDetail.last)
  end

  test "should show mom_detail" do
    get mom_detail_url(@mom_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_mom_detail_url(@mom_detail)
    assert_response :success
  end

  test "should update mom_detail" do
    patch mom_detail_url(@mom_detail), params: { mom_detail: { active: @mom_detail.active, company_tag_name: @mom_detail.company_tag_name, created_by_id: @mom_detail.created_by_id, meeting_date: @mom_detail.meeting_date, title: @mom_detail.title } }
    assert_redirected_to mom_detail_url(@mom_detail)
  end

  test "should destroy mom_detail" do
    assert_difference('MomDetail.count', -1) do
      delete mom_detail_url(@mom_detail)
    end

    assert_redirected_to mom_details_url
  end
end
