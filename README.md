# Dynalock

Dynalock is a distributed lock that uses dynamod db.


## Background

At tourlane we were running cronjobs through AWS ECS. Once the cluster become
too big, Cloudwatch was scheduling tasks, even if the same task was already
present. Dynalock solves this issue, ensuring that any new task exit and fails
before starting the real work.

The first assumption is that something like this should exists, but normally
not as a command line program (if you found any, please let us know). So we
created our own.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dynalock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dynalock

You need to create a table in dynamo db with "id" as a primary key, and "expires" as expires.
The default table name is "locks"


## Usage


Set the environment variables to its proper values.


    AWS_ACCESS_KEY_ID
    AWS_REGION
    AWS_SECRET_ACCESS_KEY


### Usage inside ruby

```ruby
require 'dynalock'

include Dynalock::Lock

adquire_lock(context: "my_lock", table: TABLE, owner: @owner, expire_time: 10)
refresh_lock(context: "my_lock", table: TABLE, owner: @owner, expire_time: 10)
with_lock(context: "my_lock", table: TABLE, owner: @owner) { "Only run this" }
```

Most of the paramenters are optional

```ruby
adquire_lock(context: "my_lock")
refresh_lock(context: "my_lock")
with_lock(context: "my_lock") { "Only run this" }
```


### Usage through the command line

```sh
$ dynalock my_program
```

This will try to adquire to a lock in dynamodb for 10 seconds, and refresh it every 5 seconds and run your program. The command will be context.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/guillermo/dynalock. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Dynalock project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/guillermo/dynalock/blob/master/CODE_OF_CONDUCT.md).

