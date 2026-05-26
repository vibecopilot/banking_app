module Api
  module V1
    class AmenitySlotConfigsController < ApplicationController
      before_action :set_amenity, only: [:show, :update, :generate_slots]

      # GET /api/v1/amenity_slot_configs/:id
      def show
        render json: slot_config_json(@amenity), status: :ok
      end

      # PUT /api/v1/amenity_slot_configs/:id
      def update
        if @amenity.update(slot_config_params)
          render json: {
            success: true,
            message: "Slot configuration updated successfully",
            data: slot_config_json(@amenity)
          }, status: :ok
        else
          render json: {
            success: false,
            errors: @amenity.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/amenity_slot_configs/:id/generate_slots
      def generate_slots
        result = @amenity.generate_slots!
        if result[:success]
          render json: {
            success: true,
            message: "Slots generated successfully",
            slots_created: result[:slots_created],
            slots: result[:slots].map { |slot| format_slot(slot) }
          }, status: :created
        else
          render json: {
            success: false,
            error: result[:error]
          }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/amenity_slot_configs/valid_durations
      def valid_durations
        render json: {
          valid_slot_durations: AmenitySlotGenerator::VALID_SLOT_DURATIONS
        }, status: :ok
      end

      private

      def set_amenity
        @amenity = Amenity.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: "Amenity not found" }, status: :not_found
      end

      def slot_config_params
        params.require(:amenity_slot_config).permit(
          :concurrent_slot,
          :slot_by,
          :wrap_time,
          :slot_start_time,
          :slot_end_time,
          :start_time,
          :end_time,
          :break_time_start,
          :break_time_end
        ).tap do |whitelisted|
          # Map start_time to slot_start_time if provided
          whitelisted[:slot_start_time] = whitelisted.delete(:start_time) if whitelisted[:start_time].present?
          # Map end_time to slot_end_time if provided
          whitelisted[:slot_end_time] = whitelisted.delete(:end_time) if whitelisted[:end_time].present?
        end
      end

      def slot_config_json(amenity)
        {
          id: amenity.id,
          slot_start_time: amenity.slot_start_time,
          slot_end_time: amenity.slot_end_time,
          break_time_start: amenity.break_time_start,
          break_time_end: amenity.break_time_end,
          concurrent_slot: amenity.concurrent_slot,
          slot_by: amenity.slot_by,
          wrap_time: amenity.wrap_time,
          slots_count: amenity.amenity_slots.count
        }
      end

      def format_slot(slot)
        {
          id: slot.id,
          amenity_id: slot.amenity_id,
          start_time: "#{slot.start_hr.to_s.rjust(2, '0')}:#{slot.start_min.to_s.rjust(2, '0')}",
          end_time: "#{slot.end_hr.to_s.rjust(2, '0')}:#{slot.end_min.to_s.rjust(2, '0')}",
          display: slot.twelve_hr_slot
        }
      end
    end
  end
end
