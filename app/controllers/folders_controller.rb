class FoldersController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_folder, only: %i[show edit update destroy]

  # GET /folders or /folders.json
  def index
    @folders = Folder.where(site_id: @user.current_site_id)
  end

  def destroy_folder
    @folder = Folder.find(params[:id])
    @folder.destroy
    respond_to do |format|
      format.html { redirect_to folders_url, notice: "Folder was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def get_share_with
    @share_withs = ShareWith.where(user_id: @user.id)
    folder_ids = @share_withs.pluck(:folder_id).compact.uniq
    document_ids = @share_withs.pluck(:document_id).compact.uniq
    @folders = Folder.where(id: folder_ids)
    @documents = FolderDocument.where(id: document_ids)

    documents_json = @share_withs.map do |share_with|
      folder = @folders.find { |f| f.id == share_with.folder_id }
      document = @documents.find { |d| d.id == share_with.document_id }

      {
        id: share_with.id,  # share_with ID
        folder: folder ? {
          id: folder.id,
          name: folder.name,
          parent_id: folder.parent_id,
        } : nil,
        document: document ? {
          id: document.id,
          content: document.content,
          folder_id: document.folder_id,
          site_id: document.site_id,
          uploaded_by: document.uploaded_by,
          folder_type: document.folder_type,
          of_phase: document.of_phase,
          unit_id: document.unit_id,
          heavy_video_url: document.heavy_video_url,
          created_at: document.created_at,
          updated_at: document.updated_at,
          document_url: document.document_url, # Assuming this method exists in the model
          image_file_name: document.image_file_name,
          image_content_type: document.image_content_type,
          image_file_size: document.image_file_size,
          image_updated_at: document.image_updated_at,
          document_type: document.document_type,
          created_by: document.created_by
        } : nil
      }
    end

    respond_to do |format|
      format.json do
        render json: { 
          success: true, 
          message: 'Folders and documents retrieved successfully', 
          folders: @folders, 
          documents: documents_json 
        }, status: :ok
      end
    end
  end

  def get_folders
    if params[:parent_id].present?
      # @folders = Folder.where(site_id: @user.current_site_id, parent_id: params[:parent_id])
      @folders = Folder.where(site_id: @user.current_site_id, parent_id: params[:parent_id]).where.not(id: 145)
      @documents = FolderDocument.where(site_id: @user.current_site_id, folder_id: params[:parent_id])
    else
      # @folders = Folder.where(site_id: @user.current_site_id, parent_id: nil, folder_type: 'common')
      @folders = Folder.where(site_id: @user.current_site_id, parent_id: nil, folder_type: 'common').where.not(id: 145)
      @documents = FolderDocument.where(site_id: @user.current_site_id, folder_id: nil)
    end

    # Build the JSON for documents
    documents_json = @documents.map do |document|
      {
        id: document.id,
        content: document.content,
        folder_id: document.folder_id,
        site_id: document.site_id,
        uploaded_by: document.uploaded_by,
        folder_type: document.folder_type,
        of_phase: document.of_phase,
        unit_id: document.unit_id,
        heavy_video_url: document.heavy_video_url,
        created_at: document.created_at,
        updated_at: document.updated_at,
        document_url: document.document_url, # Assuming this method exists in the model
        image_file_name: document.image_file_name,
        image_content_type: document.image_content_type,
        image_file_size: document.image_file_size,
        image_updated_at: document.image_updated_at,
        document_type: document.document_type,
        created_by: document.created_by
      }
    end

    # Respond with JSON
    respond_to do |format|
      format.json do
        render json: { 
          success: true, 
          message: 'Folders retrieved successfully', 
          folders: @folders, 
          documents: documents_json 
        }, status: :ok
      end
    end
  end

  def get_personal_folders
    if params[:parent_id].present?
      @folders = Folder.where(created_by: @user.id, parent_id: params[:parent_id], folder_type: 'personal')
    else
      @folders = Folder.where(created_by: @user.id, parent_id: nil, folder_type: 'personal')
    end

    @documents = FolderDocument.where(created_by: @user.id, folder_id: params[:parent_id] || nil, document_type: 'personal')

    # Build the JSON for documents
    documents_json = @documents.map do |document|
      {
        id: document.id,
        content: document.content,
        folder_id: document.folder_id,
        site_id: document.site_id,
        uploaded_by: document.uploaded_by,
        folder_type: document.folder_type,
        of_phase: document.of_phase,
        unit_id: document.unit_id,
        heavy_video_url: document.heavy_video_url,
        created_at: document.created_at,
        updated_at: document.updated_at,
        document_url: document.document_url, # Assuming this method exists in the model
        file_name: document.image_file_name,
        image_content_type: document.image_content_type,
        image_file_size: document.image_file_size,
        image_updated_at: document.image_updated_at,
        document_type: document.document_type,
        created_by: document.created_by
      }
    end

    respond_to do |format|
      format.json { render json: { success: true, message: 'Folders retrieved successfully', folders: @folders, documents: documents_json }, status: :ok }
    end
  end

  # GET /folders/1 or /folders/1.json
  def show
  end

  # GET /folders/new
  def new
    @folder = Folder.new
  end

  # GET /folders/1/edit
  def edit
  end

  def create_common_folder
    @common_folder = Folder.new(folder_params)
    if params[:parent_id].present?
      @current_folder = Folder.find(params[:parent_id])
      @common_folder.parent_id = @current_folder.id
    end
    @common_folder.created_by = @user.id
    if @common_folder.save
      respond_to do |format|
        format.js { render json: { success: true, message: 'Folder created successfully', folder: @common_folder }, status: :created }
        format.json { render json: { success: true, message: 'Folder created successfully', folder: @common_folder }, status: :created }
      end
    else
      respond_to do |format|
        format.js { render json: { success: false, errors: @common_folder.errors.full_messages }, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @common_folder.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def share_multiple_documents
    response_data = { success: true, folders: [], documents: [] }

    if params[:file_type] == "folder"
      if params[:unit_ids].present?
        params[:unit_ids].each do |unit_id|
          folder = Folder.create(
            unit_id: unit_id,
            name: params[:folder][:name],
            description: params[:folder][:description],
            site_id: @user.current_site_id,
            uploaded_by: @user.id,
            folder_type: 'common'
          )
          response_data[:folders] << folder
          handle_flat_document(params[:flat_document], unit_id, folder.id, response_data, "common") if params[:flat_document].present?
        end
      else
        folder = Folder.create(
          name: params[:folder][:name],
          description: params[:folder][:description],
          site_id: @user.current_site_id,
          uploaded_by: @user.id,
          folder_type: "common"
        )
        response_data[:folders] << folder
      end
    elsif params[:file_type] == "files"
      if params[:unit_ids].present?
        params[:unit_ids].each do |unit_id|
          handle_flat_document(params[:flat_document], unit_id, nil, response_data, "common") if params[:flat_document].present?
        end
      end
    end

    render json: response_data, status: :created
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  def share_personal_documents
    response_data = { success: true, folders: [], documents: [] }
    if params[:file_type] == "folder"
      if params[:unit_ids].present?
        params[:unit_ids].each do |unit_id|
          folder = Folder.create(
            unit_id: unit_id,
            name: params[:folder][:name],
            description: params[:folder][:description],
            site_id: @user.current_site_id,
            uploaded_by: @user.id,
            folder_type: 'personal'
          )
          response_data[:folders] << folder
          handle_flat_document(params[:flat_document], unit_id, folder.id, response_data, "personal") if params[:flat_document].present?
        end
      else
        folder = Folder.create(
          name: params[:folder][:name],
          description: params[:folder][:description],
          site_id: @user.current_site_id,
          uploaded_by: @user.id,
          folder_type: "personal"
        )
        response_data[:folders] << folder
      end
    elsif params[:file_type] == "files"
      if params[:unit_ids].present?
        params[:unit_ids].each do |unit_id|
          handle_flat_document(params[:flat_document], unit_id, nil, response_data, "personal") if params[:flat_document].present?
        end
      end
    end

    render json: response_data, status: :created
  rescue => e
    render json: { success: false, error: e.message }, status: :internal_server_error
  end

  private

  def set_folder
    @folder = Folder.find(params[:id])
  end


  def folder_params
    params.require(:folder).permit(:name, :description, :parent_id, :site_id, :uploaded_by, :folder_type)
  end
end
