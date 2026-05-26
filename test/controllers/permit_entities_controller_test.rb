require 'test_helper'

class PermitEntitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_entity = permit_entities(:one)
  end

  test "should get index" do
    get permit_entities_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_entity_url
    assert_response :success
  end

  test "should create permit_entity" do
    assert_difference('PermitEntity.count') do
      post permit_entities_url, params: { permit_entity: { active: @permit_entity.active, name: @permit_entity.name, permit_id: @permit_entity.permit_id } }
    end

    assert_redirected_to permit_entity_url(PermitEntity.last)
  end

  test "should show permit_entity" do
    get permit_entity_url(@permit_entity)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_entity_url(@permit_entity)
    assert_response :success
  end

  test "should update permit_entity" do
    patch permit_entity_url(@permit_entity), params: { permit_entity: { active: @permit_entity.active, name: @permit_entity.name, permit_id: @permit_entity.permit_id } }
    assert_redirected_to permit_entity_url(@permit_entity)
  end

  test "should destroy permit_entity" do
    assert_difference('PermitEntity.count', -1) do
      delete permit_entity_url(@permit_entity)
    end

    assert_redirected_to permit_entities_url
  end
end
