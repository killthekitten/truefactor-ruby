class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  def truefactor
    if session[:truefactor_state] && session[:truefactor_state] == params[:state]
      session.delete :truefactor_state
      if params[:seeds]
        user = User.find_by_email params[:tfid]
        if user      
          render text: 'email already exists'
        else
          truefactor_sign_in User.create email: params[:tfid], truefactor: params[:seeds]
        end
      elsif params[:signs]
        user = User.find_by_email params[:tfid]
        v = if user && user.valid_truefactor?('login', params[:signs])
          truefactor_sign_in user
        else
          render text: 'Not valid email or signature'
        end
      else
        raise "nothing"
      end
    else
      session[:truefactor_state] = SecureRandom.hex
      redirect_to "#{Truefactor::ORIGIN}/#" + {
        action: "register",
        origin_name: "This is Bank App!",
        origin: "http://lh:3001",
        icon: "https://bankapp.com/icon",
        state: session[:truefactor_state]
      }.to_query
    end

  end

  def truefactor_current_user
    if session[:user_id]
      @user ||= User.find(session[:user_id])
    else
      false
    end
  end

  def sign_out
    session.clear
    redirect_to '/'
  end

  def truefactor_sign_in(user)
    session[:user_id] = user.id
    redirect_to '/'
  end


end
