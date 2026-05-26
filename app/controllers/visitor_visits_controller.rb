class VisitorVisitsController < ApplicationController
  include UserExt
  before_action :api_user, only: [:face_check_in, :face_check_out]
  before_action :set_visitor, except: [:face_check_in, :face_check_out]

  def index
    @q = @visitor.visitor_visits.ransack(params[:q])
    @visitor_visits = @q.result.includes(:visitor).order(created_at: :desc).page(params[:page]).per(params[:per_page] || 20)
    respond_to do |format|
      format.html
      format.json { render 'visitor_visits/check_visitor' }
    end
  end

  def check_visitor
    respond_to do |format|
      if params[:check_in]
        result = check_in
      elsif params[:check_out]
        result = check_out
      else
        result = { error: 'Invalid action. Specify either check_in or check_out.', status: :unprocessable_entity }
      end

      format.html do
        if result[:status] == :created || result[:status] == :ok
          redirect_to visitor_visitor_visits_path(@visitor), notice: result[:notice]
        else
          redirect_to visitor_visitor_visits_path(@visitor), alert: result[:error]
        end
      end
      format.json { render json: result[:data], status: result[:status] }
    end
  end

  def face_check_in
    unless params[:image].present?
      return render json: { error: "Image is required" }, status: :bad_request
    end

    begin
      result = FaceAiService.analyze(params[:image].path)
    rescue StandardError => e
      Rails.logger.error "FaceAiService error: #{e.message}"
      return render json: { error: "Face AI service unavailable" }, status: :service_unavailable
    end

    unless result["success"]
      return render json: { error: result["error"] || "Face detection failed" }, status: :unprocessable_entity
    end

    embedding = result["embedding"]

    # Scope to current site for better performance
    site_id = @user&.current_site_id
    vs = site_id.present? ? Visitor.where(site_id: site_id) : Visitor.all
    visitors_with_embedding = vs.where.not(embedding: [nil, ""])
    bm = nil
    bs = 0.0

    visitors_with_embedding.find_each do |visitor|
      begin
        stored_embedding = JSON.parse(visitor.embedding)
        score = cosine_similarity(embedding, stored_embedding)

        if score > bs
          bs = score
          bm = visitor
        end
      rescue JSON::ParserError
        Rails.logger.warn "Invalid embedding JSON for visitor #{visitor.id}"
        next
      end
    end

    if bs > 0.80
      visitor_visit = bm.visitor_visits.create!(check_in: Time.current)
      bm.update(visitor_in_out: 'IN')

      render json: {
        matched: true,
        visitor_id: bm.id,
        visitor_name: bm.name,
        confidence: bs.round(3),
        visit_id: visitor_visit.id,
        check_in: visitor_visit.check_in
      }, status: :created
    else
      render json: {
        matched: false,
        bs: bs.round(3),
        message: "No matching visitor found with sufficient confidence"
      }, status: :not_found
    end
  end

  def face_check_out
    unless params[:image].present?
      return render json: { error: "Image is required" }, status: :bad_request
    end

    begin
      result = FaceAiService.analyze(params[:image].path)
    rescue StandardError => e
      Rails.logger.error "FaceAiService error: #{e.message}"
      return render json: { error: "Face AI service unavailable" }, status: :service_unavailable
    end

    unless result["success"]
      return render json: { error: result["error"] || "Face detection failed" }, status: :unprocessable_entity
    end

    embedding = result["embedding"]

    # Scope to visitors currently IN
    site_id = @user&.current_site_id
    vs = site_id.present? ? Visitor.where(site_id: site_id) : Visitor.all
    visitors_in = vs.where(visitor_in_out: 'IN').where.not(embedding: [nil, ""])

    bm = nil
    bs = 0.0

    visitors_in.find_each do |visitor|
      begin
        stored_embedding = JSON.parse(visitor.embedding)
        score = cosine_similarity(embedding, stored_embedding)

        if score > bs
          bs = score
          bm = visitor
        end
      rescue JSON::ParserError
        next
      end
    end

    if bs > 0.70
      active_visit = bm.visitor_visits.where(check_out: nil).last

      if active_visit
        active_visit.update!(check_out: Time.current)
        bm.update(visitor_in_out: 'OUT')

        render json: {
          matched: true,
          visitor_id: bm.id,
          visitor_name: bm.name,
          confidence: bs.round(3),
          visit_id: active_visit.id,
          check_in: active_visit.check_in,
          check_out: active_visit.check_out
        }, status: :ok
      else
        render json: {
          error: "Visitor found but no active check-in exists",
          visitor_id: bm.id
        }, status: :unprocessable_entity
      end
    else
      render json: {
        matched: false,
        bs: bs.round(3),
        message: "No matching visitor found with sufficient confidence"
      }, status: :not_found
    end
  end


  private

  def check_in
    check_in_time = params[:check_in].present? ? Time.zone.parse(params[:check_in]) : Time.current
    @visitor_visit = @visitor.visitor_visits.new(check_in: check_in_time)

    if @visitor_visit.save
      @visitor.update(visitor_in_out: 'IN')
      { data: @visitor_visit, status: :created, notice: 'Visitor checked in successfully.' }
    else
      { data: { errors: @visitor_visit.errors.full_messages }, status: :unprocessable_entity, error: @visitor_visit.errors.full_messages.join(", ") }
    end
  end

  def check_out
    @visitor_visit = @visitor.visitor_visits.where(check_out: nil).last

    if @visitor_visit
      check_out_time = params[:check_out].present? ? Time.zone.parse(params[:check_out]) : Time.current
      if @visitor_visit.update(check_out: check_out_time)
        @visitor.update(visitor_in_out: 'OUT')
        { data: @visitor_visit, status: :ok, notice: 'Visitor checked out successfully.' }
      else
        { data: { errors: @visitor_visit.errors.full_messages }, status: :unprocessable_entity, error: @visitor_visit.errors.full_messages.join(", ") }
      end
    else
      { data: { error: 'No active visit found.' }, status: :not_found, error: 'No active visit found.' }
    end
  end

  def set_visitor
    @visitor = Visitor.find(params[:visitor_id])
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to visitors_path, alert: 'Visitor not found.' }
      format.json { render json: { error: 'Visitor not found' }, status: :not_found }
    end
  end

  def cosine_similarity(vec1, vec2)
    return 0.0 if vec1.nil? || vec2.nil? || vec1.empty? || vec2.empty?

    dot_product = vec1.zip(vec2).map { |a, b| a * b }.sum
    magnitude1 = Math.sqrt(vec1.map { |x| x**2 }.sum)
    magnitude2 = Math.sqrt(vec2.map { |x| x**2 }.sum)

    return 0.0 if magnitude1.zero? || magnitude2.zero?

    dot_product / (magnitude1 * magnitude2)
  end
end
