require 'test_helper'

class ContactBooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact_book = contact_books(:one)
  end

  test "should get index" do
    get contact_books_url
    assert_response :success
  end

  test "should get new" do
    get new_contact_book_url
    assert_response :success
  end

  test "should create contact_book" do
    assert_difference('ContactBook.count') do
      post contact_books_url, params: { contact_book: { generic_info_id: @contact_book.generic_info_id, mobile: @contact_book.mobile, name: @contact_book.name, site_id: @contact_book.site_id } }
    end

    assert_redirected_to contact_book_url(ContactBook.last)
  end

  test "should show contact_book" do
    get contact_book_url(@contact_book)
    assert_response :success
  end

  test "should get edit" do
    get edit_contact_book_url(@contact_book)
    assert_response :success
  end

  test "should update contact_book" do
    patch contact_book_url(@contact_book), params: { contact_book: { generic_info_id: @contact_book.generic_info_id, mobile: @contact_book.mobile, name: @contact_book.name, site_id: @contact_book.site_id } }
    assert_redirected_to contact_book_url(@contact_book)
  end

  test "should destroy contact_book" do
    assert_difference('ContactBook.count', -1) do
      delete contact_book_url(@contact_book)
    end

    assert_redirected_to contact_books_url
  end
end
