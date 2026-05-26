module Admin
  class ForumReportsController < ApplicationController
  	include UserExt
    before_action :authenticate_user!, if: :check_user
    before_action :api_user
    before_action :set_user

    def index
      if @user.pms_admin?
        # Fetch the reports, including the associated forum and its creator
        @reports = ForumReport.includes(forum: [:creator]).order(created_at: :desc)

        reports_data = @reports.map do |report|
          forum = report.forum
          creator = forum.creator

          # Fetch all images associated with the forum (e.g., ForumDocument)
          forum_images = Attachfile.where("relation = 'ForumDocument' AND relation_id = ?", forum.id).map do |attachment|
            attachment.document_url
          end

          # Fetch profile image of the forum (if available)
          forum_profile_image = Attachfile.find_by("relation = 'ForumProfile' AND relation_id = ?", forum.id)&.document_url

          # Additional fields for likes, comments
          liked_count = forum.likes.liked.count
          unliked_count = forum.likes.unliked.count
          comment_count = forum.forum_comments.count

          {
            id: report.id,
            reason: report.reason,
            created_at: report.created_at,
            forum: {
              id: forum.id,
              thread_title: forum.thread_title,
              thread_category: forum.thread_category,
              thread_tags: forum.thread_tags,
              thread_creators: forum.thread_creators,
              date: forum.date,
              thread_description: forum.thread_description,
              created_by_id: forum.created_by_id,
              created_at: forum.created_at,
              updated_at: forum.updated_at,
              visible: forum.visible,
              created_by_name: "#{creator.firstname} #{creator.lastname}",
              forum_profile_image: forum_profile_image,
              forum_images: forum_images, # This will be an array of URLs for the forum images
              liked_count: liked_count,
              unliked_count: unliked_count,
              comment_count: comment_count
            },
            reported_by: { id: report.reported_by.id , user_name: report.reported_by&.full_name }
          }
        end

        render json: reports_data
      else
        render json: { message: "Access denied. Only admins can view forum reports." }, status: :forbidden
      end
    end



    def take_action
     if @user.pms_admin?
       
      report = ForumReport.find(params[:id])
      forum = report.forum

      case params[:action_type]
      when 'hide'
        forum.update(visible: false)
      when 'delete'
        forum.destroy
      end

      report.destroy # Optionally remove the report after action
      render json: { message: 'Action taken successfully.' }
     else
        render json: { message: "Access denied. Only admins can view forum reports." }, status: :forbidden
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Report not found.' }, status: :not_found
    end
  end
end
