# Public survey endpoint: no auth required. Only active surveys are readable.
class PublicSurveysController < ApplicationController
  skip_before_action :authenticate_user!, raise: false
  skip_before_action :api_user, raise: false
  skip_before_action :set_user, raise: false

  def show
    @survey = Survey.where(status: "active")
    .includes(:background_images, :client_logos, :header_images, :footer_images,
              survey_questions: [:options, :attachments])
    .find_by(id: params[:id])
    unless @survey
      render json: { error: "Survey not found or not available" }, status: :not_found
      return
    end
    render "public_show", formats: :json
  end
end
