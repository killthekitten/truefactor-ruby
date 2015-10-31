# Installation

```
# (optional) email field is required and used as identifier (tfid)
rails new bankapp
rails g model User email:string

# add to Gemfile
gem 'truefactor', github: 'sakurity/truefactory-ruby'

# add 'truefactor' field to your users/admins/customers table
rails g migration AddTruefactorToUsers truefactor:text
rake db:migrate

# add to models/user.rb
include Truefactor::User

# add to controllers/application_controller.rb
include Truefactor::Controller

# create a route in routes.rb
get '/truefactor', to: 'application#truefactor'

# (optional) add your app description and icon to /config/initializers/truefactor.rb
Truefactor::Settings[:origin_name] = "Cobased - import your trips"
Truefactor::Settings[:icon] = "" #must be https
#Truefactor::Settings[:tfid_type] = :username #email by default

# (optional) if you require other fields but tfid, like username, you might need to autofill them in models/user.rb

  before_save do
    if self.username.blank?
      self.username = SecureRandom.hex
    end
  end






```