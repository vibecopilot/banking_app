require 'test_helper'

class TicketItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket_item = ticket_items(:one)
  end

  test "should get index" do
    get ticket_items_url
    assert_response :success
  end

  test "should get new" do
    get new_ticket_item_url
    assert_response :success
  end

  test "should create ticket_item" do
    assert_difference('TicketItem.count') do
      post ticket_items_url, params: { ticket_item: { item_count: @ticket_item.item_count, item_id: @ticket_item.item_id, rate: @ticket_item.rate, ticket_id: @ticket_item.ticket_id } }
    end

    assert_redirected_to ticket_item_url(TicketItem.last)
  end

  test "should show ticket_item" do
    get ticket_item_url(@ticket_item)
    assert_response :success
  end

  test "should get edit" do
    get edit_ticket_item_url(@ticket_item)
    assert_response :success
  end

  test "should update ticket_item" do
    patch ticket_item_url(@ticket_item), params: { ticket_item: { item_count: @ticket_item.item_count, item_id: @ticket_item.item_id, rate: @ticket_item.rate, ticket_id: @ticket_item.ticket_id } }
    assert_redirected_to ticket_item_url(@ticket_item)
  end

  test "should destroy ticket_item" do
    assert_difference('TicketItem.count', -1) do
      delete ticket_item_url(@ticket_item)
    end

    assert_redirected_to ticket_items_url
  end
end
