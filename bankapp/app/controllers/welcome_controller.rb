class WelcomeController < ApplicationController

  def index
    if truefactor_current_user
      @user = truefactor_current_user
    else
    end
  end

  def send_money
    return unless truefactor_approve! "#{params[:amount]}" #Do you want to send #{params[:amount]} to #{params[:destination]}?"
    puts 'done'
    render text: 'sent'

  end

end
