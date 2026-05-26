class PetsController < ApplicationController
  before_action :set_pet, only: %i[ show edit update destroy ]

  # GET /pets or /pets.json
  def index
    @q = Pet.ransack(params[:q]).result
    @pets = @q.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 100)
  end

  # GET /pets/1 or /pets/1.json
  def show
  end

  # GET /pets/new
  def new
    @pet = Pet.new
  end

  # GET /pets/1/edit
  def edit
  end

  def pending_approvals
    site_id = @user.current_site_id || params[:site_id]
    @pets = Pet.joins(:user).where(users: {current_site_id: site_id}).where(is_approved: nil).order(created_at: :desc)

    respond_to do |format|
      format.html {render layout: 'basic'}
      format.json { render json: @pets.as_json(include: :user) }
    end
  end

  def approve
    return unless params[:is_approved].to_s == "approved"
    @pet.approved!
    @pet.update_columns(
      approved_at: Time.zone.now,
      approved_by_id: current_user.id
    )
    notify_pet_owner("approved")

    respond_to do |format|
      format.html do
        redirect_to pending_approvals_pets_path,
          notice: "Pet was successfully approved."
      end
      format.json { render json: { message: "Pet Approved" }, status: :ok }
    end
  end

  def reject
    return unless params[:is_approved].to_s == "rejected"
    @pet.rejected!
    @pet.update!(
      # is_approved: "rejected",
      approved_at: Time.zone.now,
      approved_by_id: current_user.id,
      rejection_reason: params[:rejection_reason]
    )

    notify_pet_owner("rejected")
    respond_to do |format|
      format.html { redirect_to pending_approvals_pets_path, notice: "Pet was successfully rejected." }
      format.json { render json: {message: "Pet Rejected"}, status: :ok }
    end
  end

  # POST /pets or /pets.json
  def create
    @pet = Pet.new(pet_params)
    respond_to do |format|
      if @pet.save
        pet_details = params.dig(:pet, :pet_details)
        if pet_details.present?
          # Multiple Images
          if pet_details[:pet_images].present?
            pet_details[:pet_images].each do |doc|
              Attachfile.create!(
                active: 1,
                relation: "PetsImage",
                relation_id: @pet.id,
                image: doc
              )
            end
          end

          # Profile Image
          if pet_details[:profile_image].present?
            Attachfile.create!(
              active: 1,
              relation: "PetProfile",
              relation_id: @pet.id,
              image: pet_details[:profile_image]
            )
          end
        end
        format.html { redirect_to @pet, notice: "Pet was successfully created." }
        format.json { render :show, status: :created, location: @pet }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /pets/1 or /pets/1.json
  def update
    respond_to do |format|
      if @pet.update(pet_params)
        # Define pet_details so the code below works
        pet_details = params.dig(:pet, :pet_details)

        if pet_details.present?
          # Replace profile image
          if pet_details[:pet_images].present?
            pet_details[:pet_images].each do |doc|
              Attachfile.create!(
                active: 1,
                relation: "PetsImage",
                relation_id: @pet.id,
                image: doc
              )
            end
          end

          # Profile Image
          if pet_details[:profile_image].present?
            Attachfile.create!(
              active: 1,
              relation: "PetProfile",
              relation_id: @pet.id,
              image: pet_details[:profile_image]
            )
          end
        end

        format.html { redirect_to @pet, notice: "Pet was successfully updated." }
        format.json { render :show, status: :ok, location: @pet }
      else # This else now correctly belongs to the 'if @pet.update'
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/1 or /pets/1.json
  def destroy
    @pet.destroy
    respond_to do |format|
      format.html { redirect_to pets_url, notice: "Pet was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_pet
    @pet = Pet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def pet_params
    params.require(:pet).permit(:user_id ,:pet_name, :owner_mobile_no, :pet_breed, :gender, :colour, :age, :dob, :is_pet_transfered, :brought, :stray_pet_adopted, :whether_brought_from_current_city, :pet_born_to_owner_dog,:is_approved,
                                :approved_at,
                                :rejection_reason,
                                :approved_by_id,)
  end



  def notify_pet_owner(status)
    return unless @pet.user.present?
    sendata = {
      title: "Pet #{status.capitalize}",
      message: "Your pet #{pet_name} has been #{status}.",
      ntype: "PET-APPROVAL",
      user_id: @pet.user.id,
      company_id: @pet.user.site&.company_id,
      record_id: @pet.id
    }
    devices = UserDevice.where(user_id: @pet.user.id)
    PushNotification.push_to_devices( devices, sendata)
  end
end
