class FolderDocumentsController < ApplicationController
   include UserExt
before_action :authenticate_user!, if: :check_user
    before_action :api_user
    before_action :set_user
  before_action :set_folder_document, only: %i[ show edit update destroy ]

  # GET /folder_documents or /folder_documents.json
  def index
    @folders = Folder.where(site_id: @user.current_site_id).where.not(id: 145)
  end

  # GET /folder_documents/1 or /folder_documents/1.json
  def show
  end

  # GET /folder_documents/new
  def new
    @folder_document = FolderDocument.new
  end

  # GET /folder_documents/1/edit
  def edit
  end
def create_common_document
  @folder_document = FolderDocument.new(
    site_id: @user.current_site_id,
    uploaded_by: @user.id,
    image: params[:folder_document][:folder_document], # Access the uploaded file correctly
    document_type: params[:folder_document][:document_type], # Use 'document_type' instead of 'type'
    created_by: @user.id,
    folder_id: params[:folder_document][:parent_id]
  )

  respond_to do |format|
    if @folder_document.save
      format.json { render json: { success: true, message: 'Document created successfully', document: @folder_document }, status: :created }
    else
      format.json { render json: { success: false, errors: @folder_document.errors.full_messages }, status: :unprocessable_entity }
    end
  end
end



  # POST /folder_documents or /folder_documents.json
  def create
    # @folder_document = FolderDocument.new(folder_document_params)
    @folder_document =  FolderDocument.create(
  site_id: @user.current_site_id,
  uploaded_by: @user.id,
  image: params[:folder_document],
  type: 'common',
  created_by: @user.id 
)
    respond_to do |format|
      if @folder_document.save
        format.html { redirect_to @folder_document, notice: "Folder document was successfully created." }
        format.json { render :show, status: :created, location: @folder_document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @folder_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /folder_documents/1 or /folder_documents/1.json
  def update
    respond_to do |format|
      if @folder_document.update(folder_document_params)
        format.html { redirect_to @folder_document, notice: "Folder document was successfully updated." }
        format.json { render :show, status: :ok, location: @folder_document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @folder_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /folder_documents/1 or /folder_documents/1.json
  def destroy
    @folder_document.destroy
    respond_to do |format|
      format.html { redirect_to folder_documents_url, notice: "Folder document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_folder_document
      @folder_document = FolderDocument.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
def folder_document_params
  params.require(:folder_document).permit(
    :content, 
    :folder_id, 
    :site_id, 
    :uploaded_by, 
    :folder_type, 
    :of_phase, 
    :unit_id, 
    :heavy_video_url,
    :image,               
    :other_attribute1,     
    :other_attribute2     
  )
end

end
