# Gitbackup 
使用GitHub来备份服务器的数据  
Use GitHub to back up your data
# 功能说明

- 根据您设置的路径来备份数据到GitHub
- 支持长期备份和期限备份，使用期限备份时每日新建孤儿分支
- 每日可多次备份，备份的次数与您执行脚本的次数有关

# 安装教程
```
wget -N --no-check-certificate "https://raw.githubusercontent.com/yijiniang/Gitbackup/main/Gitbackup.sh" && chmod +x Gitbackup.sh && ./Gitbackup.sh
```
1. 拥有一个GitHub账号，登录后<a href="https://github.com/new" target="_blank">创建</a>一个干净全新的私有仓库
2. 确保这个新创建的仓库是私有状态的，否则您备份的数据将被公开！
3. 执行脚本后按照步骤即可完成配置！
4. 配置<a href="https://www.runoob.com/w3cnote/linux-crontab-tasks.html" target="_blank">计划任务</a>，列如添加一个每天02:00备份:
```
0 2 * * * /bin/sh /root/Gitbackup.sh >> /root/Gitbackup.log 2>&1
```
