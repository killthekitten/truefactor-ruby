require 'test_helper'

class User
  attr_accessor :email
  include Truefactor::Model
  truefactorize
end

class Ctrlr
  include Truefactor::Controller
  truefactorize
end

describe 'Truefactorization' do
  before do
    @user  = User.new
    @ctrlr = Ctrlr.new
  end

  describe 'when model truefactorized' do
    it "has truefactor methods" do
      module_methods = Truefactor::Model::TruefactorizedMethods.public_instance_methods
      _(@user.methods & module_methods).must_equal module_methods
    end
  end

  describe 'when controller truefactorized' do
    it "has truefactor methods" do
      module_methods = Truefactor::Controller::TruefactorizedMethods.public_instance_methods
      _(@ctrlr.methods & module_methods).must_equal module_methods
    end
  end
end
