module CoinsHelper
  def calculate_variation(coin, period)
    current_price = coin[:price_usd]
    return "N/A" unless current_price

    historical_price = CoinPrice
      .where(coin_name: coin[:name].downcase)
      .where('timestamp >= ?', period.ago)
      .order(:timestamp)
      .first
      &.price_usd

    return "N/A" unless historical_price

    variation = ((current_price - historical_price) / historical_price) * 100
    number_to_percentage(variation, precision: 2)
  end

  def variation_class(coin, period)
    variation = calculate_variation(coin, period).to_f
    if variation > 0
      'positive'
    elsif variation < 0
      'negative'
    else
      ''
    end
  end
end