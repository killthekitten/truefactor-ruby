# Installation

Truefactor.io can be your only authentication option or you can add it to existing auth schemes such as devise, authlogic etc. The installation takes up to 5 minutes. <a href="http://cobased.com/">Check out the demo how it looks like.</a>  Also you can take a look at another <a href="https://thawing-falls-18565.herokuapp.com/"demo</a> with a github <a href="https://github.com/avyy/truefactor-bankapp">repo</a>.


```
# (starting from scratch?) email field is required and used as identifier (tfid)
rails new bankapp
rails g model User email:string

# add to Gemfile (use edge version for now)
gem 'truefactor', github: 'sakurity/truefactory-ruby'

# run a generator to install it
rails g truefactor:install User

# Final touch! Put this anywhere in views to let users sign in and sign up with one button
<%= link_to_truefactor %>

# Or something like:
link_to 'Sign in', truefactor_path
```


(optional) add your app description and icon to generated /config/initializers/truefactor.rb
```
Truefactor.configure do |c|
  c.origin_name = "Cobased - import your trips"
  c.icon = "" #must be https
  c.tfid_type = :username #email by default
end
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

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
