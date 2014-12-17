# Exbot Ruby

An example Ruby bot that listens on the Excoin bayeux channel and fills any new order it sees.

## Setup

1. Run `bundle` to install dependencies.
2. Set up API keys in ~/.excoin/config.yml (see config/config.example.yml)

## Usage

1. `bundle exec irb`
2. In IRB, `require 'exbot_live'`
3. Watch it spend your Blackcoins.

__Starting points for changes:__
_exbot_live.rb_
Set which exchange to watch:
 `@bot = ExBot.new("BTC","BLK")`
Set which channels to listen on:
 `client.exchange(@bot.currency, @bot.commodity)`

_lib/exbot.rb_
Spending limit currently 50% of wallet contents:
 `@spending_limit_proportion = { @currency => 0.5, @commodity => 0.5 }`

_lib/processor.rb_
Add hooks to run when a Faye message is received. For example, 
 `ExcoinLive.bot.fill_order(ExcoinLive.bot.commodity, order)`
will fill every new "create" order received on the exchange channel.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/exbot_ruby/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
