#!/bin/bash

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Change default shell to zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

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
git clone --depth=1 https://github.com/gSpotx2f/luci-app-log package/luci-app-log-viewer
git clone --depth=1 https://github.com/ParticleG/luci-app-macvlan /package/luci-app-macvlan
# git_sparse_clone master https://github.com/vernesong/OpenClash package/luci-app-openclash

# Setup scripts permissions
chmod +x "$GITHUB_WORKSPACE"/scripts/preset-terminal-tools.sh
chmod +x "$GITHUB_WORKSPACE"/scripts/preset-adguard-core.sh
chmod +x "$GITHUB_WORKSPACE"/scripts/preset-spoof-proxy.sh

# Execute setup scripts
"$GITHUB_WORKSPACE"/scripts/preset-terminal-tools.sh
"$GITHUB_WORKSPACE"/scripts/preset-adguard-core.sh arm64

# init-script
mv "$GITHUB_WORKSPACE"/init-scripts/990_set-wireless.sh package/base-files/files/etc/uci-defaults/
mv "$GITHUB_WORKSPACE"/init-scripts/99-default-settings-chinese package/emortal/default-settings/files/99-default-settings-chinese
