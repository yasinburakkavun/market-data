#!/bin/bash

# Verileri çekme fonksiyonları

# CoinGecko API'sinden kripto para verilerini alır
get_crypto_data() {
  local coin_id=$1
  local data=$(curl -s "https://api.coingecko.com/api/v3/simple/price?ids=$coin_id&vs_currencies=usd&include_24hr_change=true")
  echo $data
}

# Yahoo Finance API'sinden hisse senedi ve endeks verilerini alır
get_stock_data() {
  local symbol=$1
  local data=$(curl -s "https://query1.finance.yahoo.com/v8/finance/chart/$symbol?interval=1d")
  echo $data
}

# Yüzdelik değişim hesaplama fonksiyonu
calculate_change() {
  local current_price=$1 #mevcut fiyat
  local previous_price=$2 #önceki fiyet
  echo "scale=2; (($current_price - $previous_price) / $previous_price) * 100" | bc
}

# Veri sembolleri ve API'lerden alacakları ID'ler
declare -A symbols=(
  ["BIST100"]="^XU100"
  ["XAU"]="GC=F"
  ["Bitcoin"]="bitcoin"
  ["Ethereum"]="ethereum"
  ["S&P500"]="^GSPC"
)

# Verileri güncelleme ve değişim hesaplama
for key in "${!symbols[@]}"; do
  symbol=${symbols[$key]}

  if [[ "$key" == "Bitcoin" || "$key" == "Ethereum" ]]; then
    data=$(get_crypto_data "$symbol") # CoinGecko API'sinden kripto para verilerini alır
    current_price=$(echo $data | jq -r '.[] | .usd') # Güncel fiyatı alır
    change=$(echo $data | jq -r '.[] | .usd_24h_change') # 24 saatlik değişimi alır
  else
    data=$(get_stock_data "$symbol") # Yahoo Finance API'sinden hisse senedi verilerini alır
    current_price=$(echo $data | jq -r '.chart.result[0].meta.regularMarketPrice') # Güncel fiyatı alır
    previous_price=$(echo $data | jq -r '.chart.result[0].indicators.quote[0].close[0]') # Önceki günün kapanış fiyatını alır
    change=$(calculate_change "$current_price" "$previous_price") # Yüzdelik değişimi hesaplar
  fi

  echo "$key: $current_price USD, CHANGE: $change%" # Sonuçları gösterir
done



