require 'eventmachine'
require 'excoin'
require 'lib/wrapper'
require 'lib/exbot'

module ExcoinLive
  require 'lib/api'
  require 'lib/processor'

  @bot = ExBot.new("BTC","BLK")
  p 'made a bot'

  def self.account
    @bot.account.summary
  end

  def self.exchange(name)
    @bot.exchange.summary
  end

  def self.bot
    @bot
  end

  EM.run do
    p "Attempting live connection to Excoin..."

    client = API.new

    client.faye.bind('transport:up') do
      p "Successfully connected to Excoin Live API."
    end

    client.faye.bind('transport:down') do
      p "Disconnected from Excoin Live API, attempting reconnect..."
    end

    ## Set which Faye channels you're listening to here
    client.account
    client.exchange(@bot.currency, @bot.commodity)
    # client.exchanges
    # client.chat

  end
end
