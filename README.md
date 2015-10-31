# Installation

```

homakov:work homakov$ rails new bankapp

rails g model User email:string
rails g migration AddTruefactorToUsers truefactor:text

rake db:migrate

gem 'truefactor', github: 'sakurity/truefactory-ruby'

add 'include Truefactor::User' to models/user.rb
```