class ForumCommentsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user

  before_action :set_forum

  # Show all comments for a forum
  def index
    @forum_comments = @forum.forum_comments
    render json: @forum_comments.as_json(methods: [:image_url, :user_fullname])
  end

  # Create a comment for a forum
  def create
    @forum_comment = @forum.forum_comments.build(forum_comment_params)
    @forum_comment.user_id = @user.id
    if @forum_comment.save
      render json: @forum_comment.as_json(methods: [:image_url, :user_fullname]), status: :created
    else
      render json: { errors: @forum_comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Update a specific comment
  def update
    @forum_comment = @forum.forum_comments.find(params[:id])
    if @forum_comment.update(forum_comment_params)
      render json: @forum_comment.as_json(methods: [:image_url]), status: :ok
    else
      render json: { errors: @forum_comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Delete a specific comment
  def destroy
    @forum_comment = @forum.forum_comments.find(params[:id])
    @forum_comment.destroy
    render json: { message: 'Comment successfully deleted.' }
  end

  private

  # Find the parent forum
  def set_forum
    @forum = Forum.find(params[:forum_id])
  end

  # Permit comment and image parameters
  def forum_comment_params
    params.require(:forum_comment).permit(:comment, :image)
  end
end