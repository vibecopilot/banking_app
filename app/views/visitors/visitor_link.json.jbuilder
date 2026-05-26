json.id               @visitor.id
json.name             @visitor.name
json.otp              @visitor.otp
json.contact_no       @visitor.contact_no
json.purpose          @visitor.purpose
json.expected_date    @visitor.expected_date
json.expected_time    @visitor.expected_time&.strftime("%H:%M:%S")
json.verified         @visitor.verified
json.pass_start_date  @visitor.start_pass&.strftime("%Y-%m-%d")
json.pass_end_date    @visitor.end_pass&.strftime("%Y-%m-%d")
json.site_name 		  @visitor.site&.try(:name)
json.visit_type    	  @visitor.visit_type
json.hosts 			  @visitor.hosts , partial: 'host', as: :a
json.profile_picture  @visitor&.profile_pic&.document_url
json.qr_code          @visitor.qr_code_image&.document_url
json.no_of_goods      @visitor.no_of_goods

if @visitor.visitor_cards.present?
  json.card_id @visitor.visitor_cards.first.card_id
else
  json.card_id nil
end