require 'test_helper'

class FolderDocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @folder_document = folder_documents(:one)
  end

  test "should get index" do
    get folder_documents_url
    assert_response :success
  end

  test "should get new" do
    get new_folder_document_url
    assert_response :success
  end

  test "should create folder_document" do
    assert_difference('FolderDocument.count') do
      post folder_documents_url, params: { folder_document: { content: @folder_document.content, folder_id: @folder_document.folder_id, folder_type: @folder_document.folder_type, heavy_video_url: @folder_document.heavy_video_url, of_phase: @folder_document.of_phase, site_id: @folder_document.site_id, unit_id: @folder_document.unit_id, uploaded_by: @folder_document.uploaded_by } }
    end

    assert_redirected_to folder_document_url(FolderDocument.last)
  end

  test "should show folder_document" do
    get folder_document_url(@folder_document)
    assert_response :success
  end

  test "should get edit" do
    get edit_folder_document_url(@folder_document)
    assert_response :success
  end

  test "should update folder_document" do
    patch folder_document_url(@folder_document), params: { folder_document: { content: @folder_document.content, folder_id: @folder_document.folder_id, folder_type: @folder_document.folder_type, heavy_video_url: @folder_document.heavy_video_url, of_phase: @folder_document.of_phase, site_id: @folder_document.site_id, unit_id: @folder_document.unit_id, uploaded_by: @folder_document.uploaded_by } }
    assert_redirected_to folder_document_url(@folder_document)
  end

  test "should destroy folder_document" do
    assert_difference('FolderDocument.count', -1) do
      delete folder_document_url(@folder_document)
    end

    assert_redirected_to folder_documents_url
  end
end
