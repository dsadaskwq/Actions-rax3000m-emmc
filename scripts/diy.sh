#!/bin/bash
#修改默认IP地址
REPO_IP="192.168.2.1"
echo "REPO_IP=$REPO_IP" >> $GITHUB_ENV
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$REPO_IP/g" package/base-files/files/bin/config_generate

#根据源码来修改 openwrt-21.02
if [[ $REPO_URL == *"immortalwrt-mt798x"* || *"mt798x-immortalwrt"* ]] ; then
  #修改默认WIFI名
  if [[ $MODIFY_WIFI == "true" ]] ; then
      #mtwifi-cfg
      sed -i "s/ssid=\"ImmortalWrt-2.4G\"/ssid=\"$USE_WIFI\"/" ./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
      sed -i "s/ssid=\"ImmortalWrt-5G\"/ssid=\"$USE_WIFI\_5G\"/" ./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
  
      sed -i "s/SSID1=MT7981_AX3000_2.4G/SSID1=$USE_WIFI/" ./package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
      sed -i "s/SSID1=MT7981_AX3000_5G/SSID1=$USE_WIFI\_5G/" ./package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat
      sed -i "s/SSID1=MT7986_AX6000_2.4G/SSID1=$USE_WIFI/" ./package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b0.dat
      sed -i "s/SSID1=MT7986_AX6000_5G/SSID1=$USE_WIFI\_5G/" ./package/mtk/drivers/wifi-profile/files/mt7986/mt7986-ax6000.dbdc.b1.dat
  fi
  #配置文件修改_关闭内存优化_512M推荐关闭
  if [[ $USE_MEMORY_SHRINK == "false" ]] ; then
      AX3000_CONFIG="./defconfig/mt7981-ax3000.config"
      MTWIFI_CONFIG="./defconfig/mt7981-ax3000-mtwifi-cfg.config"
      sed -i '/CONFIG_MTK_MEMORY_SHRINK/d' $AX3000_CONFIG
      sed -i '/CONFIG_MTK_MEMORY_SHRINK/d' $MTWIFI_CONFIG
  fi
  #去除首页cpu频率加快首页加载
  #sed -i "s/cpu_freq=\"\$(mhz | awk \-F 'cpu_MHz=' '{printf(\"\%.fMHz\",\$2)}')\"/cpu_freq=\"\"/g" package/emortal/autocore/files/generic/cpuinfo
fi

#根据源码来修改 openwrt-23.05
if [[ $REPO_URL == *"immortalwrt/immortalwrt"* ]] ; then
  #修改默认WIFI名
  sed -i "s/ssid=.*/ssid=$USE_WIFI/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
fi

#Delete DDNS's examples
sed -i '/myddns_ipv4/,$d' feeds/packages/net/ddns-scripts/files/etc/config/ddns
