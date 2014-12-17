require 'faye'
require 'yaml'

class ExcoinLive::API
  attr_reader :faye

  begin
    config = YAML::load_file(File.expand_path('~/.excoin/config.yml', __FILE__))
  rescue
    config = ''
  end
  LIVE_API_KEY = config["live_api_key"]

  def initialize
    @faye = Faye::Client.new('https://live.exco.in/v1')
  end

  def chat
    @faye.subscribe("/chat") do |message|
      ExcoinLive::Processor.chat(message)
    end
  end

  def account
    @faye.subscribe("/account/#{LIVE_API_KEY}") do |message|
      ExcoinLive::Processor.account(message)
    end
  end

  def exchanges
    @faye.subscribe("/summary") do |message|
      ExcoinLive::Processor.exchanges(message)
    end
  end

  def exchange(currency, commodity)
    @faye.subscribe("/exchange/#{currency}/#{commodity}") do |message|
      ExcoinLive::Processor.exchange(currency +  commodity, message)
    end
  end
end

