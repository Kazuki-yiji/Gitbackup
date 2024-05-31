#!/bin/bash
clear;
IP=$(curl -s ipinfo.io/ip)
IFCN=$(curl -s ipinfo.io/${IP}/country) # 判断是否为中国 IP
IFInstall="????" #是否初始化
email="?email?" #GitHub邮箱
username="?username?" #GitHub用户名
Repositories="?Repositories?" #GitHub库名称
filepath="?filepath?" #文件路径，请不要更改！
day="?day?" #备份保留天数
echo 'Please note: GitHub is part of Microsoft';
echo '--------------------------------------------------------------------';
echo 'GitHub自动备份 Version 1.7';
echo 'https://github.com/Kazuki-yiji/Gitbackup';
echo 'GitHub@Kazuki-yiji Email:kazuki@kazami.cn';
[ "$IFCN" = "CN" ] && echo "警告:CN服务器可能连不上GitHub"
echo '--------------------------------------------------------------------';

#Version 1.7
Install() {
    echo '未检测到配置文件,开启配置向导...'; #第一次运行
    echo '--------------------------------------------------------------------';
    sleep 2 #延时2秒
    if ! type git &>/dev/null; then #检测Git
        if type apt &>/dev/null; then
            echo "安装 Git..."
            sudo apt install -y git
        elif type yum &>/dev/null; then
            echo "安装 Git..."
            yum install -y git
        else
            echo "未知的系统,请手动安装 Git。"
            exit 1
        fi
    fi
    if ! type git-lfs &>/dev/null; then # 检测Git LFS
        if type apt &>/dev/null; then
            echo "安装 Git LFS..."
            sudo apt install -y git-lfs
        elif type yum &>/dev/null; then
            echo "安装 Git LFS..."
            yum install -y git-lfs
        else
            echo "未知的系统，请手动安装 Git LFS。"
            exit 1
        fi
    fi
    while true; do
        read -p "请输入GitHub绑定的邮箱: " new_email
        new_email=${new_email//[[:space:]]/}
        if [[ -n $new_email ]]; then
            sed -i "s/?email?/$new_email/g" "$(realpath "$0")"
            email="$new_email"
            break # 保存变量并跳出循环
        fi
    done
    while true; do
        read -p "请输入GitHub用户名(Name): " new_username
        new_email=${new_username//[[:space:]]/}
        if [[ -n $new_username ]]; then
            sed -i "s/?username?/$new_username/g" "$(realpath "$0")"
            username=$new_username
            break
        fi
    done
    while true; do
        read -p "请输入GitHub仓库名称(请确保为私有类型): " new_Repositories
        new_Repositories=${new_Repositories//[[:space:]]/}
        if [[ -n $new_Repositories ]]; then
            sed -i "s/?Repositories?/$new_Repositories/g" "$(realpath "$0")"
            Repositories=$new_Repositories
            break
        fi
    done
    while true; do
        read -p "请输入需要备份的文件路径(不能包含空格,首次运行!必须!是空目录): " new_filepath
        new_filepath=${new_filepath//[[:space:]]/}
        if [[ -n $new_filepath ]]; then
            if [[ ! -d $new_filepath ]]; then
                echo "目录不存在，请输入一个有效的文件路径。"
                continue
            fi
            if find "$new_filepath" -mindepth 1 -print -quit | grep -q .; then
                echo "指定的目录不是空的，请输入一个空目录。"
            else
                sed -i "s|?filepath?|$new_filepath|g" "$(realpath "$0")"
                filepath=$new_filepath
                break
            fi
        else
            echo "请输入一个有效的文件路径。"
        fi
    done
    while true; do
        read -p "请输入GitHub仓库保留备份的天数(不建议超过7天/0为永久保留): " new_day
        new_day=${new_day//[[:space:]]/}
        if [[ $new_day =~ ^[0-9]+$ ]]; then
            sed -i "s/?day?/$new_day/g" "$(realpath "$0")"
            day=$new_day
            break
        else
            echo "输入无效，请输入一个数字。"
        fi
    done
    read -p "是否需要运行GitHub SSH密钥生成绑定向导[Y/N]:" input
    if [[ $input = "Y" || $input = "y" ]]; then
        echo 'SSH密钥生成中...';
        sleep 1 #延时1秒
        ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -q -N ""
        clear;
        echo '请打开GitHub绑定下面的SSH密钥 (填写至Key内 Title随便)';
        echo 'https://github.com/settings/ssh/new';
        echo '--------------------------------------------------------------------';
        cat ~/.ssh/id_rsa.pub
        echo '--------------------------------------------------------------------';
        echo '注意:不要复制--------';
        read -n 1 -s -r -p "绑定完成后按任意键继续..."
        sleep 1
    fi
    rm -rf "$filepath/.git"
    chown -R $(whoami) "$filepath"
    echo '开始拉取仓库...';
    git clone git@github.com:${username}/${Repositories}.git "$filepath" 2>error_yglog.txt || {
        echo "拉取仓库失败!错误日志已保存到error_yglog.txt|查看使用cat error_yglog.txt"
        exit 1
    }
    sed -i "s/????/ok/g" "$(realpath "$0")" #配置完成锁定
    cd "$filepath"
    git config user.name "$username" &>/dev/null;
    git config user.email "$email" &>/dev/null;
    #为新建的库创建一个分支
    if [ -z "$(git branch)" ] && [ "$day" -ne 0 ]; then
        export LANG=C.UTF-8
        git checkout --orphan "default"
        #echo -e "说明\n请点击左上角(Branch)旁边查看最新分支" >> help.txt
        git commit --allow-empty -m "请点击左上角(Branch)旁边查看最新分支"
        git push -u origin "default"
	#rm help.txt
        cd ~
    fi
    echo '--------------------------------------------------------------------'
    printf "警告:请确保您绑定的 $Repositories 为\033[31m私有\033[0m状态 否则您的\033[31m数据将被公开\033[0m\n"
    echo "配置完毕!下次执行时就会开始备份"
    echo "现在可以往$filepath中添加需要备份的内容了"
    echo "请在cron 中配置计划任务 (crontab -e)"
    echo "例如每天两点备份0 0 2 * * bash $(realpath "$0") 2>&1 | tee /home/Gitbackup.log"
    echo '--------------------------------------------------------------------'
}

Bak() { #备份
    echo "启动备份任务 $(date "+%Y/%m/%d|%H:%M")"
    echo "脚本路径: $(realpath "$0")"
    echo "备份文件夹: $filepath"
    echo '--------------------------------------------------------------------';
    cd "$filepath"
    git lfs install &>/dev/null;
    git config push.default matching &>/dev/null;
    git config user.name "$username" &>/dev/null;
    git config user.email "$email" &>/dev/null;
    if [ "$day" = "0" ]; then # eien=永恒=eternal
        if ! git rev-parse --verify --quiet eien; then
            echo "创建分支..."
            git checkout --orphan eien
            git commit --allow-empty -m "$(hostname)•建立持久分支$(date "+%Y/%m/%d|%H:%M")"
            git push -u origin eien
        else
            echo "切换到该分支..."
            git checkout eien
        fi
        git push -u origin eien #设置分支
        find . -size +100M | while read file; do
            git lfs track "$file"
        done
        git add .gitattributes
        git add -A #推送所有文件~删除新建修改~
        git commit -m "$(hostname)•Backups-$(date "+%Y/%m/%d|%H:%M")"
        git push
        git lfs prune
        git gc --prune=now
    else
        new_date="$(date +%Y-%m-%d)" #当前日期分支
        old_date="$(date --date="$day days ago" +%Y-%m-%d)" #需要删除的分支
        if ! git rev-parse --verify --quiet $new_date; then
            echo "创建当前日期分支..."
            git checkout --orphan $new_date
            git commit --allow-empty -m "$(hostname)•建立新分支:$(date "+%Y/%m/%d|%H:%M")"
            git push -u origin $new_date
        else
            echo "分支已存在,切换到该分支..."
            git checkout $new_date
        fi
        git push -u origin $new_date 
        find . -size +100M | while read file; do
            git lfs track "$file"
        done
        git add .gitattributes
        git add -A #推送所有文件~删除新建修改~
        git commit -m "$(hostname)•Backups-$(date "+%Y/%m/%d|%H:%M")"
        git push
        #删除旧分支
        if git rev-parse --verify --quiet $old_date; then
            git branch -D $old_date &>/dev/null;
            git push origin --delete $old_date &>/dev/null;
        fi
        git lfs prune
        git gc --prune=now
    fi
    echo '--------------------------------------------------------------------';
}

[ "$IFInstall" = "ok" ] && Bak #开始备份
[ "$IFInstall" != "ok" ] && Install #第一次运行
