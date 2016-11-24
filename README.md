## 快速搭建饥荒服务器shell

虽然不太会shell，但沉迷饥荒之下还是把它写出来了

* 在 ubuntu server14.04 和 debian8.2 下测试成功

```shell
wget https://raw.githubusercontent.com/moonprism/installDSTserver.sh/master/install.sh
chmod +x install.sh 
./install
```

---

> 请输入安装模式（ install mode 1 / 2 / 3 ）

如果要将地面与地穴服务器装在一起的话就输入1,如果要安装地面服务器到该服务器就输入2,安装地穴服务器就输入3

> 请输入你的token( Server Token )：

token要登入你steam饥荒上的游戏点击账户信息获取

> 请输入服务器名( Server Name )：
> 请输入服务器描述( Server Description )：
> 请输入服务器密码( Server Password )：

这个填自己的配置就好了

> 安装模式为3 ？ 请输入服务器ip（server ip）

如果单独安装地穴服务器的话

> 请输入需要的 modid（ 各id间使用,分隔 eg. 374550642,378160973,375850593,458587300,375859599 ） :

添加mod,这里很好理解的吧，这五个是我觉得对于饥荒服务器挺必要的mod

---

最后成功安装的话会在当前目录生成执行脚本，根据提示的命令执行就好了 --

[快速搭建指南 - 相关博客](http://www.kicoe.com/article/id/4)
