class LikesController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user	
  before_action :set_forum ,only: %i[create destroy]
  before_action :set_other_project, only: %i[create_other_project_like delete_other_project_like]


  def create
    like = @forum.likes.new(user: @user)
    if like.save
      render json: { success: true, like_count: @forum.likes.count , user_id: @user.id}
    else
      render json: { success: false, errors: like.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    like = @forum.likes.find_by(user: @user)
    if like&.destroy
      render json: { success: true, like_count: @forum.likes.count }
    else
      render json: { success: false, message: "Unable to unlike." }, status: :unprocessable_entity
    end
  end
  def delete_other_project_like

    like = @other_project.likes.find_by(user: @user)
    if like&.destroy
      render json: { success: true, like_count: @other_project.likes.count }
    else
      render json: { success: false, message: "Unable to unlike." }, status: :unprocessable_entity
    end
  end

 def create_other_project_like
  # binding.pry
  if @other_project
    like = Like.create(
      resource_id: @other_project.id,  # Use resource_id for polymorphic association
      resource_type: "OtherProject",  # Set resource_type explicitly
      user_id: @user.id,              # Associate the like with the current user
      status: params[:status]         # Set the status from params
    )
    if like.persisted?
      render json: { success: true, like_count: Like.where(resource_id: @other_project.id, resource_type: "OtherProject").count, user_id: @user.id }
    else
      render json: { success: false, errors: like.errors.full_messages }, status: :unprocessable_entity
    end
  else
    render json: { success: false, message: "OtherProject not found." }, status: :not_found
  end
end


  private

  def set_forum
    @forum = Forum.find(params[:forum_id])
  end	
  def set_other_project
    @other_project = OtherProject.find_by(id: params[:other_project_id])
    unless @other_project
      render json: { success: false, message: "OtherProject not found." }, status: :not_found
    end
  end
end
