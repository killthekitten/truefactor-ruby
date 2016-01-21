require "truefactor/version"
require 'active_support'
require 'active_record'
require 'action_controller'
require "truefactor/model"
require "truefactor/controller"
require "truefactor/helper"

require 'securerandom'
require 'uri'
require 'openssl'

module Truefactor
  class << self
    attr_accessor :configuration, :model_name
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :web_origin, :desktop_origin, :tfid_type, :origin_name, :origin, :icon, :model_name

    def initialize
      @web_origin     = 'https://truefactor.io'
      @desktop_origin = 'truefactor://'
      @tfid_type      = :email
      @origin_name    = 'Truefactorized app'
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include Truefactor::Model
end

ActiveSupport.on_load(:action_controller) do
  include Truefactor::Controller
end

ActiveSupport.on_load(:action_view) do
  include Truefactor::Helper
end
