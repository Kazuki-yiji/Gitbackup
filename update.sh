#!/bin/bash
curl -Ls https://raw.githubusercontent.com/Kazuki-yiji/Gitbackup/main/Gitbackup.sh | sed -n "/echo 'Please note: GitHub is part of Microsoft';/,/Install #第一次运行/p" > new_data.txt
#使用临时文件中的数据替换原脚本中的内容
sed -i "/echo 'Please note: GitHub is part of Microsoft';/,/Install #第一次运行/{/echo 'Please note: GitHub is part of Microsoft';/b;/Install #第一次运行/!d;};/Install #第一次运行/r new_data.txt" Gitbackup.sh
if [ $? -eq 0 ]; then
    echo "Gitbackup.sh脚本更新成功!"
	# 删除多余的行
	sed -i '1,50{/\[ "\$IFInstall" != "ok" \] && Install #第一次运行/d}' Gitbackup.sh
	sed -i '0,/echo '\''Please note: GitHub is part of Microsoft'\'';/ { //d; }' Gitbackup.sh
else
    echo "更新失败!请检查Gitbackup.sh文件是否存在，如果不存在请手动使用cd /脚本所在的目录"
fi
rm new_data.txt
