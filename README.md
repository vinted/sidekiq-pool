# Sidekiq::Pool

[![Gem](https://img.shields.io/gem/v/sidekiq-pool.svg)](https://rubygems.org/gems/sidekiq-pool)
[![Build Status](https://travis-ci.org/laurynas/sidekiq-pool.svg?branch=master)](https://travis-ci.org/laurynas/sidekiq-pool)

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

Signals `USR1`, `USR2` are forwarded to the children.

Signal `HUP` to parent starts new children and then stops old.

When using symlinked working directory `working_directory` configuration
option must be used to pick up new code.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/laurynas/sidekiq-pool.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
