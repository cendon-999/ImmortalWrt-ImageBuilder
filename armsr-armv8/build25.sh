#!/bin/bash
# Log file for debugging
# 25.12.x uses apk-custom-packages.sh, older versions use custom-packages.sh
if [ -f "shell/apk-custom-packages.sh" ]; then
    source shell/apk-custom-packages.sh
else
    source shell/custom-packages.sh
fi
source shell/switch_repository.sh
echo "第三方软件包：$CUSTOM_PACKAGES"
LOGFILE="/tmp/uci-defaults-log.txt"
echo "Starting 99-custom.sh at $(date)" >> $LOGFILE
# yml 传入的路由器型号 PROFILE
echo "Building for profile: $PROFILE"
# yml 传入的固件大小 ROOTFS_PARTSIZE
echo "Building for ROOTFS_PARTSIZE: $ROOTFS_PARTSIZE"

echo "Create pppoe-settings"
mkdir -p  /home/build/immortalwrt/files/etc/config

# 创建 pppoe 配置文件 yml 传入环境变量 ENABLE_PPPOE 等 写入配置文件 供 99-custom.sh 读取
cat << EOF > /home/build/immortalwrt/files/etc/config/pppoe-settings
enable_pppoe=${ENABLE_PPPOE}
pppoe_account=${PPPOE_ACCOUNT}
pppoe_password=${PPPOE_PASSWORD}
EOF

echo "cat pppoe-settings"
cat /home/build/immortalwrt/files/etc/config/pppoe-settings

if [ -z "$CUSTOM_PACKAGES" ]; then
  echo "⚪️ 未选择 任何第三方软件包"
else
  # 下载 run 文件仓库
  echo "🔄 正在同步第三方软件仓库 Cloning run file repo..."
  git clone --depth=1 https://github.com/wukongdaily/store.git /tmp/store-run-repo

  # 拷贝 run/arm64 下所有 run 文件和 ipk 文件到 extra-packages 目录
  mkdir -p /home/build/immortalwrt/extra-packages
  cp -r /tmp/store-run-repo/run/arm64/* /home/build/immortalwrt/extra-packages/

  echo "✅ Run files copied to extra-packages:"
  ls -lh /home/build/immortalwrt/extra-packages/*.run
  # 解压并拷贝 ipk 到 packages 目录
  sh shell/prepare-packages.sh
  ls -lah /home/build/immortalwrt/packages/
  # 添加架构优先级信息
  sed -i '1i\
  arch aarch64_generic 10\n\
  arch aarch64_cortex-a53 15' repositories.conf
fi

# 输出调试信息
echo "$(date '+%Y-%m-%d %H:%M:%S') - 开始构建 QEMU-arm64 固件..."

# ============================================================
# 官方 feed 软件包清单 —— 与 192.168.0.10 (ImmortalWrt 25.12.1 arm64) 对齐
# 由 Zo 于 2026-08-31 从 .10 实际 apk 清单逐项核对官方 feed 生成
# nikkii 生态（luci-app-nikki/nikki/mihomo-alpha）已内置（2026-09-01），
# 从 nikkii feed 下载 apk 到 packages/ 本地仓库；passwall 用 wukongdaily 离线包（官方 feed 缺 shadowsocks-rust 依赖）
# ============================================================

PACKAGES=""

# ---- app (47) ----
PACKAGES="$PACKAGES attendedsysupgrade-common"
PACKAGES="$PACKAGES attr"
PACKAGES="$PACKAGES avahi-dbus-daemon"
PACKAGES="$PACKAGES cgi-io"
PACKAGES="$PACKAGES chinadns-ng"
PACKAGES="$PACKAGES cloudflared"
PACKAGES="$PACKAGES curl"
PACKAGES="$PACKAGES daed"
PACKAGES="$PACKAGES daed-geoip"
PACKAGES="$PACKAGES daed-geosite"
PACKAGES="$PACKAGES dbus"
PACKAGES="$PACKAGES dns2socks"
PACKAGES="$PACKAGES etherwake"
PACKAGES="$PACKAGES filebrowser"
PACKAGES="$PACKAGES geoview"
PACKAGES="$PACKAGES haproxy"
PACKAGES="$PACKAGES hysteria"
PACKAGES="$PACKAGES ip-full"
PACKAGES="$PACKAGES ipt2socks"
PACKAGES="$PACKAGES lua"
PACKAGES="$PACKAGES luci"
PACKAGES="$PACKAGES microsocks"
PACKAGES="$PACKAGES mihomo-alpha"
PACKAGES="$PACKAGES miniupnpd-nftables"
PACKAGES="$PACKAGES nikki"
PACKAGES="$PACKAGES openssh-sftp-server"
PACKAGES="$PACKAGES ppp"
PACKAGES="$PACKAGES ppp-mod-pppoe"
PACKAGES="$PACKAGES samba4-libs"
PACKAGES="$PACKAGES samba4-server"
PACKAGES="$PACKAGES shellsync"
PACKAGES="$PACKAGES simple-obfs-client"
PACKAGES="$PACKAGES sing-box"
PACKAGES="$PACKAGES smartmontools"
PACKAGES="$PACKAGES softethervpn5-bridge"
PACKAGES="$PACKAGES softethervpn5-client"
PACKAGES="$PACKAGES softethervpn5-libs"
PACKAGES="$PACKAGES softethervpn5-server"
PACKAGES="$PACKAGES ttyd"
PACKAGES="$PACKAGES v2ray-geoip"
PACKAGES="$PACKAGES v2ray-geosite"
PACKAGES="$PACKAGES v2ray-plugin"
PACKAGES="$PACKAGES vlmcsd"
PACKAGES="$PACKAGES vsftpd"
PACKAGES="$PACKAGES xray-core"
PACKAGES="$PACKAGES yq"
PACKAGES="$PACKAGES zerotier"
PACKAGES="$PACKAGES zlib"
PACKAGES="$PACKAGES rtp2httpd"

# ---- luci (38) ----
PACKAGES="$PACKAGES luci-app-argon-config"
PACKAGES="$PACKAGES luci-app-attendedsysupgrade"
PACKAGES="$PACKAGES luci-app-cloudflared"
PACKAGES="$PACKAGES luci-app-daed"
PACKAGES="$PACKAGES luci-app-diskman"
PACKAGES="$PACKAGES luci-app-filebrowser-go"
PACKAGES="$PACKAGES luci-app-filemanager"
PACKAGES="$PACKAGES luci-app-firewall"
PACKAGES="$PACKAGES luci-app-homeproxy"
PACKAGES="$PACKAGES luci-app-openclash"
PACKAGES="$PACKAGES luci-app-nikki"
PACKAGES="$PACKAGES luci-app-package-manager"
PACKAGES="$PACKAGES luci-app-passwall"
PACKAGES="$PACKAGES luci-app-samba4"
PACKAGES="$PACKAGES luci-app-softethervpn"
PACKAGES="$PACKAGES luci-app-ttyd"
PACKAGES="$PACKAGES luci-app-upnp"
PACKAGES="$PACKAGES luci-app-vlmcsd"
PACKAGES="$PACKAGES luci-app-vsftpd"
PACKAGES="$PACKAGES luci-app-wol"
PACKAGES="$PACKAGES luci-app-zerotier"
PACKAGES="$PACKAGES luci-app-rtp2httpd"
PACKAGES="$PACKAGES luci-base"
PACKAGES="$PACKAGES luci-compat"
PACKAGES="$PACKAGES luci-lib-base"
PACKAGES="$PACKAGES luci-lib-ip"
PACKAGES="$PACKAGES luci-lib-jsonc"
PACKAGES="$PACKAGES luci-lib-nixio"
PACKAGES="$PACKAGES luci-lib-uqr"
PACKAGES="$PACKAGES luci-light"
PACKAGES="$PACKAGES luci-lua-runtime"
PACKAGES="$PACKAGES luci-mod-admin-full"
PACKAGES="$PACKAGES luci-mod-network"
PACKAGES="$PACKAGES luci-mod-status"
PACKAGES="$PACKAGES luci-mod-system"
PACKAGES="$PACKAGES luci-proto-ipv6"
PACKAGES="$PACKAGES luci-proto-ppp"
PACKAGES="$PACKAGES luci-theme-argon"
PACKAGES="$PACKAGES luci-theme-bootstrap"

# ---- i18n (21) ----
PACKAGES="$PACKAGES luci-i18n-argon-config-zh-cn"
PACKAGES="$PACKAGES luci-i18n-attendedsysupgrade-zh-cn"
PACKAGES="$PACKAGES luci-i18n-base-zh-cn"
PACKAGES="$PACKAGES luci-i18n-cloudflared-zh-cn"
PACKAGES="$PACKAGES luci-i18n-daed-zh-cn"
PACKAGES="$PACKAGES luci-i18n-diskman-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filebrowser-go-zh-cn"
PACKAGES="$PACKAGES luci-i18n-filemanager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-firewall-zh-cn"
PACKAGES="$PACKAGES luci-i18n-homeproxy-zh-cn"
PACKAGES="$PACKAGES luci-i18n-package-manager-zh-cn"
PACKAGES="$PACKAGES luci-i18n-nikki-zh-cn"
PACKAGES="$PACKAGES luci-i18n-passwall-zh-cn"
PACKAGES="$PACKAGES luci-app-passwall2 luci-i18n-passwall2-zh-cn"
PACKAGES="$PACKAGES luci-i18n-samba4-zh-cn"
PACKAGES="$PACKAGES luci-i18n-softethervpn-zh-cn"
PACKAGES="$PACKAGES luci-i18n-ttyd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-upnp-zh-cn"
PACKAGES="$PACKAGES luci-i18n-vlmcsd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-vsftpd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-rtp2httpd-zh-cn"
PACKAGES="$PACKAGES luci-i18n-wol-zh-cn"
PACKAGES="$PACKAGES luci-i18n-zerotier-zh-cn"

# ---- kmods (140) ----
PACKAGES="$PACKAGES kmod-acpi-mdio"
PACKAGES="$PACKAGES kmod-amazon-ena"
PACKAGES="$PACKAGES kmod-atlantic"
PACKAGES="$PACKAGES kmod-bcmgenet"
PACKAGES="$PACKAGES kmod-crypto-acompress"
PACKAGES="$PACKAGES kmod-crypto-aead"
PACKAGES="$PACKAGES kmod-crypto-arc4"
PACKAGES="$PACKAGES kmod-crypto-blake2b"
PACKAGES="$PACKAGES kmod-crypto-crc32"
PACKAGES="$PACKAGES kmod-crypto-crc32c"
PACKAGES="$PACKAGES kmod-crypto-ctr"
PACKAGES="$PACKAGES kmod-crypto-ecb"
PACKAGES="$PACKAGES kmod-crypto-gcm"
PACKAGES="$PACKAGES kmod-crypto-geniv"
PACKAGES="$PACKAGES kmod-crypto-gf128"
PACKAGES="$PACKAGES kmod-crypto-ghash"
PACKAGES="$PACKAGES kmod-crypto-hash"
PACKAGES="$PACKAGES kmod-crypto-hmac"
PACKAGES="$PACKAGES kmod-crypto-manager"
PACKAGES="$PACKAGES kmod-crypto-null"
PACKAGES="$PACKAGES kmod-crypto-rng"
PACKAGES="$PACKAGES kmod-crypto-seqiv"
PACKAGES="$PACKAGES kmod-crypto-sha1"
PACKAGES="$PACKAGES kmod-crypto-sha3"
PACKAGES="$PACKAGES kmod-crypto-sha512"
PACKAGES="$PACKAGES kmod-crypto-user"
PACKAGES="$PACKAGES kmod-crypto-xxhash"
PACKAGES="$PACKAGES kmod-dummy"
PACKAGES="$PACKAGES kmod-dwmac-imx"
PACKAGES="$PACKAGES kmod-dwmac-rockchip"
PACKAGES="$PACKAGES kmod-dwmac-sun8i"
PACKAGES="$PACKAGES kmod-e1000e"
PACKAGES="$PACKAGES kmod-fixed-phy"
PACKAGES="$PACKAGES kmod-fs-btrfs"
PACKAGES="$PACKAGES kmod-fs-exfat"
PACKAGES="$PACKAGES kmod-fs-ext4"
PACKAGES="$PACKAGES kmod-fs-msdos"
PACKAGES="$PACKAGES kmod-fs-ntfs3"
PACKAGES="$PACKAGES kmod-fs-vfat"
PACKAGES="$PACKAGES kmod-fsl-dpaa1-net"
PACKAGES="$PACKAGES kmod-fsl-dpaa2-net"
PACKAGES="$PACKAGES kmod-fsl-enetc-net"
PACKAGES="$PACKAGES kmod-fsl-fec"
PACKAGES="$PACKAGES kmod-fsl-mc-dpio"
PACKAGES="$PACKAGES kmod-fsl-pcs-lynx"
PACKAGES="$PACKAGES kmod-fsl-xgmac-mdio"
PACKAGES="$PACKAGES kmod-gpio-pca953x"
PACKAGES="$PACKAGES kmod-hwmon-core"
PACKAGES="$PACKAGES kmod-i2c-core"
PACKAGES="$PACKAGES kmod-i2c-mux"
PACKAGES="$PACKAGES kmod-i2c-mux-pca954x"
PACKAGES="$PACKAGES kmod-inet-diag"
PACKAGES="$PACKAGES kmod-lib-crc-ccitt"
PACKAGES="$PACKAGES kmod-lib-crc-itu-t"
PACKAGES="$PACKAGES kmod-lib-crc16"
PACKAGES="$PACKAGES kmod-lib-crc32c"
PACKAGES="$PACKAGES kmod-lib-lzo"
PACKAGES="$PACKAGES kmod-lib-raid6"
PACKAGES="$PACKAGES kmod-lib-xor"
PACKAGES="$PACKAGES kmod-lib-xxhash"
PACKAGES="$PACKAGES kmod-lib-zlib-deflate"
PACKAGES="$PACKAGES kmod-lib-zlib-inflate"
PACKAGES="$PACKAGES kmod-lib-zstd"
PACKAGES="$PACKAGES kmod-libphy"
PACKAGES="$PACKAGES kmod-macsec"
PACKAGES="$PACKAGES kmod-macvlan"
PACKAGES="$PACKAGES kmod-marvell-mdio"
PACKAGES="$PACKAGES kmod-mdio-bcm-unimac"
PACKAGES="$PACKAGES kmod-mdio-bus-mux"
PACKAGES="$PACKAGES kmod-mdio-devres"
PACKAGES="$PACKAGES kmod-mdio-gpio"
PACKAGES="$PACKAGES kmod-mii"
PACKAGES="$PACKAGES kmod-mppe"
PACKAGES="$PACKAGES kmod-mvneta"
PACKAGES="$PACKAGES kmod-mvpp2"
PACKAGES="$PACKAGES kmod-net-selftests"
PACKAGES="$PACKAGES kmod-netlink-diag"
PACKAGES="$PACKAGES kmod-nf-conntrack"
PACKAGES="$PACKAGES kmod-nf-conntrack-netlink"
PACKAGES="$PACKAGES kmod-nf-conntrack6"
PACKAGES="$PACKAGES kmod-nf-flow"
PACKAGES="$PACKAGES kmod-nf-log"
PACKAGES="$PACKAGES kmod-nf-log6"
PACKAGES="$PACKAGES kmod-nf-nat"
PACKAGES="$PACKAGES kmod-nf-nathelper"
PACKAGES="$PACKAGES kmod-nf-reject"
PACKAGES="$PACKAGES kmod-nf-reject6"
PACKAGES="$PACKAGES kmod-nf-socket"
PACKAGES="$PACKAGES kmod-nf-tproxy"
PACKAGES="$PACKAGES kmod-nfnetlink"
PACKAGES="$PACKAGES kmod-nft-core"
PACKAGES="$PACKAGES kmod-nft-fib"
PACKAGES="$PACKAGES kmod-nft-fullcone"
PACKAGES="$PACKAGES kmod-nft-nat"
PACKAGES="$PACKAGES kmod-nft-offload"
PACKAGES="$PACKAGES kmod-nft-socket"
PACKAGES="$PACKAGES kmod-nft-tproxy"
PACKAGES="$PACKAGES kmod-nls-base"
PACKAGES="$PACKAGES kmod-nls-cp437"
PACKAGES="$PACKAGES kmod-nls-cp932"
PACKAGES="$PACKAGES kmod-nls-cp936"
PACKAGES="$PACKAGES kmod-nls-cp950"
PACKAGES="$PACKAGES kmod-nls-iso8859-1"
PACKAGES="$PACKAGES kmod-nls-utf8"
PACKAGES="$PACKAGES kmod-octeontx2-net"
PACKAGES="$PACKAGES kmod-of-mdio"
PACKAGES="$PACKAGES kmod-pcs-xpcs"
PACKAGES="$PACKAGES kmod-phy-aquantia"
PACKAGES="$PACKAGES kmod-phy-bcm7xxx"
PACKAGES="$PACKAGES kmod-phy-broadcom"
PACKAGES="$PACKAGES kmod-phy-marvell"
PACKAGES="$PACKAGES kmod-phy-realtek"
PACKAGES="$PACKAGES kmod-phy-smsc"
PACKAGES="$PACKAGES kmod-phylib-broadcom"
PACKAGES="$PACKAGES kmod-phylink"
PACKAGES="$PACKAGES kmod-ppp"
PACKAGES="$PACKAGES kmod-pppoe"
PACKAGES="$PACKAGES kmod-pppox"
PACKAGES="$PACKAGES kmod-pps"
PACKAGES="$PACKAGES kmod-ptp"
PACKAGES="$PACKAGES kmod-regmap-core"
PACKAGES="$PACKAGES kmod-regmap-i2c"
PACKAGES="$PACKAGES kmod-renesas-net-avb"
PACKAGES="$PACKAGES kmod-rtc-rx8025"
PACKAGES="$PACKAGES kmod-sched-bpf"
PACKAGES="$PACKAGES kmod-sched-core"
PACKAGES="$PACKAGES kmod-scsi-core"
PACKAGES="$PACKAGES kmod-sfp"
PACKAGES="$PACKAGES kmod-slhc"
PACKAGES="$PACKAGES kmod-stmmac-core"
PACKAGES="$PACKAGES kmod-tun"
PACKAGES="$PACKAGES kmod-usb-common"
PACKAGES="$PACKAGES kmod-usb-core"
PACKAGES="$PACKAGES kmod-usb-storage"
PACKAGES="$PACKAGES kmod-usb-storage-extras"
PACKAGES="$PACKAGES kmod-usb-storage-uas"
PACKAGES="$PACKAGES kmod-veth"
PACKAGES="$PACKAGES kmod-vmxnet3"
PACKAGES="$PACKAGES kmod-wdt-sp805"
PACKAGES="$PACKAGES kmod-xdp-sockets-diag"

# ---- nikkii 生态 + passwall2 离线包（内置）----
# nikkii 来源：https://nikkinikki.pages.dev/openwrt-25.12/aarch64_generic/nikki/
# passwall 用官方 feed（26.9.1，官方 feed 25.12.1 已含 shadowsocks-rust-sslocal/ssserver 依赖）
# 全部 PACKAGES 用裸包名（严禁 =ver 钉死——会毒化 world 里后续所有包）
NIKKI_FEED="https://nikkinikki.pages.dev/openwrt-25.12/aarch64_generic/nikki"
mkdir -p /home/build/immortalwrt/packages
for pkg in \
  "luci-app-nikki-1.26.1-r1.apk" \
  "luci-i18n-nikki-zh-cn-26.226.20072~8aaa68c.apk" \
  "nikki-2026.04.08-r1.apk" \
  "mihomo-alpha-2026.08.13.apk"; do
  echo "⬇️  下载 nikkii 包: $pkg"
  wget -q "$NIKKI_FEED/$pkg" -O "/home/build/immortalwrt/packages/$pkg" || { echo "❌ 下载失败: $pkg"; exit 1; }
done
# passwall2 离线包（wukongdaily/apk 仓库 run/arm64/passwall2，官方 feed 无 passwall2）
# 依赖 geoview/xray-core/sing-box/hysteria/kmod-nft-socket/kmod-nft-tproxy 已在官方 PACKAGES 清单
echo "⬇️  下载 passwall2 离线包"
mkdir -p /tmp/pw2-extract
wget -q "https://raw.githubusercontent.com/wukongdaily/apk/master/run/arm64/passwall2/luci-app-passwall2-26.5.1-r1.apk" -O /home/build/immortalwrt/packages/luci-app-passwall2-26.5.1-r1.apk || { echo "❌ passwall2 app 下载失败"; exit 1; }
wget -q "https://raw.githubusercontent.com/wukongdaily/apk/master/run/arm64/passwall2/luci-i18n-passwall2-zh-cn-26.5.1.apk" -O /home/build/immortalwrt/packages/luci-i18n-passwall2-zh-cn-26.5.1.apk || { echo "❌ passwall2 i18n 下载失败"; exit 1; }
ls -lah /home/build/immortalwrt/packages/luci-app-passwall2* /home/build/immortalwrt/packages/luci-i18n-passwall2*
# rtp2httpd 用 GitHub 官方 release v3.17.0（官方源是 3.16.0，落后）
# 注意：apk 文件名必须无架构后缀（与 nikkii 一致），否则 apk mkndx 索引不识别
echo "⬇️  下载 rtp2httpd v3.17.0 (GitHub)"
RTP2HTTPD_RELEASE="https://github.com/stackia/rtp2httpd/releases/download/v3.17.0"
wget -q "$RTP2HTTPD_RELEASE/rtp2httpd-3.17.0-r1_aarch64_generic.apk" -O /home/build/immortalwrt/packages/rtp2httpd-3.17.0-r1.apk || { echo "❌ rtp2httpd 下载失败"; exit 1; }
wget -q "$RTP2HTTPD_RELEASE/luci-app-rtp2httpd-3.17.0-r1.apk" -O /home/build/immortalwrt/packages/luci-app-rtp2httpd-3.17.0-r1.apk || { echo "❌ luci-app-rtp2httpd 下载失败"; exit 1; }
wget -q "$RTP2HTTPD_RELEASE/luci-i18n-rtp2httpd-zh-cn-3.17.0.apk" -O /home/build/immortalwrt/packages/luci-i18n-rtp2httpd-zh-cn-3.17.0.apk || { echo "❌ luci-i18n-rtp2httpd 下载失败"; exit 1; }
ls -lah /home/build/immortalwrt/packages/rtp2httpd* /home/build/immortalwrt/packages/luci-app-rtp2httpd* /home/build/immortalwrt/packages/luci-i18n-rtp2httpd*

# 判断是否需要编译 Docker 插件
if [ "$INCLUDE_DOCKER" = "yes" ]; then
    PACKAGES="$PACKAGES luci-i18n-dockerman-zh-cn"
    echo "Adding package: luci-i18n-dockerman-zh-cn"
fi

# 若构建 openclash 则预置 clash core + 规则库
# luci-app-openclash 本体来自官方 feed（0.47.075，与 192.168.0.10 同版），
# 这里只放 core 二进制和 Geo 规则，不额外下载 ipk，避免与官方 feed 包冲突
if echo "$PACKAGES" | grep -q "luci-app-openclash"; then
    echo "✅ 已选择 luci-app-openclash，添加 openclash core"
    mkdir -p files/etc/openclash/core
    # Download clash_meta core (arm64, core 分支)
    META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz"
    wget -qO- $META_URL | tar xOvz > files/etc/openclash/core/clash_meta
    chmod +x files/etc/openclash/core/clash_meta
    # Download GeoIP and GeoSite
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat -O files/etc/openclash/GeoIP.dat
    wget -q https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O files/etc/openclash/GeoSite.dat
else
    echo "⚪️ 未选择 luci-app-openclash"
fi

if echo "$PACKAGES" | grep -q "luci-app-ssr-plus"; then
    echo "✅ 已选择 luci-app-ssr-plus，添加 mihomo core"
    mkdir -p files/usr/bin
    # Download mihomo
    MIHOMO_URL="https://github.com/MetaCubeX/mihomo/releases/download/v1.19.24/mihomo-linux-arm64-v1.19.24.gz"
    mkdir -p files/usr/bin
    wget -qO- "$MIHOMO_URL" | gzip -dc > files/usr/bin/mihomo
    chmod +x files/usr/bin/mihomo
    echo "✅ 已下载 mihomo core"
    ls -lah files/usr/bin
else
    echo "⚪️ 未选择 luci-app-ssr-plus"
fi

# 构建镜像
echo "$(date '+%Y-%m-%d %H:%M:%S') - Building image with the following packages:"
echo "$PACKAGES"

make image PROFILE=$PROFILE PACKAGES="$PACKAGES" FILES="/home/build/immortalwrt/files" ROOTFS_PARTSIZE=$ROOTFS_PARTSIZE

if [ $? -ne 0 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Error: Build failed!"
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') - Build completed successfully."

