class ExBot
  attr_reader :currency, :commodity, :account, :exchange, :orders, :coins
  def initialize(currency, commodity)
    @currency = currency
    @commodity = commodity
    @exchange = Exchange.new(@currency, @commodity)
    @account = Account.new

    @coins = [@currency, @commodity]
    @spending_limit_proportion = { @currency => 0.5, @commodity => 0.5 }

    @coins.each do |coin|
      @account.reset_balances(coin, @spending_limit_proportion[coin])
    end
  end

  def place_order(order_type, amount, price)
    begin
    p "in place_order"
      if amount.class == BigDecimal
        amount_string = Money.new(to_satoshi(amount)).to_s
      else
        amount_string = amount.to_s
      end
      price_string = Money.new(to_satoshi(price)).to_s
      @exchange.summary.issue_order(order_type, amount_string, price_string)
      if order_type == "bid"
        spent_coin = @currency
        received_coin = @commodity
        received = amount / price
      elsif order_type == "ask"
        spent_coin = @commodity
        received_coin = @currency
        received = amount * price
      end
      @account.update_spending_limit_left(spent_coin, amount)
      @account.update_received(received_coin, received)
    rescue
      p "Order failure: type #{order_type}, amount #{amount_string}, price #{price_string}"
    end
  end

  def fill_order(coin, order)
    p "fill order with #{coin}"
    price = order.price
    if order.type == "ASK"
      placed_order_type = "bid"
      if order.currency_amount < @account.balances[coin][:spending_limit_left]
        amount = order.currency_amount
      else
        amount = @account.balances[coin][:spending_limit_left]
      end
    elsif order.type == "BID"
      placed_order_type = "ask"
      if order.commodity_amount < @account.balances[coin][:spending_limit_left]
        amount = order.commodity_amount
      else
        amount = @account.balances[coin][:spending_limit_left]
      end
    end
    place_order(placed_order_type, amount, price)
    p "placed order"
    unless @account.balances[coin][:spending_limit_left] > 0
      cancel_open_orders(coin)
    end
  end

  def cancel_open_orders(coin)
    @account.fetch_update
    @account.summary.orders.each do |exchange_order_hash|
      if exchange_order_hash.has_value?(coin)
        if exchange_order_hash.key(coin) == "commodity"
          exchange_order_hash["ask_orders"].each do |order|
            order.cancel
          end
        elsif exchange_order_hash.key(coin) == "currency"
          exchange_order_hash["bid_orders"].each do |order|
            order.cancel
          end
        end
      end
    end
  end

  def profit(coin)
    update_account
    available(coin) - @account.balances[coin][:starting_balance]
  end

  def to_satoshi(decimal)
    decimal * 10**8
  end
end
