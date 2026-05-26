class FitoutDocumentsController < ApplicationController
  before_action :set_fitout_document, only: %i[ show edit update destroy ]

  # GET /fitout_documents or /fitout_documents.json
  def index
    @fitout_documents = FitoutDocument.all.order(created_at: :desc)
  end

  # GET /fitout_documents/1 or /fitout_documents/1.json
  def show
  end

  # GET /fitout_documents/new
  def new
    @fitout_document = FitoutDocument.new
  end

  # GET /fitout_documents/1/edit
  def edit
  end

  # POST /fitout_documents or /fitout_documents.json
  def create
    @fitout_document = FitoutDocument.new(fitout_document_params)
    # binding.pry

    respond_to do |format|
      if @fitout_document.save
        #binding.pry
        if params[:fitout_docs].present?
          Array(params[:fitout_docs]).each do |doc|

            Attachfile.create(
              image: doc,
              relation: "FitoutDocument",
              relation_id: @fitout_document.id,
              active: 1
            )
          end
        end
        format.html { redirect_to @fitout_document, notice: "Fitout document was successfully created." }
        format.json { render :show, status: :created, location: @fitout_document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @fitout_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fitout_documents/1 or /fitout_documents/1.json
  def update
    respond_to do |format|
      if @fitout_document.update(fitout_document_params)
        format.html { redirect_to @fitout_document, notice: "Fitout document was successfully updated." }
        format.json { render :show, status: :ok, location: @fitout_document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @fitout_document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fitout_documents/1 or /fitout_documents/1.json
  def destroy
    @fitout_document.destroy
    respond_to do |format|
      format.html { redirect_to fitout_documents_url, notice: "Fitout document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_fitout_document
    @fitout_document = FitoutDocument.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def fitout_document_params
    params.require(:fitout_document).permit(:fitout_request_id, :active, :name)
  end
end
