# Hotel
Helps you manage all of those keys you're giving out.

[![Build Status](https://travis-ci.org/davidrivera/hotel.svg?branch=master)](https://travis-ci.org/davidrivera/hotel) [![Code Climate](https://codeclimate.com/github/davidrivera/hotel/badges/gpa.svg)](https://codeclimate.com/github/davidrivera/hotel) [![Inline docs](http://inch-ci.org/github/davidrivera/hotel.svg?branch=master)](http://inch-ci.org/github/davidrivera/hotel)

## Setup
 - Add `gem 'hotel', git: 'https://github.com/davidrivera/hotel.git'` to Gemfile
 - Run `rails generate hotel:install`
 - Configure `config/initializers/hotel.rb`
 - Configure `config/redis.yml` keyed with the application environment, these options will be piped directly to `Redis.new`
```
# config/redis.yml
production:
  ...
development:
  ...
```

- Done

## Basic Usage
Here are the basic methods you can call to perform various operations

```ruby
Hotel.token.generate(private_claim_hash)

Hotel.token.revoke(raw_token)
Hotel.token.rotate(raw_token)

Hotel.token.decode_and_validate(raw_token)
Hotel.token.decode_and_validate!(raw_token)
Hotel.token.valid?(raw_token)
```

## How invalidation happens
[JSON Web Tokens](https://jwt.io/) by nature cannot be invalidated, there are few methods
for rotating out compromised ones such as

* shortening the time to expire
* storing a whitelist of issued tokens in your DDL
* tracking which tokens you've issued to who

<rant>
These solutions to me all seemed lame, shortening the time to expiry means
you are rotating out good non-compromised keys more frequently possibly running into
situations causing your users to have to re-login, which is bad for obvious reasons.
Storing a whitelist in your DDL also doesn't make sense because the point of JWT
is the minimize the hits to the DDL by letting you store your own claims, like
user permissions, and by being able to validate it without the need for any DB call.
Lastly tracking issued JWT's also makes no sense. The point of them is to be able
to issue them to anything an android phone, a web browser, a toaster it doesn't matter.
It's suppose to account for scaling so you're suppose to be able to issue as many as need be.
Then authenticate them on any web head. Tracking issued ones just causes more DB lookups to
happen and the need for more database synchronization (running into the [CAP](https://en.wikipedia.org/wiki/CAP_theorem))
</rant>

So I made Hotel. The way we invalidate tokens is by storing a blacklist of
compromised tokens in redis. Tokens only need to be stored until their expiry,
after that they are, well, expired and no longer need to be tracked. Redis
provides a nice feature called [expire](http://redis.io/commands/expire).
So all we have to do is set the redis expiry for the record equal to the
difference of the tokens expiry and the current time.

This approach provides for nice self cleaning records and doesn't require any change
to your DDL.
