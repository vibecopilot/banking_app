require 'test_helper'

class AmenityBookingRulesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @amenity_booking_rule = amenity_booking_rules(:one)
  end

  test "should get index" do
    get amenity_booking_rules_url
    assert_response :success
  end

  test "should get new" do
    get new_amenity_booking_rule_url
    assert_response :success
  end

  test "should create amenity_booking_rule" do
    assert_difference('AmenityBookingRule.count') do
      post amenity_booking_rules_url, params: { amenity_booking_rule: { active: @amenity_booking_rule.active, amenity_id: @amenity_booking_rule.amenity_id, duration: @amenity_booking_rule.duration, enumerator: @amenity_booking_rule.enumerator, level: @amenity_booking_rule.level, site_id: @amenity_booking_rule.site_id } }
    end

    assert_redirected_to amenity_booking_rule_url(AmenityBookingRule.last)
  end

  test "should show amenity_booking_rule" do
    get amenity_booking_rule_url(@amenity_booking_rule)
    assert_response :success
  end

  test "should get edit" do
    get edit_amenity_booking_rule_url(@amenity_booking_rule)
    assert_response :success
  end

  test "should update amenity_booking_rule" do
    patch amenity_booking_rule_url(@amenity_booking_rule), params: { amenity_booking_rule: { active: @amenity_booking_rule.active, amenity_id: @amenity_booking_rule.amenity_id, duration: @amenity_booking_rule.duration, enumerator: @amenity_booking_rule.enumerator, level: @amenity_booking_rule.level, site_id: @amenity_booking_rule.site_id } }
    assert_redirected_to amenity_booking_rule_url(@amenity_booking_rule)
  end

  test "should destroy amenity_booking_rule" do
    assert_difference('AmenityBookingRule.count', -1) do
      delete amenity_booking_rule_url(@amenity_booking_rule)
    end

    assert_redirected_to amenity_booking_rules_url
  end
end
