#!/bin/bash
#删除软件包
rm -rf $(find ../feeds/luci/ -type d -regex ".*\(luci-app-ssr-plus\|passwall\|aliyundrive-webdav\|openclash\|mosdns\|dockerman\|adguardhome\|alist\|luci-app-unblockneteasemusic\).*")

#删除冲突核心 packages 
rm -rf $(find ../feeds/packages/ -type d -regex ".*\(alist\|mosdns\|aliyundrive-webdav\).*")

##git仓库  "$4"可拉仓库子目录
CURRENT_PATH=$(pwd)
UPDATE_PACKAGE() {
  # 参数检查
  if [ "$#" -lt 2 ]; then
    echo "Usage: UPDATE_PACKAGE <git_url> <branch> [target_directory] [subdirectory]"
    return 1
  fi
  local git_url="$1"
  local branch="$2"
  local source_target_directory="$3"
  local target_directory="$3"
  local subdirectory="$4"
  #检测是否 git子目录
  if [ -n "$subdirectory" ]; then
    target_directory=$CURRENT_PATH/repos/$(echo "$git_url" | awk -F'/' '{print $(NF-1)"-"$NF}')
  fi
  # 检查目标目录是否存在
  if [ -d "$target_directory" ]; then
    pushd "$target_directory" || return 1
    git pull
    popd
  else
    if [ -n "$branch" ]; then
      git clone --depth=1 -b $branch $git_url $target_directory
    else
      git clone --depth=1 $git_url $target_directory
    fi
  fi
  
  if [ -n "$subdirectory" ]; then
    cp -a $target_directory/$subdirectory ./$source_target_directory
    rm -rf $target_directory
  fi
}
# 用法举例
#UPDATE_PACKAGE "https://github.com/xxx/yyy" "分支名" "目标目录" "git 子目录"
#UPDATE_PACKAGE "https://github.com/xxx/yyy" "master" "package/luci-xxx"  "applications/xxx"
#UPDATE_PACKAGE "https://github.com/xxx/yyy" "" "package/luci-xxx" "applications/xxx"
#UPDATE_PACKAGE "https://github.com/xxx/yyy"

# git拉取子目录
UPDATE_PACKAGE "https://github.com/messense/aliyundrive-webdav" "main" "" "openwrt/aliyundrive-webdav"
UPDATE_PACKAGE "https://github.com/messense/aliyundrive-webdav" "main" "" "openwrt/luci-app-aliyundrive-webdav"

# 正常git clone
UPDATE_PACKAGE "https://github.com/muink/luci-app-tinyfilemanager" "master"
UPDATE_PACKAGE "https://github.com/gngpp/luci-theme-design" "$([[ $REPO_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "https://github.com/gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "https://github.com/jerrykuku/luci-theme-argon" "$([[ $REPO_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "https://github.com/jerrykuku/luci-app-argon-config" "$([[ $REPO_URL == *"lede"* ]] && echo "18.06" || echo "master")"
UPDATE_PACKAGE "https://github.com/sirpdboy/luci-theme-kucat.git" "$([[ $REPO_URL == *"lede"* ]] && echo "main" || echo "js")"
UPDATE_PACKAGE "https://github.com/sirpdboy/luci-app-advancedplus.git" "main"
UPDATE_PACKAGE "https://github.com/xiaorouji/openwrt-passwall" "main"
UPDATE_PACKAGE "https://github.com/xiaorouji/openwrt-passwall2" "main"
UPDATE_PACKAGE "https://github.com/xiaorouji/openwrt-passwall-packages" "main"
UPDATE_PACKAGE "https://github.com/fw876/helloworld" "master"
UPDATE_PACKAGE "https://github.com/vernesong/OpenClash" "master"
UPDATE_PACKAGE "https://github.com/sbwml/luci-app-alist.git" "master"
UPDATE_PACKAGE "https://github.com/chenmozhijin/luci-app-adguardhome.git" "master"
UPDATE_PACKAGE "https://github.com/lisaac/luci-app-dockerman.git" "master"
UPDATE_PACKAGE "https://github.com/sbwml/luci-app-mosdns.git" "v5"
UPDATE_PACKAGE "https://github.com/gdy666/luci-app-lucky.git" "main"
UPDATE_PACKAGE "https://github.com/padavanonly/luci-app-mwan3helper-chinaroute.git" "main"
UPDATE_PACKAGE "https://github.com/tty228/luci-app-wechatpush" "master"
UPDATE_PACKAGE "https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic" "$([[ $REPO_URL == *"lede"* ]] && echo "master" || echo "js")"
UPDATE_PACKAGE "https://github.com/sirpdboy/netspeedtest" "master"

##根据源码修改 21.02  删除/更新 指定路径冲突插件或者核心
if [[ $REPO_URL == *"immortalwrt-mt798x"* || *"mt798x-immortalwrt"* ]] ; then 
  cd ..
  
  #更新golang 
  rm -rf feeds/packages/lang/golang
  git clone https://github.com/sbwml/packages_lang_golang -b 21.x ./feeds/packages/lang/golang
  #更新adblock广告过滤
  #rm -rf feeds/packages/net/adblock
  #rm -rf feeds/luci/applications/luci-app-adblock
  #svn export https://github.com/coolsnowwolf/luci/trunk/applications/luci-app-adblock ./feeds/luci/applications/luci-app-adblock
  #svn export https://github.com/coolsnowwolf/packages/trunk/net/adblock ./feeds/packages/net/adblock
  #更新tailscale
  #rm -rf feeds/packages/net/tailscale
  #svn export https://github.com/immortalwrt/packages/trunk/net/tailscale ./feeds/packages/net/tailscale

  cd package
fi


##根据源码修改 23.05 Home Proxy
if [[ $REPO_URL == *"immortalwrt/immortalwrt"* ]] ; then
  rm -rf ../feeds/luci/applications/luci-app-homeproxy
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
