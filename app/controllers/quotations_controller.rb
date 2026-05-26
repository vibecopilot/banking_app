class QuotationsController < ApplicationController
  include UserExt
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_quotation, only: %i[show update destroy decide visit start_work complete_work generate_certificate download_certificate]

  def index
    @quotations = Quotation.where(site_id: @user.current_site_id)
                           .includes(:quotation_lines, :quotation_histories)
                           .order(created_at: :desc)
                           .paginate(page: params[:page], per_page: params[:per_page] || 50)
    render json: {
      quotations: @quotations.map { |q| quotation_json(q) },
      total_count: @quotations.total_entries,
      current_page: @quotations.current_page,
      total_pages: @quotations.total_pages,
    }
  end

  def show
    render json: { quotation: quotation_json(@quotation) }
  end

  def create
    @quotation = Quotation.new(quotation_params)
    @quotation.site_id = @user.current_site_id
    @quotation.created_by = @user.full_name

    if @quotation.save
      render json: { quotation: quotation_json(@quotation) }, status: :created
    else
      render json: { error: @quotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @quotation.update(quotation_params)
      render json: { quotation: quotation_json(@quotation) }
    else
      render json: { error: @quotation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @quotation.destroy
    head :no_content
  end

  def decide
    new_status = params[:status]
    return render json: { error: "Status required" }, status: :unprocessable_entity unless new_status

    ActiveRecord::Base.transaction do
      @quotation.quotation_histories.create!(action: "Marked #{new_status}", actor: @user.full_name)
      @quotation.update!(status: new_status)
    end

    render json: { quotation: quotation_json(@quotation) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def visit
    return render json: { error: "Quotation is not approved" }, status: :unprocessable_entity unless @quotation.status == "approved"

    ActiveRecord::Base.transaction do
      @quotation.update!(visited_at: Time.current, visited_by: @user.full_name, status: "visited")
      @quotation.quotation_histories.create!(action: "Site visited by #{@user.full_name}", actor: @user.full_name)
    end

    render json: { quotation: quotation_json(@quotation) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def start_work
    return render json: { error: "Site must be visited first" }, status: :unprocessable_entity unless @quotation.status == "visited"

    ActiveRecord::Base.transaction do
      @quotation.update!(work_started_at: Time.current, status: "in_progress")
      @quotation.quotation_histories.create!(action: "Work started by #{@user.full_name}", actor: @user.full_name)
    end

    render json: { quotation: quotation_json(@quotation) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def complete_work
    return render json: { error: "Work not yet started" }, status: :unprocessable_entity unless @quotation.status == "in_progress"

    ActiveRecord::Base.transaction do
      @quotation.update!(work_completed_at: Time.current, work_notes: params[:work_notes], status: "completed")
      @quotation.quotation_histories.create!(action: "Work completed by #{@user.full_name}", actor: @user.full_name)
    end

    render json: { quotation: quotation_json(@quotation) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def generate_certificate
    return render json: { error: "Work not yet completed" }, status: :unprocessable_entity unless @quotation.status == "completed"

    certificate = @quotation.completion_certificates.create!(
      notes: params[:notes],
      recipients: params[:recipients] || [{ role: "Zonal Admin Team" }, { role: "Request Initiator" }].to_json
    )

    @quotation.update!(status: "certificate_shared")
    @quotation.quotation_histories.create!(action: "Completion certificate #{certificate.certificate_number} generated", actor: @user.full_name)

    render json: { quotation: quotation_json(@quotation), certificate: certificate_json(certificate) }
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def download_certificate
    certificate = @quotation.completion_certificates.find(params[:certificate_id])
    html = render_to_string(template: "completion_certificates/show", layout: false, locals: { certificate: certificate, quotation: @quotation })
    pdf = WickedPdf.new.pdf_from_string(html, orientation: "Landscape", page_size: "A4")
    send_data pdf, filename: "#{certificate.certificate_number}.pdf", type: "application/pdf"
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_quotation
    @quotation = Quotation.includes(:quotation_lines, :quotation_histories, :completion_certificates).find(params[:id])
  end

  def quotation_params
    params.require(:quotation).permit(
      :ticket_id, :vendor_id, :tax_pct, :discount_pct, :status, :version, :notes,
      :work_notes,
      quotation_lines_attributes: %i[id description qty rate _destroy],
      quotation_histories_attributes: %i[id action actor _destroy],
    )
  end

  def quotation_json(q)
    {
      id: "QT-#{q.id.to_s.rjust(4, '0')}",
      apiId: q.id,
      ticketId: q.ticket_id || "",
      vendorId: q.vendor_id&.to_s,
      taxPct: q.tax_pct&.to_f || 18,
      discountPct: q.discount_pct&.to_f || 0,
      status: q.status || "draft",
      version: q.version || 1,
      notes: q.notes || "",
      createdBy: q.created_by || "",
      totalAmount: q.total_amount&.to_f || 0.0,
      createdAt: q.created_at&.iso8601 || "",
      visitedAt: q.visited_at&.iso8601,
      visitedBy: q.visited_by,
      workStartedAt: q.work_started_at&.iso8601,
      workCompletedAt: q.work_completed_at&.iso8601,
      workNotes: q.work_notes,
      lines: q.quotation_lines.map { |l|
        { id: "L-#{l.id}", description: l.description || "", qty: l.qty || 1, rate: l.rate&.to_f || 0 }
      },
      history: q.quotation_histories.map { |h|
        { ts: h.created_at&.iso8601 || "", action: h.action || "", actor: h.actor || "" }
      },
      certificates: q.completion_certificates.map { |c| certificate_json(c) },
    }
  end

  def certificate_json(c)
    {
      id: c.id,
      certificateNumber: c.certificate_number,
      issuedAt: c.issued_at&.iso8601,
      notes: c.notes,
      recipients: c.recipients,
    }
  end
end
