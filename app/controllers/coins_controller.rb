require 'net/http'
require 'json'

class CoinsController < ApplicationController
  COINS = {
  "bitcoin" => {
    symbol: "BTC",
    image: "https://cryptologos.cc/logos/bitcoin-btc-logo.png"
  },
  "ethereum" => {
    symbol: "ETH",
    image: "https://cryptologos.cc/logos/ethereum-eth-logo.png"
  },
  "solana" => {
    symbol: "SOL",
    image: "https://cryptologos.cc/logos/solana-sol-logo.png"
  },
  "cardano" => {
    symbol: "ADA",
    image: "https://cryptologos.cc/logos/cardano-ada-logo.png"
  },
  "ripple" => {
    symbol: "XRP",
    image: "https://cryptologos.cc/logos/xrp-xrp-logo.png"
  }
}

  def index
    @usd_to_brl = get_usd_to_brl
    @coin_data = COINS.map do |coin, data|
      timestamp, price_usd = get_coin_price(coin)
      price_brl = price_usd ? (price_usd * @usd_to_brl).round(2) : nil

      # Armazenar o preço no banco de dados
      CoinPrice.create(
        coin_name: coin,
        price_usd: price_usd,
        price_brl: price_brl,
        timestamp: timestamp
      ) if price_usd

      {
        name: coin.capitalize,
        symbol: data[:symbol],
        image: data[:image],
        price_usd: price_usd,
        price_brl: price_brl,
        timestamp: timestamp
      }
    end

    # Limitar o histórico a 30 dias
    CoinPrice.where('timestamp < ?', 30.days.ago).delete_all
  end

  private

  def get_usd_to_brl
    url = URI("https://economia.awesomeapi.com.br/json/last/USD-BRL")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    data["USDBRL"]["bid"].to_f
  rescue StandardError => e
    Rails.logger.error "Erro ao obter cotação do dólar: #{e.message}"
    5.0 # Valor padrão em caso de erro
  end

  def get_coin_price(coin)
    url = URI("https://api.coingecko.com/api/v3/coins/#{coin}/market_chart?vs_currency=usd&days=30")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    latest_price = data["prices"].last
    timestamp = Time.at(latest_price[0] / 1000) # Convertendo timestamp para Time
    price = latest_price[1]
    [timestamp, price]
  rescue StandardError => e
    Rails.logger.error "Erro ao obter dados de #{coin}: #{e.message}"
    [nil, nil]
  end
end