require 'test_helper'

class AmenitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @amenity = amenities(:one)
  end

  test "should get index" do
    get amenities_url
    assert_response :success
  end

  test "should get new" do
    get new_amenity_url
    assert_response :success
  end

  test "should create amenity" do
    assert_difference('Amenity.count') do
      post amenities_url, params: { amenity: { active: @amenity.active, advance_min: @amenity.advance_min, book_before: @amenity.book_before, cancel_before: @amenity.cancel_before, cancellation_policy: @amenity.cancellation_policy, create_by: @amenity.create_by, cutoff_min: @amenity.cutoff_min, deposit: @amenity.deposit, description: @amenity.description, disclaimer: @amenity.disclaimer, fac_name: @amenity.fac_name, fac_type: @amenity.fac_type, guest_price_adult: @amenity.guest_price_adult, guest_price_child: @amenity.guest_price_child, max_people: @amenity.max_people, max_slots: @amenity.max_slots, member_charges: @amenity.member_charges, member_price_adult: @amenity.member_price_adult, member_price_child: @amenity.member_price_child, min_people: @amenity.min_people, return_percentage: @amenity.return_percentage, site_id: @amenity.site_id, terms: @amenity.terms } }
    end

    assert_redirected_to amenity_url(Amenity.last)
  end

  test "should show amenity" do
    get amenity_url(@amenity)
    assert_response :success
  end

  test "should get edit" do
    get edit_amenity_url(@amenity)
    assert_response :success
  end

  test "should update amenity" do
    patch amenity_url(@amenity), params: { amenity: { active: @amenity.active, advance_min: @amenity.advance_min, book_before: @amenity.book_before, cancel_before: @amenity.cancel_before, cancellation_policy: @amenity.cancellation_policy, create_by: @amenity.create_by, cutoff_min: @amenity.cutoff_min, deposit: @amenity.deposit, description: @amenity.description, disclaimer: @amenity.disclaimer, fac_name: @amenity.fac_name, fac_type: @amenity.fac_type, guest_price_adult: @amenity.guest_price_adult, guest_price_child: @amenity.guest_price_child, max_people: @amenity.max_people, max_slots: @amenity.max_slots, member_charges: @amenity.member_charges, member_price_adult: @amenity.member_price_adult, member_price_child: @amenity.member_price_child, min_people: @amenity.min_people, return_percentage: @amenity.return_percentage, site_id: @amenity.site_id, terms: @amenity.terms } }
    assert_redirected_to amenity_url(@amenity)
  end

  test "should destroy amenity" do
    assert_difference('Amenity.count', -1) do
      delete amenity_url(@amenity)
    end

    assert_redirected_to amenities_url
  end
end
