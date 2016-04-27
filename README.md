# JWT Keeper
[![Build Status](https://img.shields.io/travis/sirwolfgang/jwt_keeper/master.svg)](https://travis-ci.org/sirwolfgang/jwt_keeper)
[![Dependency Status](https://img.shields.io/gemnasium/sirwolfgang/jwt_keeper.svg)](https://gemnasium.com/sirwolfgang/jwt_keeper)
[![Code Climate](https://img.shields.io/codeclimate/github/sirwolfgang/jwt_keeper.svg)](https://codeclimate.com/github/sirwolfgang/jwt_keeper)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/sirwolfgang/jwt_keeper.svg)](https://codeclimate.com/github/sirwolfgang/jwt_keeper/coverage)
[![Inline docs](http://inch-ci.org/github/sirwolfgang/jwt_keeper.svg?style=shields)](http://inch-ci.org/github/sirwolfgang/jwt_keeper)

An managing interface layer for handling the creation and validation of JWTs.

## Setup
 - Add `gem 'jwt_keeper', '~> 3.0'` to Gemfile
 - Run `rails generate keeper:install`
 - Configure `config/initializers/jwt_keeper.rb`
 - Done

## Basic Usage
Here are the basic methods you can call to perform various operations

```ruby
token = JWTKeeper::Token.create(private_claim_hash)
token = JWTKeeper::Token.find(raw_token_string)

token.revoke
token.rotate

token.valid?
raw_token_string = token.to_jwt
```

## Rails Usage
The designed rails token flow is to receive and respond to requests with the token being present in the `Authorization` part of the header. This is to allow us to seamlessly rotate the tokens on the fly without having to rebuff the request as part of the user flow. Automatic rotation happens as part of the `require_authentication` action, meaning that you will always get the latest token data as created by `generate_claims` in your controllers. This new token is added to the response with the `write_authentication_token` action.

```bash
rake generate jwt_keeper:install
```

```ruby
class ApplicationController < ActionController::Base
  before_action :require_authentication

  def not_authenticated
    # Overload to return status 401
  end

  def authenticated(token)
    # Overload to make use of token data
  end

  def regenerate_claims(old_token)
    # Overload to update claims on automatic rotation.
    current_user = User.find(old_token.claims[:uid])
    { uid: current_user.id, usn: current_user.email }
  end
end
```

```ruby
class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: :create

  # POST /sessions
  def create
    token = JWTKeeper::Token.create(uid: @user.id, usn: @user.email)
    write_authentication_token(token)
  end

  # PATCH/PUT /sessions
  def update
    token = read_authentication_token
    token.rotate
    write_authentication_token(token)
  end

  # DELETE /sessions
  def destroy
    token = read_authentication_token
    token.revoke
    clear_authentication_token
  end
```

## Invalidation
### Hard Invalidation
Hard Invalidation is a permanent revocation of the token. The primary cases of this is when a user wishes to logout, or when your security has been otherwise compromised. To revoke all tokens simply update the configuration `secret`. To revoke a single token you can utilize either the class(`Token.revoke(jti)`) or instance(`token.revoke`) method.

### Soft Invalidation
Soft Invalidation is the process of triggering a rotation upon the next time a token is seen in a request. On the global scale this is done when there is a version mismatch in the config. Utilizing the rails controller flow, this method works even if you have two different versions of your app deployed and requests bounce back and forth; Making rolling deployments and rollbacks completely seamless. To rotate a single token, like in the case of a change of user permissions, simply use the class(`Token.rotate`) method to flag the token for regeneration.

## Cookie Locking
Cookie locking is the practice of securing the JWT by pairing it with a secure/httponly cookie. When a JWT is created, part of the secret used to sign it is a one time generated key that is stored in a matching cookie. The cookie and JWT thus must be sent together to be considered valid. The effective result makes it extremely hard to hijack a session by stealing the JWT. This reduces the surface area of XSS considerably.
