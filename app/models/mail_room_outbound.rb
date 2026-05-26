class MailRoomOutbound < ApplicationRecord
	belongs_to :vendor
	belongs_to :user, class_name: 'User', foreign_key: 'sender_id'
end
