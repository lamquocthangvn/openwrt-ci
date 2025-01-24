#!/bin/sh
. /usr/share/libubox/jshn.sh

# 默认WIFI设置
BASE_SSID='AX1800Pro'
BASE_WORD='09090909'

# 获取无线设备的数量
RADIO_NUM=$(uci show wireless | grep -c "wifi-device")

# 如果没有找到无线设备，直接退出
[ "$RADIO_NUM" -eq 0 ] && exit 0

# 配置参数
configure_wifi() {
  local radio=$1
  local channel=$2
  local htmode=$3
  local ssid=$4
  local band=$5
  local current_encryption=$(uci get wireless.default_radio${radio}.encryption)

  # 如果当前加密方式已设置且不为"none"，则不更新配置
  if [ -n "$current_encryption" ] && [ "$current_encryption" != "none" ]; then
    echo "No update needed for radio${radio} with channel ${channel} and SSID ${ssid}"
    return 0
  fi

  # 设置无线设备参数
  uci set wireless.radio${radio}.channel=${channel}
  uci set wireless.radio${radio}.htmode=${htmode}
  uci set wireless.radio${radio}.country='US'
  uci set wireless.radio${radio}.disabled='0'
  uci set wireless.radio${radio}.cell_density='0'
  uci set wireless.radio${radio}.mu_beamformer='1'
  uci set wireless.radio${radio}.txpower='20'

  uci set wireless.default_radio${radio}.ssid=${ssid}
  uci set wireless.default_radio${radio}.encryption='psk2+ccmp'
  uci set wireless.default_radio${radio}.key=${BASE_WORD}
  uci set wireless.default_radio${radio}.ieee80211k='1'
  uci set wireless.default_radio${radio}.time_advertisement='2'
  uci set wireless.default_radio${radio}.time_zone='CST-8'
  uci set wireless.default_radio${radio}.bss_transition='1'
  uci set wireless.default_radio${radio}.wnm_sleep_mode='1'
  uci set wireless.default_radio${radio}.wnm_sleep_mode_no_keys='1'

  # Disable 2.4G WiFi
  if [ "$band" = '2g' ]; then
    uci set wireless.radio${radio}.disabled='1'
  fi
}

# 查询mode
query_mode() {
  json_load_file "/etc/board.json"
  json_select wlan
  json_get_keys phy_keys
  for phy in $phy_keys; do
    json_select $phy
    json_get_var path_value "path"
    if [ "$path_value" = "$1" ]; then
      json_select info
      json_select bands
      json_get_keys band_keys
      for band in $band_keys; do
        json_select $band
        json_select modes
        json_get_keys mode_keys
        for mode in $mode_keys; do
          json_get_var mode_value $mode
          last_mode=$mode_value
        done
        json_select ..
        json_select ..
      done
      echo "$last_mode"
      return
    fi
    json_select ..
  done
}

# 设置无线设备的默认配置
FIRST_5G=''
set_wifi_def_cfg() {
  local band=$(uci get wireless.radio${1}.band)
  local path=$(uci get wireless.radio${1}.path)
  local htmode=$(query_mode "$path")
  local channel=6
  local WIFI_SSID="$BASE_SSID"

  case "$band" in
  '5g')
    channel=36
    [ "$htmode" = 'HE160' ] || [ "$htmode" = 'VHT160' ] && channel=44
    if [ -z "$FIRST_5G" ]; then
      [ "$RADIO_NUM" -gt 2 ] && WIFI_SSID="${BASE_SSID}_5G_1" || WIFI_SSID="${BASE_SSID}_5G"
      FIRST_5G=1
    else
      WIFI_SSID="${BASE_SSID}_5G_2"
    fi
    ;;
  '2g')
    WIFI_SSID="${BASE_SSID}_2.4G"
    ;;
  *)
    case "$htmode" in
    'HT40' | 'VHT40' | 'HE40')
      htmode="${htmode%40}20"
      ;;
    esac
    ;;
  esac

  configure_wifi "$1" "$channel" "$htmode" "$WIFI_SSID" "$band"
}

for i in $(seq 0 $((RADIO_NUM - 1))); do
  set_wifi_def_cfg "$i"
done

uci commit wireless

exit 0
