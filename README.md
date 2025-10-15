# Github Host Update

自动更新github的host的脚本文件

## 使用方法

### windows

将windows文件夹下的所有内容复制到本地的稳定位置$baseDir
使用任务计划程序，创建任务，操作的程序为：

```
wscript.exe
```

参数为：

```
"$baseDir\run_host_silently.vbs"
```
可以在触发器设置执行开始时间和间隔。