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
        if !session[:old_env]
          user = User.find_by_email params[:tfid]
          v = if user && user.valid_truefactor?('login', params[:signs])
            truefactor_sign_in user
          else
            render text: 'Not valid email or signature'
          end
        else
          session[:truefactor_signs] = params[:signs]
          redirect_to session[:old_env]["path"]+'?'+session[:old_env]["params"].to_query
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

  def truefactor_approve!(challenge)
    path = request.env['PATH_INFO'] #url_for(action: params[:action], controller: params[:controller])
    if session[:old_env] && session[:old_env]["path"] == path && session[:truefactor_signs]
      # we are back
      session.delete :old_env
      puts "old env"
      if truefactor_current_user.valid_truefactor?(challenge, session.delete(:truefactor_signs))

        return true

      end      
    end
      params.delete :action
      params.delete :controller
      session[:old_env] = {
        path: path,
        params: params
      }

      session[:truefactor_state] = SecureRandom.hex
      redirect_to "#{Truefactor::ORIGIN}/#" + {
        action: "auth",
        origin: "http://lh:3001",
        challenge: challenge,
        state: session[:truefactor_state]
      }.to_query

      false
    

  end


end
