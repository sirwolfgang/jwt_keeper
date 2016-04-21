# Keeper
[![Build Status](https://img.shields.io/travis/hive-xyz/keeper/master.svg)](https://travis-ci.org/hive-xyz/keeper)
[![Dependency Status](https://img.shields.io/gemnasium/hive-xyz/keeper.svg)](https://gemnasium.com/hive-xyz/keeper)
[![Code Climate](https://img.shields.io/codeclimate/github/hive-xyz/keeper.svg)](https://codeclimate.com/github/hive-xyz/keeper)
[![Test Coverage](https://img.shields.io/codeclimate/coverage/github/hive-xyz/keeper.svg)](https://codeclimate.com/github/hive-xyz/keeper/coverage)
[![Inline docs](http://inch-ci.org/github/hive-xyz/keeper.svg?style=shields)](http://inch-ci.org/github/hive-xyz/keeper)

An managing interface layer for handling the creation and validation of JWTs.

## Setup
 - Add `gem 'keeper', git: 'https://github.com/hive-xyz/keeper.git'` to Gemfile
 - Run `rails generate keeper:install`
 - Configure `config/initializers/keeper.rb`
 - Done

## Basic Usage
Here are the basic methods you can call to perform various operations

```ruby
token = Keeper::Token.create(private_claim_hash)
token = Keeper::Token.find(raw_token_string)

token.revoke
token.rotate

token.valid?
raw_token_string = token.to_jwt
```

## Rails Usage
The designed rails token flow is to receive and respond to requests with the token being present in the `Authorization` part of the header. This is to allow us to seamlessly rotate the tokens on the fly without having to rebuff the request as part of the user flow. Automatic rotation happens as part of the `require_authentication` action, meaning that you will always get the latest token data as
created by `generate_claims` in your controllers. This new token is added to the response with
the `respond_with_authentication` action.

```ruby
class ApplicationController < ActionController::Base
  before_action :require_authentication
  after_action :respond_with_authentication

  def not_authenticated
    # Overload to return status 401
  end

  def authenticated(token)
    # Overload to make use of token data
  end

  def regenerate_claims
    # Overload to update claims on automatic rotation.
    current_user = User.find(authentication_token.claims[:uid])
    { uid: current_user.id, usn: current_user.email }
  end
end
```

```ruby
class SessionsController < ApplicationController
  skip_before_action :require_authentication, only: :create
  skip_after_action :respond_with_authentication, only: :destroy

  # POST /sessions
  def create
    authentication_token = Keeper::Token.create({ uid: @user.id, usn: @user.email })
  end

  # PATCH/PUT /sessions
  def update
    authentication_token = request_token.rotate(generate_claims)
  end

  # DELETE /sessions
  def destroy
    request_token.revoke
    authentication_token = nil
  end
```

## Invalidation
### Hard Invalidation
Hard Invalidation is a permanent revocation of the token. The primary cases of this is when a user wishes to logout, or when your security has been otherwise compromised. To revoke all tokens simply update the configuration `secret`. To revoke a single token you can utilize either the class(`Token.revoke(jti)`) or instance(`token.revoke`) method.

### Soft Invalidation
Soft Invalidation is the process of triggering a rotation upon the next time a token is seen in a request. On the global scale this is done when there is a version mismatch in the config. Utilizing the rails controller flow, this method works even if you have two different versions of your app deployed and requests bounce back and forth; Making rolling deployments and rollbacks completely seamless. To rotate a single token, like in the case of a change of user permissions, simply use the class(`Token.rotate`) method to flag the token for regeneration.
