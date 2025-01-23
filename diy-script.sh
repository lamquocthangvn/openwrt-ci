#!/bin/bash

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# Update wireless configuration
cat <<EOL > /etc/config/wireless
config wifi-device 'radio0'
        option type 'mac80211'
        option path 'platform/soc@0/c000000.wifi'
        option band '5g'
        option channel '40'
        option htmode 'HE80'
        option disabled '0'
        option country 'US'
        option cell_density '0'
        option mu_beamformer '1'
        option txpower '20'

config wifi-iface 'default_radio0'
        option device 'radio0'
        option network 'lan'
        option mode 'ap'
        option ssid 'AX1800Pro_5G'
        option encryption 'psk2'
        option key '09090909'

config wifi-device 'radio1'
        option type 'mac80211'
        option path 'platform/soc@0/c000000.wifi+1'
        option band '2g'
        option channel '1'
        option htmode 'HE20'
        option disabled '1'

config wifi-iface 'default_radio1'
        option device 'radio1'
        option network 'lan'
        option mode 'ap'
        option ssid 'AX1800Pro_2.4G'
        option encryption 'none'
        option disabled '1'
EOL

# Git sparse clone function
function git_sparse_clone() {
    branch="$1" repourl="$2" && shift 2
    git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
    repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
    cd $repodir && git sparse-checkout set $@
    mv -f $@ ../package
    cd .. && rm -rf $repodir
}

# Add core packages
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

# Setup scripts permissions
chmod +x $GITHUB_WORKSPACE/scripts/preset-terminal-tools.sh
chmod +x $GITHUB_WORKSPACE/scripts/preset-adguard-core.sh

# Execute setup scripts
$GITHUB_WORKSPACE/scripts/preset-terminal-tools.sh
$GITHUB_WORKSPACE/scripts/preset-adguard-core.sh aarch64