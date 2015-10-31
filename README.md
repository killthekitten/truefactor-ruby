# Installation

Truefactor.io can be your only authentication option or you can add it to existing auth schemes such as devise, authlogic etc. The installation just 5 minutes. <a href="http://cobased.com/">Check out the demo how it looks like.</a>


```
# (starting from scratch?) email field is required and used as identifier (tfid)
rails new bankapp
rails g model User email:string

# add to Gemfile (use edge version for now)
gem 'truefactor', github: 'sakurity/truefactory-ruby'

# add 'truefactor' field to your users/admins/customers etc table
rails g migration AddTruefactorToUsers truefactor:text
rake db:migrate

# add to models/user.rb
include Truefactor::User

# add to controllers/application_controller.rb
include Truefactor::Controller

# create a route in routes.rb
get '/truefactor', to: 'application#truefactor'


# Final touch! Put this anywhere to let users sign in and sign up with one button
<a href="/truefactor"><img width="180px" src="https://truefactor.io/signin.png" />
```


(optional) add your app description and icon to /config/initializers/truefactor.rb
```
Truefactor::Settings[:origin_name] = "Cobased - import your trips"
Truefactor::Settings[:icon] = "" #must be https
#Truefactor::Settings[:tfid_type] = :username #email by default
```

This is it! Other features (verified requests/responses/paired devices) are optional and mostly useful for very sensitive applications. Pull requests on how to simplify the installation are welcome.

If you have any *critical actions* in your app: money transfer, destroying a repo or showing an API key, you can protect them from XSS/extensions/widgets and even device compromise with *Verified Requests*. Just add Truefactor JS SDK:
```
<script src="https://truefactor.io/sdk.js"></script>
<% if current_user %>
  <script>Truefactor.tfid = <%=raw current_user.email.to_json %>;</script>
<% end %>
```
On the client side you need to get signatures first. You have form like this:
```
<form action="/btcsend" id="withdraw_form">
Amount: <input id="amount" name="amount" value="1.123"><br>
Address: <input id="addr" name="addr" value="1JU9gCtodk9rc2s4x85zDWYUo38gVSUaaH"><br>
<br>
<a id="withdraw_button"><img width="180px" src="<%=truefactor_domain%>/approve.png"/></a>
```

Add onclick event to the button
```
Truefactor.origin_name = 'Cobased';
Truefactor.icon = 'http://photos.state.gov/libraries/media/788/images/90x90.gif';

$('#withdraw_button').click(function(){
  var challenge = "Send " + $('#amount').val() + " btc to " + $('#addr').val() + "?";
  Truefactor.sign(challenge, function(signs){
    $('#withdraw_form').submit();

  })
})
```

Verify signatures on the server side. Make sure the 'challenge' string is equal one you built with JS and that it has enough details about the transaction in plain text: destination address, SWIFT, account number, full name, currency etc.

```
def btcsend
  challenge = "Send #{params[:amount]} btc to #{params[:addr]}?"
  signs = cookies.delete :truefactor_response || [params[:otp0],params[:otp1]].join(':')
  if current_user.valid_truefactor?(challenge, signs)
    # do something...
    redirect_to :back, notice: "The signature is valid! Sending #{params[:amount]} to #{params[:addr]}"
  else
    redirect_to :back, alert: "The signature (#{signs}) for this action (#{challenge}) is invalid"
  end
end
```


(optional) if you require other fields but tfid, like username, you might need to autofill them in models/user.rb and let the user update later.
```
before_save do
  if self.username.blank?
    self.username = SecureRandom.hex
  end
end
```

### Also

* Disable password resets by email for truefactor-enabled users

