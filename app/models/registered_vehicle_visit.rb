class RegisteredVehicleVisit < ApplicationRecord
  belongs_to :registered_vehicle
  belongs_to :user, class_name: "User", foreign_key: :created_by_id, optional: true

  validate :only_one_open_visit, on: :create
  after_commit :change_status_in_vehicle, on: %i[create update]

  private

  def change_status_in_vehicle
    return unless registered_vehicle.present?

    status =
      if check_out.present?
        "OUT"
      elsif check_in.present?
        "IN"
      else
        nil
      end

    return if status.blank?

    registered_vehicle.update_columns(vehicle_in_out: status)
  end

  def only_one_open_visit
    if RegisteredVehicleVisit.exists?(
      registered_vehicle_id: registered_vehicle_id,
      check_out: nil
    )
      errors.add(:base, "Vehicle already checked in")
    end
  end
end
