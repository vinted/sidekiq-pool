# Sidekiq::Pool

Allows Sidekiq using more CPU cores on Ruby MRI by forking multiple processes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-pool'
```

## Usage

Help

    $ bundle exec sidekiq-pool -h

Start pool with 3 instances

    $ bundle exec sidekiq-pool --pool-size 3 

## Signals

Signals `USR1`, `USR2` are forwarded to the children.
 
`TTIN` forks new child 
    
    $ kill -TTIN masterpid
    
`TTOU` kills one child
    
    $ kill -TTOU masterpid
    
## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/laurynas/sidekiq-pool.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
