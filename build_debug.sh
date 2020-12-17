# 先执行命令 gem install fir-cli 再执行命令 fir login，需要安装 ruby 环境，然后执行该脚本，该脚本可以自动生成 debug 包然后上传到 fir.im，如果 fir.im 使用 webhook 绑定企业微信群机器人，群成员将都会收到通知
# 注意：将 latest_changelog_raw=$(curl 后的链接换成自己的，latest/ 后是应用 id，可在 "应用管理" -> "基本信息" 查看，api_token 是 fir.im 上的用户 token（点用户头像/API token），参考文档：https://betaqr.com/docs/version_detection
# clean archive
if [ "-c" == $1 ]; then
    /bin/rm -rf ./.temp
fi

# update build version
build_version=$(date +%y.%m.%d.%H.%M)
temp_dir="./.temp/$build_version"

# write changelog
log_dir="$temp_dir/log"
log_path="$log_dir/changelog.log"
mkdir -p "$temp_dir/log"

read -n1 -p "是否读取上个版本changelog [Y/N]?" can_read_latest_changelog
echo "如果不读取，则将要使用 vim 输入 changelog(更新内容)"
case $can_read_latest_changelog in
Y | y)
    latest_changelog_raw=$(curl https://api.bq04.com/apps/latest/你的appid\?api_token\=你的fir上的token)
    latest_changelog=$(./.utils/json "$latest_changelog_raw" "changelog")
    echo "$latest_changelog" >>$log_path
    ;;
*)
    touch $log_path
    ;;
esac

vim $log_path
cat $log_path
log_text=$(cat $log_path)


./gradlew assembleDebug
apk_path="./app/build/outputs/apk/debug/app-debug.apk"

# publish to fir
# > gem install fir-cli
# > fir login
fir p $apk_path -c "$log_text"
open https://www.betaqr.com/apps/5faa62f5b2eb4615d45f0bfc