class AttachfilesController < ApplicationController
  before_action :set_attachfile, only: [:show, :edit, :update, :destroy]

  # GET /attachfiles
  # GET /attachfiles.json
  def index
    @attachfiles = Attachfile.all
  end

  # GET /attachfiles/1
  # GET /attachfiles/1.json
  def show
  end

  # GET /attachfiles/new
  def new
    @attachfile = Attachfile.new
  end

  # GET /attachfiles/1/edit
  def edit
  end

  # POST /attachfiles
  # POST /attachfiles.json
  def create
    @attachfile = Attachfile.new(attachfile_params)

    respond_to do |format|
      if @attachfile.save
        format.html { redirect_to @attachfile, notice: 'Attachfile was successfully created.' }
        format.json { render :show, status: :created, location: @attachfile }
      else
        format.html { render :new }
        format.json { render json: @attachfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /attachfiles/1
  # PATCH/PUT /attachfiles/1.json
  def update
    respond_to do |format|
      if @attachfile.update(attachfile_params)
        format.html { redirect_to @attachfile, notice: 'Attachfile was successfully updated.' }
        format.json { render :show, status: :ok, location: @attachfile }
      else
        format.html { render :edit }
        format.json { render json: @attachfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attachfiles/1
  # DELETE /attachfiles/1.json
  def destroy
    @attachfile.destroy
    respond_to do |format|
      format.html { redirect_to attachfiles_url, notice: 'Attachfile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attachfile
      @attachfile = Attachfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attachfile_params
      params.require(:attachfile).permit(:relation, :relation_id, :image, :active)
    end
end
