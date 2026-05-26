require 'test_helper'

class PermitSafetyEquipmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permit_safety_equipment = permit_safety_equipments(:one)
  end

  test "should get index" do
    get permit_safety_equipments_url
    assert_response :success
  end

  test "should get new" do
    get new_permit_safety_equipment_url
    assert_response :success
  end

  test "should create permit_safety_equipment" do
    assert_difference('PermitSafetyEquipment.count') do
      post permit_safety_equipments_url, params: { permit_safety_equipment: { activity_id: @permit_safety_equipment.activity_id, hazard_category_id: @permit_safety_equipment.hazard_category_id, permit_risk_id: @permit_safety_equipment.permit_risk_id, permit_type_id: @permit_safety_equipment.permit_type_id, safety_equipment_name: @permit_safety_equipment.safety_equipment_name, sub_activity_id: @permit_safety_equipment.sub_activity_id } }
    end

    assert_redirected_to permit_safety_equipment_url(PermitSafetyEquipment.last)
  end

  test "should show permit_safety_equipment" do
    get permit_safety_equipment_url(@permit_safety_equipment)
    assert_response :success
  end

  test "should get edit" do
    get edit_permit_safety_equipment_url(@permit_safety_equipment)
    assert_response :success
  end

  test "should update permit_safety_equipment" do
    patch permit_safety_equipment_url(@permit_safety_equipment), params: { permit_safety_equipment: { activity_id: @permit_safety_equipment.activity_id, hazard_category_id: @permit_safety_equipment.hazard_category_id, permit_risk_id: @permit_safety_equipment.permit_risk_id, permit_type_id: @permit_safety_equipment.permit_type_id, safety_equipment_name: @permit_safety_equipment.safety_equipment_name, sub_activity_id: @permit_safety_equipment.sub_activity_id } }
    assert_redirected_to permit_safety_equipment_url(@permit_safety_equipment)
  end

  test "should destroy permit_safety_equipment" do
    assert_difference('PermitSafetyEquipment.count', -1) do
      delete permit_safety_equipment_url(@permit_safety_equipment)
    end

    assert_redirected_to permit_safety_equipments_url
  end
end
