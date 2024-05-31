# Gitbackup 
使用GitHub来备份服务器的数据  
Use GitHub to back up your data
# 功能说明

- 根据您设置的路径来备份数据到GitHub
- 支持长期备份和期限备份，使用期限备份时每日新建孤儿分支
- 点击分支即可查看每日备份，如果选择长期备份请查看eien分支
- 每日可多次备份，备份的次数与您执行脚本的次数有关
- GitHub的大小限制：单个文件最大2GB，单个储存库最大使用100GB

<a href="https://www.kazami.cn/skill/369.html" target="_blank">带图文的教程</a>
# 安装教程
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Kazuki-yiji/Gitbackup/main/Gitbackup.sh" && chmod +x Gitbackup.sh && bash Gitbackup.sh
```
1. 拥有一个GitHub账号，登录后<a href="https://github.com/new" target="_blank">创建</a>一个干净全新的私有仓库
2. 确保这个新创建的仓库是私有状态的，否则您备份的数据将被公开！
3. 执行脚本后按照步骤即可完成配置！(再次执行上面的命令会清空脚本数据)
4. 配置<a href="https://www.runoob.com/w3cnote/linux-crontab-tasks.html" target="_blank">计划任务</a>(crontab -e)，列如添加一个每天02:00备份:
```
0 2 * * * bash /root/Gitbackup.sh 2>&1 | tee -a /root/Gitbackup.log
```
# 更新脚本
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/Kazuki-yiji/Gitbackup/main/GitbakUpdate.sh" && chmod +x update.sh && bash update.sh
```
# 常见错误
fatal: detected dubious ownership in repository at '/xxx':  
解决方法，在/home新建目录 或者使用以下目录给予目录权限:
```
sudo chown -R $(whoami) /xxx
```
