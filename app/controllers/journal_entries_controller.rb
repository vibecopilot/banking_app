class JournalEntriesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_journal_entry, only: %i[show edit update destroy post cancel]

  # GET /journal_entries or /journal_entries.json
  def index
    @q = JournalEntry.for_site(@user.current_site_id)
    .includes(:unit, :created_by, :journal_entry_lines => :ledger)
    .ransack(params[:q])

    @journal_entries = @q.result
    .order(entry_date: :desc, created_at: :desc)
    .paginate(page: params[:page], per_page: params[:per_page] || 50)

    respond_to do |format|
      format.html
      format.json { render :index }
    end
  end

  # GET /journal_entries/1 or /journal_entries/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :show }
    end
  end

  # GET /journal_entries/new
  def new
    @journal_entry = JournalEntry.new
    @journal_entry.entry_date = Date.current
    @journal_entry.journal_entry_lines.build
  end

  # GET /journal_entries/1/edit
  def edit
  end

  # POST /journal_entries or /journal_entries.json
  def create
    @journal_entry = JournalEntry.new(journal_entry_params)
    if params[:journal_entry][:description].present?
      @journal_entry.narration = params[:journal_entry][:description]
    end
    @journal_entry.site_id = @user.current_site_id
    @journal_entry.created_by = @user
    @journal_entry.entry_type = 'manual'

    respond_to do |format|
      if @journal_entry.save
        format.html { redirect_to journal_entries_path, notice: 'Journal entry was successfully created.' }
        format.json { render :show, status: :created, location: @journal_entry }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @journal_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /journal_entries/1 or /journal_entries/1.json
  def update
    if @journal_entry.status != 'draft'
      respond_to do |format|
        format.html { redirect_to journal_entries_path, alert: 'Cannot edit a posted or cancelled journal entry.' }
        format.json { render json: { error: 'Cannot edit a posted or cancelled journal entry' }, status: :unprocessable_entity }
      end
      return
    end

    if params[:journal_entry][:description].present?
      @journal_entry.narration = params[:journal_entry][:description]
    end

    respond_to do |format|
      if @journal_entry.update(journal_entry_params)
        # Optional inline posting if client sends status=posted
        if params[:status].to_s == 'posted'
          unless @journal_entry.post!(@user)
            return format.json { render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity }
          end
        end
        format.html { redirect_to journal_entries_path, notice: 'Journal entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @journal_entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @journal_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /journal_entries/1 or /journal_entries/1.json
  def destroy
    if @journal_entry.status != 'draft'
      respond_to do |format|
        format.html { redirect_to journal_entries_path, alert: 'Cannot delete a posted journal entry. Please cancel it instead.' }
        format.json { render json: { error: 'Cannot delete a posted journal entry' }, status: :unprocessable_entity }
      end
      return
    end

    @journal_entry.destroy
    respond_to do |format|
      format.html { redirect_to journal_entries_url, notice: 'Journal entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /journal_entries/1/post
  def post
    # binding.pry
    if @journal_entry.post!(@user)
      respond_to do |format|
        format.html { redirect_to journal_entries_path, notice: 'Journal entry was successfully posted.' }
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to journal_entries_path, alert: @journal_entry.errors.full_messages.join(', ') }
        format.json { render json: { errors: @journal_entry.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  # POST /journal_entries/1/cancel
  def cancel
    if @journal_entry.cancel!
      respond_to do |format|
        format.html { redirect_to journal_entries_path, notice: 'Journal entry was successfully cancelled.' }
        format.json { render :show, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to journal_entries_path, alert: 'Failed to cancel journal entry.' }
        format.json { render json: { error: 'Failed to cancel journal entry' }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_journal_entry
    @journal_entry = JournalEntry.find(params[:id])
  end

  def journal_entry_params
    # Extract entry_lines_attributes before permit to avoid Rails trying to find non-existent association
    entry_lines = params[:journal_entry][:entry_lines_attributes]

    # Remove entry_lines_attributes from params before permit to avoid the warning
    filtered_params = params[:journal_entry].except(:entry_lines_attributes)

    permitted = ActionController::Parameters.new(journal_entry: filtered_params)
    .require(:journal_entry)
    .permit(
      :entry_date, :unit_id, :narration, :expense_month, :expense_year, :invoice_number, :invoice_date, :entry_type,
      :reference_id, :reference_type,
      journal_entry_lines_attributes: [:id, :ledger_id, :entry_side, :amount, :description, :unit_id, :_destroy]
    )


    # Support "entry_lines_attributes" with debit/credit format
    if entry_lines.present? && permitted[:journal_entry_lines_attributes].blank?
      line_attrs = []
      entry_lines_array = entry_lines.is_a?(Hash) ? entry_lines.values : entry_lines.to_a
      entry_lines_array.each do |line|
        line = line.to_unsafe_h if line.respond_to?(:to_unsafe_h)
        line = line.with_indifferent_access if line.is_a?(Hash)

        # Handle _destroy flag for existing records
        if line[:_destroy].present? && line[:id].present?
          line_attrs << { id: line[:id], _destroy: line[:_destroy] }
          next
        end

        ledger_id = line[:ledger_id]
        desc = line[:description]
        unit_line_id = line[:unit_id]
        line_id = line[:id]
        debit = line[:debit]
        credit = line[:credit]

        if debit.present? && debit.to_d > 0
          attrs = { ledger_id: ledger_id, entry_side: 'debit', amount: debit, description: desc, unit_id: unit_line_id }
          attrs[:id] = line_id if line_id.present?
          line_attrs << attrs
        end
        if credit.present? && credit.to_d > 0
          attrs = { ledger_id: ledger_id, entry_side: 'credit', amount: credit, description: desc, unit_id: unit_line_id }
          attrs[:id] = line_id if line_id.present?
          line_attrs << attrs
        end
      end
      permitted[:journal_entry_lines_attributes] = line_attrs if line_attrs.any?
    end

    # Support simplified "entries" array (each having ledger_id, debit, credit, description, unit_id)
    if params[:entries].present? && permitted[:journal_entry_lines_attributes].blank?
      line_attrs = []
      params[:entries].each do |line|
        ledger_id = line[:ledger_id] || line['ledger_id']
        desc = line[:description] || line['description']
        unit_line_id = line[:unit_id] || line['unit_id']
        debit = line[:debit] || line['debit']
        credit = line[:credit] || line['credit']

        if debit.present? && debit.to_d > 0
          line_attrs << { ledger_id: ledger_id, entry_side: 'debit', amount: debit, description: desc, unit_id: unit_line_id }
        end
        if credit.present? && credit.to_d > 0
          line_attrs << { ledger_id: ledger_id, entry_side: 'credit', amount: credit, description: desc, unit_id: unit_line_id }
        end
      end
      permitted[:journal_entry_lines_attributes] = line_attrs if line_attrs.any?
    end

    permitted
  end
end
