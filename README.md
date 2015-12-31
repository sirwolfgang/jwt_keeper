# Keeper
Helps you manage all of those keys you're giving out.

## Setup
 - Add `gem 'keeper', git: 'https://github.com/hive-xyz/keeper.git'` to Gemfile
 - Run `rails generate keeper:install`
 - Configure `config/initializers/keeper.rb`
 - Done

## Basic Usage
Here are the basic methods you can call to perform various operations

```ruby
Keeper.token.generate(private_claim_hash)

Keeper.token.revoke(raw_token)
Keeper.token.rotate(raw_token)

Keeper.token.decode_and_validate(raw_token)
Keeper.token.decode_and_validate!(raw_token)
Keeper.token.valid?(raw_token)
```

## Motivation
[JSON Web Tokens](https://jwt.io/) by nature cannot be invalidated, there are few methods
for rotating out compromised ones such as:
- shortening the time to expire
- storing a whitelist of issued tokens in your DDL
- tracking which tokens you've issued to who

These solutions to me all seemed inadequate; Shortening the time to expiry means
you are rotating out good non-compromised keys more frequently possibly running into situations causing your users to have to re-login, which is bad for obvious user experience reasons.

Storing a whitelist in your DDL also doesn't make sense because the point of JWT
is the minimize the hits to the DDL by letting you store your own claims, like
user permissions, and by being able to validate it without the need for any DB call.

Lastly tracking issued JWT's also makes no sense. The point of them is to be able
to issue them to anything an android phone, a web browser, a toaster it doesn't matter. It's suppose to account for scaling so you're suppose to be able to issue as many as need be.Then authenticate them on any web head. Tracking issued ones just causes more DB lookups to happen and the need for more database synchronization (running into the [CAP](https://en.wikipedia.org/wiki/CAP_theorem)).

So I made [Hotel]/Keeper.

## Method
The way we invalidate tokens is by storing a blacklist of compromised tokens in redis. Tokens only need to be stored until their expiry, after that they are, well, expired and no longer need to be tracked. Redis provides a nice feature called [expire](http://redis.io/commands/expire). So all we have to do is set the redis expiry for the record equal to the difference of the tokens expiry and the current time.

This approach provides for nice self cleaning records and doesn't require any change to your DDL.
