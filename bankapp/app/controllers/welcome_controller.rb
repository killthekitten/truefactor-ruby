class WelcomeController < ApplicationController

  def index
    if truefactor_current_user
      @user = truefactor_current_user
    else
    end
  end
end
