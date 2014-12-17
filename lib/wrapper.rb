require 'net/https'
require 'json'
require 'config/ruby_money_config'

class Exchange
  attr_reader :currency, :commodity, :summary, :updated_at, :spread, :top_bid, :lowest_ask, :spread
  def initialize(currency, commodity)
    @currency = currency
    @commodity = commodity
    @summary = Excoin.exchange(@currency + @commodity)
    @updated_at = Time.now.utc

    @spread = @summary.spread

    @top_bid = @summary.top_bid
    @lowest_ask = @summary.lowest_ask

    @recent_trade_limit = 20
  end

  def spread_magnitude(trade_type)
    trade_count =  @summary.trades.send(trade_type).count
    if trade_count > 1
      if trade_count >= @recent_trade_limit
        trades = @summary.trades.send(trade_type).first(@recent_trade_limit)
      else
        trades = @summary.trades.send(trade_type)
      end
      trades.map!.with_index do |trade, i|
        if i < (trades.count - 1)
          (trade.price - trades[i+1].price).abs
        else
          0
        end
      end
      average_abs_difference = trades.reduce(:+) / (trades.count - 1)
      unless average_abs_difference == 0
        @spread / average_abs_difference
      else
        0
      end
    else
      0
    end
  end


end

class Account
  attr_reader :summary, :updated_at, :balances
  def initialize
    @summary = Excoin.account
    @updated_at = Time.now.utc
    @balances = {}
  end

  def fetch_update
    @summary.update
    @updated_at = Time.now.utc
  end

  def available(coin)
    coin_available = @summary.wallet(coin).available_balance
    if coin_available
      coin_available
    else
      0
    end
  end

  def initialize_balance(coin)
    @balances.merge!({ coin => { starting_balance: available(coin), spent: 0, received: 0, updated_at: @updated_at }})
  end

  def update_spending_limit(coin, spending_limit_proportion)
    @balances[coin].merge!({ spending_limit: @balances[coin][:starting_balance] * spending_limit_proportion })
  end

  def update_spending_limit_left(coin, spent = 0)
    @balances[coin].merge!({ spending_limit_left: @balances[coin][:spending_limit] - spent, spent: @balances[coin][:spent] + spent })
  end

  def reset_balances(coin, spending_limit_proportion)
    initialize_balance(coin)
    update_spending_limit(coin, spending_limit_proportion)
    update_spending_limit_left(coin)
  end

  def update_received(coin, received)
    @balances[coin].merge!({ received: @balances[coin][:received] + received })
  end

end
