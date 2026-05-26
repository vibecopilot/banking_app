class ApplicationController < ActionController::Base
  include UserExt
  protect_from_forgery with: :exception, if: :check_html_format
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  rescue_from CanCan::AccessDenied do |exception|
  	flash[:error] = "Access denied."
  	redirect_to root_url
  end
  
  protected
    def after_sign_in_path_for(resource)
      if current_user.present?
        current_user.update(api_key: SecureRandom.hex(24)) if !current_user.api_key.present?
      else
        # redirect_to "/pms/complaints"
        redirect_to root_url
      end
  		"/pms/complaints"
  	end

    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: [:firstname, :lastname, :email, :password])
    end
end
