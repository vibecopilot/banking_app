class ContactBooksController < ApplicationController
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_contact_book, only: %i[ show edit update destroy ]

  # GET /contact_books or /contact_books.json
  def index
    @q = ContactBook.ransack(params[:q])
    base_scope = @q.result.includes(:generic_info, :generic_sub_info, :logo, :attachments).where(site_id: @user.current_site_id).order(created_at: :desc)
    @contact_books = base_scope.page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /contact_books/1 or /contact_books/1.json
  def show
  end

  # GET /contact_books/new
  def new
    @contact_book = ContactBook.new
  end

  # GET /contact_books/1/edit
  def edit
  end

  # POST /contact_books or /contact_books.json
  def create
    @contact_book = ContactBook.new(contact_book_params)
    @contact_book.site_id = @user.current_site_id

    respond_to do |format|
      if @contact_book.save
        if params[:contact_book][:logo].present?
          params[:contact_book][:logo].each do |doc|
            Attachfile.create!(
              image: doc,
              relation: "ContactBookLogo",
              relation_id: @contact_book.id,
              active: 1
            )
          end
        end

        if params[:contact_book][:attachments].present?
          params[:contact_book][:attachments].each do |doc|
            Attachfile.create!(
              image: doc,
              relation: "ContactBookDocument",
              relation_id: @contact_book.id,
              active: 1
            )
          end
        end

        format.html { redirect_to @contact_book, notice: "Contact book was successfully created." }
        format.json { render :show, status: :created, location: @contact_book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @contact_book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contact_books/1 or /contact_books/1.json
  def update
    respond_to do |format|
      ActiveRecord::Base.transaction do
        if @contact_book.update(contact_book_params)

          # DELETE REMOVED LOGOS
          if params[:removed_logo_ids].present?
            Attachfile.where(
              id: params[:removed_logo_ids],
              relation: "ContactBookLogo",
              relation_id: @contact_book.id
            ).destroy_all
          end

          # DELETE REMOVED DOCUMENTS
          if params[:removed_document_ids].present?
            Attachfile.where(
              id: params[:removed_document_ids],
              relation: "ContactBookDocument",
              relation_id: @contact_book.id
            ).destroy_all
          end

          # ADD NEW LOGOS
          if params[:logo].present?
            params[:logo].each do |doc|
              Attachfile.create!(
                image: doc,
                relation: "ContactBookLogo",
                relation_id: @contact_book.id,
                active: 1
              )
            end
          end

          # ADD NEW DOCUMENTS
          if params[:attachfiles].present?
            params[:attachfiles].each do |doc|
              Attachfile.create!(
                image: doc,
                relation: "ContactBookDocument",
                relation_id: @contact_book.id,
                active: 1
              )
            end
          end

          format.html { redirect_to @contact_book, notice: "Contact book updated successfully." }
          format.json { render :show, status: :ok }
        else
          raise ActiveRecord::Rollback
        end
      end
    rescue
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @contact_book.errors, status: :unprocessable_entity }
    end
  end


  # DELETE /contact_books/1 or /contact_books/1.json
  def destroy
    @contact_book.destroy
    respond_to do |format|
      format.html { redirect_to contact_books_url, notice: "Contact book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_contact_book
    @contact_book = ContactBook.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def contact_book_params
    params.require(:contact_book).permit(:company_name, :contact_person_name, :site_id, :generic_info_id, :generic_sub_info_id, :mobile, :landline_no, :primary_email, :secondary_email, :website, :address, :key_offering, :description, :profile, :status)
  end
end
