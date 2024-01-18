#!/bin/bash
#=================================================
# File name: preset-clash-core.sh
# Usage: <preset-clash-core.sh $platform> | example: <preset-clash-core.sh armv8>
# System Required: Linux
# Version: 1.0
# Lisence: MIT
# Author: SuLingGG
# Blog: https://mlapp.cn
#=================================================


# 预置openclash内核
mkdir -p files/etc/openclash/core


# dev内核
CLASH_DEV_URL="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-arm64.tar.gz"
# premium内核
CLASH_TUN_URL="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz"
# Meta内核版本
CLASH_META_URL="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz"

wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
#wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
# 给内核权限
chmod +x files/etc/openclash/core/clash*

# meta 要GeoIP.dat 和 GeoSite.dat
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat

# Country.mmdb
COUNTRY_LITE_URL=https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/lite/Country.mmdb
# COUNTRY_FULL_URL=https://raw.githubusercontent.com/alecthw/mmdb_china_ip_list/release/Country.mmdb
wget -qO- $COUNTRY_LITE_URL > files/etc/openclash/Country.mmdb
# wget -qO- $COUNTRY_FULL_URL > files/etc/openclash/Country.mmdb

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_PATCH="./homeproxy/root/etc/homeproxy/resources"

	UPDATE_RESOURCES() {
		local RES_TYPE=$1
		local RES_REPO=$(echo "$2" | tr '[:upper:]' '[:lower:]')
		local RES_BRANCH=$3
		local RES_FILE=$4
		local RES_EXT=${4##*.}
		local RES_DEPTH=${5:-1}

		git clone -q --depth=$RES_DEPTH --single-branch --branch $RES_BRANCH "https://github.com/$RES_REPO.git" ./$RES_TYPE/

		cd ./$RES_TYPE/

		if [[ $RES_EXT == "txt" ]]; then
			echo $(git log -1 --pretty=format:'%s' -- $RES_FILE | grep -o "[0-9]*") > "$RES_TYPE".ver
			mv -f $RES_FILE "$RES_TYPE"."$RES_EXT"
		elif [[ $RES_EXT == "zip" ]]; then
			local REPO_ID=$(echo -n "$RES_REPO" | md5sum | cut -d ' ' -f 1)
			local REPO_VER=$(git log -1 --pretty=format:'%s' | cut -d ' ' -f 1)
			echo "{ \"$REPO_ID\": { \"repo\": \"$(echo $RES_REPO | sed 's/\//\\\//g')\", \"version\": \"$REPO_VER\" } }" > "$RES_TYPE".ver
			curl -sfL -O "https://github.com/$RES_REPO/archive/$RES_FILE"
			mv -f $RES_FILE $HP_PATCH/"${RES_REPO//\//_}"."$RES_EXT"
		elif [[ $RES_EXT == "db" ]]; then
			local RES_VER=$(git tag | tail -n 1)
			echo $RES_VER > "$RES_TYPE".ver
			curl -sfL -O "https://github.com/$RES_REPO/releases/download/$RES_VER/$RES_FILE"
		fi

		cp -f "$RES_TYPE".* $HP_PATCH/
		chmod +x $HP_PATCH/*

		cd .. && rm -rf ./$RES_TYPE/
	}

	UPDATE_RESOURCES "china_ip4" "1715173329/IPCIDR-CHINA" "master" "ipv4.txt" "5"
	UPDATE_RESOURCES "china_ip6" "1715173329/IPCIDR-CHINA" "master" "ipv6.txt" "5"
	UPDATE_RESOURCES "gfw_list" "Loyalsoldier/v2ray-rules-dat" "release" "gfw.txt"
	UPDATE_RESOURCES "china_list" "Loyalsoldier/v2ray-rules-dat" "release" "direct-list.txt"
	#UPDATE_RESOURCES "geoip" "1715173329/sing-geoip" "master" "geoip.db"
	#UPDATE_RESOURCES "geosite" "1715173329/sing-geosite" "master" "geosite.db"
	#UPDATE_RESOURCES "clash_dashboard" "MetaCubeX/metacubexd" "gh-pages" "gh-pages.zip"

	echo "homeproxy date has been updated!"
fi
