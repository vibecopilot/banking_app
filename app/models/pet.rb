class Pet < ApplicationRecord
  has_one :pet_dp , -> {where(relation: "PetProfile")}, class_name: "Attachfile", foreign_key: :relation_id
  belongs_to :user
  has_many :pets_images, -> { where(relation: "PetsImage") }, class_name: "Attachfile", foreign_key: 'relation_id'
  belongs_to :approved_by , class_name: "User", foreign_key: :approved_by_id, optional: true

  enum is_approved: { pending: "pending", approved: "approved", rejected: "rejected" }

  after_create :notify_admins_for_approval

  private

  def notify_admins_for_approval
    return unless user.present?

    site_id = user.current_site_id
    return unless site_id.present?

    site_admins = User.where(current_site_id: site_id, user_type: "pms_admin")

    site_admins.each do |admin|
      sendata = {
        title: "New Pet Added To Society",
        message: "New Pet: #{pet_name} has been added by #{user.full_name} requires approval.",
        ntype: "PET-APPROVAL",
        user_id: admin.id,
        company_id: Site.find_by(id: site_id)&.company_id,
        record_id: id
      }
      devices = UserDevice.where(user_id: admin.id)
      PushNotification.push_to_devices( devices, sendata)
    end
  end
end
