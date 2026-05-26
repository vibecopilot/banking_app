class ForumsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_forum, only: %i[ show edit update destroy hide unhide report share toggle_like unsave toggle_visibility]
  before_action :check_admin_access, only: [:create, :edit, :update, :destroy]

  # GET /forums or /forums.json
  def index
    @q = Forum.ransack(params[:q])
    base_scope = @q.result.joins(:creator)
                      .where(users: { current_site_id: @user.current_site_id })
                      .preload(:creator, :forum_comments, :forum_documents, :forum_profile, 
                               forum_comments: :user, likes: :user)
    @forums = params[:show_all] == 'true' ? base_scope.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 50) : base_scope.visible.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 50)
  end


  # GET /forums or /forums/1.json
  def visibility_status
    @q = Forum.ransack(params[:q])
    visible_forums = @q.result.joins(:creator)
                          .where(users: { current_site_id: @user.current_site_id })
                          .preload(:creator, :forum_comments, :forum_documents, :forum_profile,
                                   forum_comments: :user, likes: :user)
                          .visible
    hidden_forums = @q.result.joins(:creator)
                         .where(users: { current_site_id: @user.current_site_id })
                         .preload(:creator, :forum_comments, :forum_documents, :forum_profile,
                                  forum_comments: :user, likes: :user)
                         .hidden

    # Rendering both visible and hidden forums with the forum.json.jbuilder template
    render json: {
      visible_forums: visible_forums.map { |forum| render_forum_json(forum) },
      hidden_forums: hidden_forums.map { |forum| render_forum_json(forum) }
    }
  end


  # GET /forums/1 or /forums/1.json
  def show
  end

  # GET /forums/new
  def new
    @forum = Forum.new
  end

  # GET /forums/1/edit
  def edit
  end

  # POST /forums or /forums.json
  def create
    @forum = Forum.new(forum_params)
    @forum.created_by_id = @user.id

    respond_to do |format|
      if @forum.save
        #  if params[:profile_image].present? 
        #     Attachfile.create(image: params[:profile_image], relation: "ForumProfile", relation_id: @forum.id, active: 1)
        # end
        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "ForumDocument", relation_id: @forum.id, active: 1)
          end
        end
        format.html { redirect_to @forum, notice: "Forum was successfully created." }
        format.json { render :show, status: :created, location: @forum }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @forum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /forums/1 or /forums/1.json
  def update
    respond_to do |format|
      if @forum.update(forum_params)
        if params[:attachfiles].present? 
          params[:attachfiles].each do |doc|
            Attachfile.create(image: doc, relation: "ForumDocument", relation_id: @forum.id, active: 1)
          end
        end
        format.html { redirect_to @forum, notice: "Forum was successfully updated." }
        format.json { render :show, status: :ok, location: @forum }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @forum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /forums/1 or /forums/1.json
  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_url, notice: "Forum was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  # POST /forums/:id/hide
  def hide
    if @forum.update(visible: false)
      render json: { success: true, message: "Forum is now hidden." }
    else
      render json: { success: false, errors: @forum.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /forums/:id/unhide
  def unhide
    if @forum.update(visible: true)
      render json: { success: true, message: "Forum is now visible." }
    else
      render json: { success: false, errors: @forum.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # hide and unhide are combined so above 2 methods are not in use
  # POST /forums/:id/toggle_visibility
  def toggle_visibility
    new_visibility = !@forum.visible # Toggle the current visibility status

    if @forum.update(visible: new_visibility)
      message = new_visibility ? "Forum is now visible." : "Forum is now hidden."
      render json: { success: true, message: message }
    else
      render json: { success: false, errors: @forum.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def report
    report = @forum.reports.new(reason: params[:reason], reported_by_id: params[:reported_by])
    attachments = Attachfile.where("relation = 'ForumDocument' AND relation_id = ?", @forum.id)

    if report.save
      render json: {
        message: "Forum reported successfully.",
        report: {
          id: report.id,
          reason: report.reason,
          created_at: report.created_at,
          reported_by: {
            id: report.reported_by.id,
            fullname: report.reported_by.fullname
          },
          forum: {
            id: @forum.id,
            thread_title: @forum.thread_title,
            thread_category: @forum.thread_category,
            thread_tags: @forum.thread_tags,
            thread_creators: @forum.thread_creators,
            date: @forum.date,
            thread_description: @forum.thread_description,
            created_by_id: @forum.created_by_id,
            created_at: @forum.created_at,
            updated_at: @forum.updated_at,
            visible: @forum.visible,
            created_by_name: User.find_by(id: @forum.created_by_id)&.slice(:firstname, :lastname),
            forum_comments: @forum.forum_comments,
            url: forum_url(@forum, format: :json),
            liked_count: @forum.likes.liked.count,
            unliked_count: @forum.likes.unliked.count,
            comment_count: @forum.forum_comments.count,
            
            # Attachments related to the Forum
            forums_image: attachments.map do |doc|
              {
                id: doc.id,
                relation: doc.relation,
                relation_id: doc.relation_id,
                document: doc.document_url
              }
            end
          }
        }
      }, status: :created
    else
      render json: { error: report.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end



  def unsave
    forum = Forum.find(params[:id])   # Forum ID is typically passed in the URL

    saved_forum = @user.saved_forums.find_by(forum_id: forum.id)

    if saved_forum
      saved_forum.destroy
      render json: { message: 'Forum removed from saved list' }, status: :ok
    else
      render json: { error: 'Forum not found in saved list' }, status: :not_found
    end
  end


# Save a forum
  def save_for_later
    forum = Forum.find(params[:id])

    if @user.saved_forums.create(forum: forum)
      render json: { message: "Forum saved successfully." }, status: :created
    else
      render json: { error: "You have already saved this forum." }, status: :unprocessable_entity
    end
  end

  def saved_forums
    saved_forums = @user.saved_forums.includes(forum: :creator)

    render json: saved_forums.map { |saved_forum|
      forum = saved_forum.forum
      attachments = Attachfile.where("relation = 'ForumDocument' AND relation_id = ?", forum.id)

      {
        id: saved_forum.id,
        created_at: saved_forum.created_at,
        forum: {
          id: forum.id,
          thread_title: forum.thread_title,
          thread_category: forum.thread_category,
          thread_tags: forum.thread_tags,
          thread_creators: forum.thread_creators,
          thread_description: forum.thread_description,
          comment_count: forum.forum_comments.count,
          likes_count: forum.likes.count,
          visible: forum.visible,
           creator: forum.creator ? {
              id: forum.creator.id,
              name: forum.creator.full_name
            } : nil,
                forums_image: attachments.map do |attachment|
            {
              id: attachment.id,
              relation: attachment.relation,
              relation_id: attachment.relation_id,
              document: attachment.document_url
            }
          end
        }
      }
    }
  end

  # Share a forum with another user
  def share
    receiver = User.find_by(id: params[:receiver_id])

    if receiver.nil? || @forum.nil?
      render json: { error: "Invalid forum or receiver" }, status: :not_found and return
    end

    shared_forum = SharedForum.new(
      forum: @forum,
      sender: @user,
      receiver: receiver
    )

    if shared_forum.save
      render json: { message: "Forum shared successfully." }, status: :created
    else
      render json: { error: shared_forum.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  # List forums shared with the current user
  def shared_with_me
    shared_forums = SharedForum.where(receiver: @user).includes(:forum, :sender)
    render json: shared_forums.as_json(
      include: {
        forum: { only: [:id, :title] },
        sender: { only: [:id, :name, :email] }
      }
    ), status: :ok
  end

  def toggle_like
    like = @forum.likes.find_by(user: @user)

    if like
      # Toggle the status
      like.update(status: like.status == 'liked' ? 'unliked' : 'liked')
      render json: {
        success: true,
        message: "Toggled like status",
        liked_count: @forum.likes.liked.count,
        unliked_count: @forum.likes.unliked.count
      }
    else
      # Create a new like with 'liked' status
      @forum.likes.create(user: @user, status: 'liked')
      render json: {
        success: true,
        message: "Liked the forum",
        liked_count: @forum.likes.liked.count,
        unliked_count: @forum.likes.unliked.count
      }
    end
  end

  private

    def render_forum_json(forum)
      # Use Jbuilder to render the forum's JSON from the '_forum.json.jbuilder' template
      JSON.parse(render_to_string(partial: 'forums/forum', locals: { forum: forum }))
    end
    # Check access: Only allow admin to do CRUD
    def check_admin_access
      unless @user.pms_admin?
        render json: { error: "You don't have permission to perform this action." }, status: :forbidden
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_forum
      @forum = Forum.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def forum_params
      params.require(:forum).permit(:thread_title, :thread_category, :thread_tags, :thread_creators, :date, :thread_description, :created_by_id)
    end
end
