class AwsController < ApplicationController

  # require 'sinatra'
  require 'aws-sdk'
  # require 'dotenv'
  # Dotenv.load

  require 'bucket'
  require 'recognition'

  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :find_user, only: [:update, :destroy]

  def add_user_face
    RecognitionProcessor.new(collection_id: 'vibefms').add_user_face(bucket_name: 'vibeface', face: params[:face], user_id: params[:user_id])
    if params[:web].present?
      redirect_to "/user_attendances/#{params[:user_id]}"
    else
      render json: {"code": 200, "message": "success"}
    end
  end

  def recognize
  	# response = Recognition.new(bucket: Bucket.new(name: 'user-face')).recognize(request.body.read.to_s)
    begin    
    response = RecognitionProcessor.new(collection_id: params[:collection_id]).compare_faces_with_file(params[:face])
	  if response.face_matches.count == 0
	    render json: { "code": 404,
	      "message": "No faces were recognized..."
	    }
	  else
        uid = response.face_matches[0].face.external_image_id
        @user = User.find_by_id(uid)
        @attendance = @user.attendances.where("DATE(punched_in_at) = ?", Date.today).first
        if @attendance.present?
          @attendance.update_attributes(punched_out_at: Time.now)
          message = "Punched Out successfully"
        else
          @attendance = @user.attendances.build(attendance_params)
          @attendance.punched_in_at = Time.now
          message = "Punched In successfully"
        end
        @attendance.resource_type = "Site"
        @attendance.resource_id = @user.current_site_id || @user.sites.try(:first).try(:id)
        @attendance.save
	    render json: {
	      id: uid,
	      confidence: response.face_matches[0].face.confidence,
	      message: message || "Rekognition success"
	    }
	  end
    rescue StandardError => e
      render json: { "code": 404,
        "message": "No faces were found..."
      }
    end
  end

  def attendance_params
    params.permit(:attendance_of_id, :attendance_of_type, :resource_id, :resource_type, :punched_in_at, :punched_out_at, :work_log, :seat_booking_slot_id)
  end

end