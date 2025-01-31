#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")


#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

cp -rf $GITHUB_WORKSPACE/banner package/base-files/files/etc
chmod +x package/base-files/files/etc/*

cp -f $GITHUB_WORKSPACE/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

find ./package/base-files/files/etc/ -type f -name "openwrt_version" -exec sh -c ': > "$1"' _ {} \;
CURRENT_TIME=$(date +"%Y-%m-%d") && sed -i "s/^DISTRIB_DESCRIPTION='.*'/DISTRIB_DESCRIPTION='布丁智能科技 © 蓝色的海 compiled in $CURRENT_TIME'/g" $(find ./package/base-files/files/etc/ -type f -name "openwrt_release")
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE


#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#添加编译日期标识
CURRENT_TIME=$(date +"%Y-%m-%d") && sed -i "/('Firmware Version')/!b;/_('Kernel Version')/!{N;s/\('Firmware Version'\),.*,_('Kernel Version')/\('Firmware Version'\), (' $WRT_NAME ') + (' \/ 布丁智能科技 © 蓝色的海 compiled in $CURRENT_TIME'), _('Kernel Version')/}" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")



#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config


#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#高通平台锁定512M内存
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	echo "CONFIG_IPQ_MEM_PROFILE_1024=n" >> ./.config
	echo "CONFIG_IPQ_MEM_PROFILE_512=y" >> ./.config
	echo "CONFIG_ATH11K_MEM_PROFILE_1G=n" >> ./.config
	echo "CONFIG_ATH11K_MEM_PROFILE_512M=y" >> ./.config
fi

#科学插件设置
 	echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-passwall=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
        echo "CONFIG_PACKAGE_luci-app-v2raya=y" >> ./.config
        echo "CONFIG_PACKAGE_luci-app-appfilter=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-ddns-go=y" >> ./.config
        echo "CONFIG_PACKAGE_luci-app-mosdns=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-store=y" >> ./.config

