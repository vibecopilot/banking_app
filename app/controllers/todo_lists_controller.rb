class TodoListsController < ApplicationController
  include UserExt
  layout 'basic'
  before_action :authenticate_user!, if: :check_user
  before_action :api_user
  before_action :set_user
  before_action :set_todo_list, only: %i[ show edit update destroy ]

  # GET /todo_lists or /todo_lists.json
  def index
    @todo_lists = TodoList.where(site_id: @user.current_site_id).order(created_at: :desc)
  end

  # GET /todo_lists/1 or /todo_lists/1.json
  def show
  end

  # GET /todo_lists/new
  def new
    @todo_list = TodoList.new
  end

  # GET /todo_lists/1/edit
  def edit
  end

  # POST /todo_lists or /todo_lists.json
  def create
    @todo_list = TodoList.new(todo_list_params)

    respond_to do |format|
      if @todo_list.save

        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create!(active: 1, relation: "TodoList", relation_id: @todo_list.id, image: doc)
          end
        end
        format.html { redirect_to @todo_list, notice: "Todo list was successfully created." }
        format.json { render :show, status: :created, location: @todo_list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /todo_lists/1 or /todo_lists/1.json
  def update
    respond_to do |format|
      if @todo_list.update(todo_list_params)
        if params[:attachments].present?
          params[:attachments].each do |doc|
            Attachfile.create!(active: 1, relation: "TodoList", relation_id: @todo_list.id, image: doc)
          end
        end
        format.html { redirect_to @todo_list, notice: "Todo list was successfully updated." }
        format.json { render :show, status: :ok, location: @todo_list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @todo_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /todo_lists/1 or /todo_lists/1.json
  def destroy
    @todo_list.destroy
    respond_to do |format|
      format.html { redirect_to todo_lists_url, notice: "Todo list was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def todo_list_params
    params.require(:todo_list).permit(:title, :status, :relation_id, :relation, :site_id, :start_at, :end_at, :assigned_to, :task_type, :urgent, :repeat, :to_from, :to_date, :time,
                                      :due_date,
                                      :task_description,
                                      dependent_task_ids: [],
                                      working_days: []
                                      )
  end
end
