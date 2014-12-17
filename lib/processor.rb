require 'json'

module ExcoinLive::Processor
  extend EventMachine::Deferrable

  def self.chat(message_json)
    chat_message = JSON.parse(message_json)
    p chat_message
  end

  def self.account(message_json)
    account_update = JSON.parse(message_json)
    p account_update
    if account_update['action'] == "transaction"
      ExcoinLive.account.send("add_" + account_update['type'].downcase, account_update)
    elsif account_update['action'] == "balances"
      p ExcoinLive.account.wallets
      ExcoinLive.account.wallet(account_update['currency']).update(account_update)
    elsif account_update['action'] == "order"
      if account_update['type'] == "modify"
        ExcoinLive.account.order(account_update['id']).update
      elsif account_update['type'] == "delete"
        ExcoinLive.account.orders.delete(account_update)
      end
    elsif account_update['action'] == "trade"
        ExcoinLive.account.trades.add(account_update)
    end
  end

  def self.exchanges(message_json)
    p exchange_update = JSON.parse(message_json)
    ExcoinLive.exchange(exchange_update['currency'] + exchange_update['commodity']).update(exchange_update)
  end

  def self.exchange(exchange_name, message_json)
    exchange_item_update = JSON.parse(message_json)
    p exchange_item_update
    if exchange_item_update['action'] == "order"
      if exchange_item_update['update_type'] == "create"
        order = Excoin::Market::Exchange::Order.new(exchange_item_update)
        ExcoinLive.exchange(exchange_name).orders.add(order)
        ## Example: Fill any order that comes in
        ExcoinLive.bot.fill_order(ExcoinLive.bot.commodity, order)
      else
        ExcoinLive.exchange(exchange_name).orders.update(exchange_item_update['type'])
      end
    elsif exchange_item_update['action'] == "trade"
      ExcoinLive.exchange(exchange_name).trades.add(exchange_item_update)
    end
  end

end
