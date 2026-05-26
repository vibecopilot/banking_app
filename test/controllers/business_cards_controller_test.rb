require 'test_helper'

class BusinessCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @business_card = business_cards(:one)
  end

  test "should get index" do
    get business_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_business_card_url
    assert_response :success
  end

  test "should create business_card" do
    assert_difference('BusinessCard.count') do
      post business_cards_url, params: { business_card: { address: @business_card.address, contact_number: @business_card.contact_number, email_id: @business_card.email_id, full_name: @business_card.full_name, profession: @business_card.profession, website_url: @business_card.website_url } }
    end

    assert_redirected_to business_card_url(BusinessCard.last)
  end

  test "should show business_card" do
    get business_card_url(@business_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_business_card_url(@business_card)
    assert_response :success
  end

  test "should update business_card" do
    patch business_card_url(@business_card), params: { business_card: { address: @business_card.address, contact_number: @business_card.contact_number, email_id: @business_card.email_id, full_name: @business_card.full_name, profession: @business_card.profession, website_url: @business_card.website_url } }
    assert_redirected_to business_card_url(@business_card)
  end

  test "should destroy business_card" do
    assert_difference('BusinessCard.count', -1) do
      delete business_card_url(@business_card)
    end

    assert_redirected_to business_cards_url
  end
end
