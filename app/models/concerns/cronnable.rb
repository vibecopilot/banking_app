module Cronnable
  extend ActiveSupport::Concern

  included do
    has_one :cron_setting, as: :cronnable, dependent: :destroy
    accepts_nested_attributes_for :cron_setting
  end
end