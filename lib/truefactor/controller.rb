module Truefactor
  module Controller
    extend ::ActiveSupport::Concern

    module ClassMethods
      def truefactorize
        class_exec do
          send :include, Truefactor::Controller::TruefactorizedMethods
        end
      end
    end

    module TruefactorizedMethods
      def truefactor
        tfid_type = Truefactor.configuration.tfid_type
        if cookies[:truefactor_state] && cookies.delete(:truefactor_state) == params[:state]
          cookies[:truefactor_response] = {
            value: params[:signs],
            expires: 1.hour.from_now
          }
          return render text: "Please close this window."
        elsif session[:truefactor_state] && session[:truefactor_state] == params[:state]
          session.delete :truefactor_state
          if params[:seeds]
            user = ::Truefactor._model_.find_by(tfid_type => params[:tfid])
            if user
              flash[:alert] = "#{tfid_type} already exists"
            else
              user = ::Truefactor._model_.new
              puts tfid_type
              user.send "#{tfid_type}=", params[:tfid]
              user.truefactor = params[:seeds]
              user.save(validate: false)
              truefactor_sign_in user
            end
            return redirect_to '/'
          elsif params[:signs]
            if !session[:old_env]
              user = ::Truefactor._model_.find_by(tfid_type => params[:tfid])
              v = if user && user.valid_truefactor?('login', params[:signs])
                    truefactor_sign_in user
                  else
                    flash[:alert] = "Invalid #{tfid_type} or signature"
                  end
              return redirect_to '/'

            else
              session[:truefactor_signs] = params[:signs]
              return redirect_to session[:old_env]["path"]+'?'+session[:old_env]["params"].to_query
            end
          else
            raise "nothing"
          end
        else
          redirect_to_truefactor action: "register", tfid_type: Truefactor.configuration.tfid_type
        end

      end

      def truefactor_current_user
        if session[:user_id]
          @user ||= ::Truefactor._model_.find(session[:user_id])
        else
          false
        end
      end

      def truefactor_sign_out
        session.clear
        redirect_to '/'
      end

      def truefactor_sign_in(user)
        session[:user_id] = user.id
      end

      def truefactor_approve!(challenge)
        path = request.env['PATH_INFO'] #url_for(action: params[:action], controller: params[:controller])
        if session[:old_env] && session[:old_env]["path"] == path && session[:truefactor_signs]
          # we are back
          session.delete :old_env
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
        redirect_to_truefactor action: "auth", challenge: challenge

        false
      end

      def redirect_to_truefactor(args)
        origin = Truefactor.configuration.web_origin

        session[:truefactor_state] = SecureRandom.hex
        args[:state] = session[:truefactor_state]

        current_origin = "#{request.protocol}#{request.host_with_port}"
        args[:origin] = Truefactor.configuration.origin || current_origin

        args[:origin_name] = Truefactor.configuration.origin_name
        args[:icon] = Truefactor.configuration.icon

        redirect_to "#{origin}/#" + args.to_query
      end
    end
  end
end
