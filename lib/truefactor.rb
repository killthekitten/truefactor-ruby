require 'securerandom'
require 'uri'
require 'openssl'

module Truefactor
  ORIGIN = 'https://truefactor.io'
  module User
    def truefactor_signatures(challenge, raw = false)
      seed1, seed2 = self.truefactor.split(',')
      unless raw
        stamp = Time.now.to_i / 120
        challenge = "#{challenge}:#{stamp}" 
      end
      [to_otp(challenge, seed1), to_otp(challenge, seed2)]
    end

    def valid_truefactor?(challenge, str)
      sig1, sig2 = str.gsub(/\s/,'').split(',')

      real_sig = to_otp(truefactor_signatures(challenge).join)

      sig1 = to_digits(sig1)
      sig2 = to_digits(sig2)

      sig1 = to_otp(sig1 + sig2) if !sig2.blank?

      real_sig == sig1
    end

    def to_otp(m, secret = false)
      hex = if secret
        OpenSSL::HMAC.hexdigest('sha256', secret, m)
      else
        OpenSSL::Digest::SHA256.hexdigest(m)
      end

      code = (hex.to_i(16) % 10**12).to_s

      '0'*(12-code.length) + code
    end

    def to_digits(s)
      s = s.to_s
      if s.length == 8
        s.to_i(32).to_s.rjust(12,'0')
      else
        s
      end
    end
  end


  def gen(l)
    SecureRandom.base64(100).gsub(/[^A-Za-z0-9]/,'')[0,l]
  end
  
  def qr(data)
    base = data.map{|i|
      URI.encode_www_form_component(i)
    }.join('/')
    "https://chart.googleapis.com/chart?cht=qr&chs=200x200&chl=http://truefactor.io/%23#{base}&chld=" #H|0
  end

  def origin
    URI.encode_www_form_component('http://lh:3000')
  end



  module Controller
    def truefactor
      if cookies[:truefactor_state] && cookies.delete(:truefactor_state) == params[:state] 
        cookies[:truefactor_response] = { 
          value: params[:signs], 
          expires: 1.hour.from_now 
        }
        return render text: "Please close this window."
      elsif session[:truefactor_state] && session[:truefactor_state] == params[:state]
        session.delete :truefactor_state
        if params[:seeds]
          user = ::User.find_by_email params[:tfid]
          if user      
            flash[:alert] = 'email already exists'
          else
            user = ::User.new email: params[:tfid], truefactor: params[:seeds],username: SecureRandom.hex(8), password: SecureRandom.hex(8)
            user.save(validate: false)
            sign_in user
          end
          redirect_to '/'

        elsif params[:signs]
          if !session[:old_env]
            user = ::User.find_by_email params[:tfid]
            v = if user && user.valid_truefactor?('login', params[:signs])
              sign_in user
            else
              flash[:alert] = 'Invalid email or signature'
            end
            redirect_to '/'

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
        @user ||= ::User.find(session[:user_id])
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
end

#curl -u homakov https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials