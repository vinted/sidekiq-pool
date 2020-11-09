# Sidekiq::Pool

[![Gem](https://img.shields.io/gem/v/sidekiq-pool.svg)](https://rubygems.org/gems/sidekiq-pool)
[![Build Status](https://travis-ci.org/vinted/sidekiq-pool.svg?branch=master)](https://travis-ci.org/vinted/sidekiq-pool)

Allows Sidekiq using more CPU cores on Ruby MRI by forking multiple processes.
Also adds an option to use different command line option workers in the same pool.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-pool'
```

Create a config file and specify it's path with the *p* command line option (the default is config/sidekiq-pool.yml)

Paste the following config and modify it to your needs:

```yaml
:working_directory: /path/to/working/direcory # optional, needed if HUP reload is used with symlink
:workers:
  -
    :command: '-q default -q high'
    :env:
      CUSTOM_ENV_VARIABLE: 1
      REDIS_SHARD: 'A'
    :amount: 2
  -
    :command: '-q high -L high_logfile.txt'
    :amount: 1
```

## Usage

Help

    $ bundle exec sidekiq-pool -h

Start pool with a non-default path config

    $ bundle exec sidekiq-pool -p config/pool_config.yml

## Signals

Signals `USR1`, `USR2`, and `TSTP` are forwarded to the children. Depending on the version of Sidekiq, you may need to send `USR1` or `TSTP` to prepare it for shutdown. For more information, please read [signals and sidekiq](https://github.com/mperham/sidekiq/wiki/Signals) documentation.

Signal `HUP` to parent starts new children and then stops old.

When using symlinked working directory `working_directory` configuration
option must be used to pick up new code.

## Env
You are able to specify the list of environment variables, which will be passed to the process.

## After fork
You may want to execute code after process has been forked. It can be done by registering after_fork hook like this
```ruby
require 'sidekiq/pool'
Sidekiq::Pool.after_fork do
  # run code here
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vinted/sidekiq-pool.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
