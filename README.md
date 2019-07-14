# GemStream

GemStream is a gem that allows you to follow along as new gems are published on Rubygems.org.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gem_stream'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gem_stream

## Usage

### Configure
First, you'll need to configure GemStream to handle two events.

Specify a proc for `on_version`, which receives a hash of version attributes as an argument. It will be called once for each ruby gem version that's published.

Specify a proc for `on_synced`, which receives no arguments. It will be called when the stream is up to date.

Example:

```ruby
GemStream.configure do |c|
  c.on_version = -> (version) { handle_version(version) }
  c.on_synced = -> () { handle_sync }
end
```

You can also configure the api call interval. Rubygems.org does have a rate limit (10 req/s), so you can configure an interval as low as `0.1`. If you don't configure an interval, the default interval will be applied (1 second).

### Follow

Once you've handled configuration, you can use GemStream like this:

```ruby
# start_time being an instance of Time, from which you'd like to begin streaming.
GemStream::Follower.follow_from(start_time)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fwilkens/gem_stream.
