class ApplicationController < ActionController::Base

  include SslRequirement

  protect_from_forgery
  layout 'application'

  def ssl_required?
    #return false if request.remote_ip == "127.0.0.1" || RAILS_ENV == 'test'
    return false if Rails.env == 'test' || Rails.env == 'development'
    super
  end

  def invalid_route
    redirect_to('/visualize', :notice => "Sorry, your request was not recognized")
  end

  def establish_cookie
    #Can customize expiry time and bundle values into one cookie with code below 
    #cookies[:jbb1] = { :value => {:one => "hi", :two => "hello"},
    #                   :expires => Time.now.utc + 3.months
    #                 }
    #cookies[:jbb1][:one] = "hi 2"
    
    begin
      if cookies[:user_zip].length < 3 || cookies[:lon].length < 3
        cookies.permanent[:user_zip] = cookies[:user_just_zip] = HOME_ZIP
        cookies.permanent[:lat] = HOME_LAT
        cookies.permanent[:lon] = HOME_LON
        cookies.permanent[:radius] = DEFAULT_RADIUS
        cookies.permanent[:show_instructions] = "true"
      end
    rescue #if no cookie, we will land here when trying to access a nil object in begin area
      cookies.permanent[:user_zip] = cookies[:user_just_zip] = HOME_ZIP
      cookies.permanent[:lat] = HOME_LAT
      cookies.permanent[:lon] = HOME_LON
      cookies.permanent[:radius] = DEFAULT_RADIUS
      cookies.permanent[:show_instructions] = "true"
    end
    @user_lat = cookies[:lat].to_f
    @user_lon = cookies[:lon].to_f
    @user_radius = cookies[:radius].to_i ||= DEFAULT_RADIUS
    @show_instructions = cookies[:show_instructions] ||= "true"
    @change_zip_problem = false
  end

  def get_localized_messaging
    if cookies[:language].nil?
      cookies.permanent[:language] = "1"
      @localized_messaging = ENGLISH_MESSAGING
    else
      case cookies[:language].to_i
      when 1
        @localized_messaging = ENGLISH_MESSAGING
      when 2
        @localized_messaging = SPANISH_MESSAGING
      else
        @localized_messaging = ENGLISH_MESSAGING
      end
    end
  end

  def get_localized_err_msgs
    if cookies[:language].nil?
      cookies.permanent[:language] = "1"
      @err_msgs = ENGLISH_ERRORS
    else
      case cookies[:language].to_i
      when 1
        @err_msgs = ENGLISH_ERRORS
      when 2
        @err_msgs = SPANISH_ERRORS
      else
        @err_msgs = ENGLISH_ERRORS
      end
    end
  end

  private

  def authorize_admin(pwd = "badpwd")
    if session[:admin_user] == "1"
      return true
    elsif pwd == "maldini3!"
      session[:admin_user] = "1"
      return true
    else
      redirect_to("/admin/login", :notice => 'Please login')
    end
  end

end
