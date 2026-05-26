module UserExt
	def check_html_format
		request.format.html?
	end
	def set_user
    if request.headers["Authorization"].present?
      @user = User.find_by(api_key: request.headers["Authorization"])
    elsif params.has_key?(:token)
  		@user = params.has_key?(:token) ? User.find_by(api_key: params[:token]) : current_user
    end
  	unless @user
    	render json: {"code":401, "error":"Not Authorised"}
  	end
    if params[:wv].present?
      sign_in(@user)
      current_user = @user
    end
	end
	def check_user
    if params[:wv].present?
      return false
    else 
      return request.format.html? || request.format.xls? || request.format.csv?
    end
  end

   def api_user
      if request.headers["Authorization"].present?
        @user = User.find_by(api_key: request.headers["Authorization"])
      elsif params.has_key?(:token)
        @user = params.has_key?(:token) ? User.find_by(api_key: params[:token]) : current_user
      else
        @user = current_user
      end
      User.current = @user
      current_user = @user
      current_user = @user
      unless @user
        render json: {"code":401, "error":"Not Authorised"}
      end
    puts "-----uid---#{@user.try(:id)}"
  end
end