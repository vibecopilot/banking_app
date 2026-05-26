require "application_system_test_case"

class RoleAccessesTest < ApplicationSystemTestCase
  setup do
    @role_access = role_accesses(:one)
  end

  test "visiting the index" do
    visit role_accesses_url
    assert_selector "h1", text: "Role Accesses"
  end

  test "creating a Role access" do
    visit role_accesses_url
    click_on "New Role Access"

    fill_in "Site", with: @role_access.site_id
    fill_in "Title", with: @role_access.title
    click_on "Create Role access"

    assert_text "Role access was successfully created"
    click_on "Back"
  end

  test "updating a Role access" do
    visit role_accesses_url
    click_on "Edit", match: :first

    fill_in "Site", with: @role_access.site_id
    fill_in "Title", with: @role_access.title
    click_on "Update Role access"

    assert_text "Role access was successfully updated"
    click_on "Back"
  end

  test "destroying a Role access" do
    visit role_accesses_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Role access was successfully destroyed"
  end
end
