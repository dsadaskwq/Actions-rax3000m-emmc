#!/bin/bash
#删除软件包
rm -rf $(find ../feeds/luci/ -type d -regex ".*\(luci-app-ssr-plus\).*")

#删除冲突核心 packages 
rm -rf $(find ../feeds/packages/ -type d -regex ".*\(alist\|mosdns\).*")

#更新软件包luci
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | rev | cut -d'/' -f 1 | rev)
	
	rm -rf $(find ../feeds/luci/ -type d -iname "*$PKG_NAME*" -prune)
    
	git clone --depth=1 --single-branch --branch $PKG_BRANCH $PKG_REPO
        echo "PKG_NAME=$PKG_NAME"
        if [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
        fi
}
###仓库单独拉一个文件夹 替代SVN
# $1=被拉文件夹路径  $2=仓库地址 $3=BRANCH
SVN_PACKAGE() {
	local PKG_PATH=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local REPO_NAME=$(echo $PKG_REPO | rev | cut -d'/' -f 1 | rev)
	local SVN_NAME=$(echo $PKG_PATH | rev | cut -d'/' -f 1 | rev)
	
	git clone --depth=1 --single-branch --branch $PKG_BRANCH $PKG_REPO
        echo "SVN_NAME=$SVN_NAME"
	mv $REPO_NAME/$PKG_PATH ./
        rm -rf $REPO_NAME
}

SVN_PACKAGE "openwrt/aliyundrive-webdav" "https://github.com/messense/aliyundrive-webdav" "main"
SVN_PACKAGE "openwrt/luci-app-aliyundrive-webdav" "https://github.com/messense/aliyundrive-webdav" "main"

UPDATE_PACKAGE "tinyfilemanager" "https://github.com/muink/luci-app-tinyfilemanager" "master"
UPDATE_PACKAGE "design" "https://github.com/gngpp/luci-theme-design" "$([[ $REPO_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "design-config" "https://github.com/gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "https://github.com/jerrykuku/luci-theme-argon" "$([[ $REPO_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "argon-config" "https://github.com/jerrykuku/luci-app-argon-config" "$([[ $REPO_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "luci-theme-kucat" "https://github.com/dsadaskwq/luci-theme-kucat.git" "$([[ $REPO_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "luci-app-advancedplus" "https://github.com/sirpdboy/luci-app-advancedplus.git" "main"
UPDATE_PACKAGE "passwall" "https://github.com/xiaorouji/openwrt-passwall" "main"
UPDATE_PACKAGE "passwall2" "https://github.com/xiaorouji/openwrt-passwall2" "main"
UPDATE_PACKAGE "passwall-packages" "https://github.com/xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "helloworld" "https://github.com/fw876/helloworld" "master"
UPDATE_PACKAGE "openclash" "https://github.com/vernesong/OpenClash" "master"
UPDATE_PACKAGE "alist" "https://github.com/sbwml/luci-app-alist.git" "master"
UPDATE_PACKAGE "adguardhome" "https://github.com/chenmozhijin/luci-app-adguardhome.git" "master"
UPDATE_PACKAGE "dockerman" "https://github.com/lisaac/luci-app-dockerman.git" "master"
UPDATE_PACKAGE "mosdns" "https://github.com/sbwml/luci-app-mosdns.git" "v5"
UPDATE_PACKAGE "lucky" "https://github.com/gdy666/luci-app-lucky.git" "main"
UPDATE_PACKAGE "luci-app-mwan3helper-chinaroute" "https://github.com/padavanonly/luci-app-mwan3helper-chinaroute.git" "main"

##根据源码修改 21.02  删除/更新 指定路径冲突插件或者核心
if [[ $REPO_URL == *"immortalwrt-mt798x"* ]] ; then 
  
  #更新golang 
  rm -rf ../feeds/packages/lang/golang
  git clone https://github.com/sbwml/packages_lang_golang -b 21.x ../feeds/packages/lang/golang
  #更新adblock广告过滤
  #SVN_PACKAGE "applications/luci-app-adblock" "https://github.com/coolsnowwolf/luci" "master"
  #SVN_PACKAGE "net/adblock" "https://github.com/coolsnowwolf/packages" "master"
  #mv svn-package/luci-app-adblock ../feeds/luci/applications/luci-app-adblock
  #mv svn-package/adblock ../feeds/packages/net/adblock
  #更新tailscale
  #rm -rf ../feeds/packages/net/tailscale
  #svn export https://github.com/immortalwrt/packages/trunk/net/tailscale ../feeds/packages/net/tailscale
  #SVN_PACKAGE "net/tailscale" "https://github.com/immortalwrt/packages" "master"
  #mv svn-package/tailscale ../feeds/packages/net/tailscale
fi


##根据源码修改 23.05 Home Proxy
if [[ $REPO_URL == *"immortalwrt/immortalwrt"* ]] ; then
  git clone --depth=1 --single-branch --branch "dev" https://github.com/immortalwrt/homeproxy.git
fi

#修改Tiny Filemanager汉化
if [ -d *"tinyfilemanager"* ]; then
	PO_FILE="./luci-app-tinyfilemanager/po/zh_Hans/tinyfilemanager.po"
	sed -i '/msgid "Tiny File Manager"/{n; s/msgstr.*/msgstr "文件管理器"/}' $PO_FILE
	sed -i 's/启用用户验证/用户验证/g;s/家目录/初始目录/g;s/Favicon 路径/收藏夹图标路径/g;s/存储//g' $PO_FILE

	echo "tinyfilemanager date has been updated!"
fi

if [[ $USE_IPK == "true" ]] ; then
    #部分插件调整到status 状态
    sed -i 's/services/status/g' ./feeds/luci/luci-app-nlbwmon/root/usr/share/luci/menu.d/luci-app-nlbwmon.json
    sed -i 's/network/status/g' ./mtk/applications/luci-app-wrtbwmon/root/usr/share/luci/menu.d/luci-app-wrtbwmon.json
    #部分插件调整到nas 网络储存
    sed -i 's/services/nas/g' ./luci-app-aliyundrive-webdav/luasrc/controller/*.lua
    sed -i 's/services/nas/g' ./luci-app-aliyundrive-webdav/luasrc/view/aliyundrive-webdav/*.htm

    sed -i 's/services/nas/g' ./feeds/luci/luci-app-wol/root/usr/share/luci/menu.d/luci-app-wol.json

    sed -i 's/services/nas/g' ./feeds/luci/luci-app-ksmbd/root/usr/share/luci/menu.d/luci-app-ksmbd.json
    #部分插件调整到vpn
    sed -i 's/services/vpn/g' ./feeds/luci/luci-app-uugamebooster/luasrc/controller/*.lua
    sed -i 's/services/vpn/g' ./feeds/luci/luci-app-uugamebooster/luasrc/view/uugamebooster/*.htm
    #部分插件调整到network 网络
    #sed -i 's/services/network/g' ./mtk/applications/luci-app-eqos-mtk/root/usr/share/luci/menu.d/luci-app-eqos.json
  
fi
