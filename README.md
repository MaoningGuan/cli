# 使用skynet框架及lua脚本实现cli命令
## 一、开发简述：
### 1. 往环境中注册ipmcget和ipmcset命令
在系统启动的脚本中，往.bashrc文件末尾写入以下两行内容，其中ipmcget.lua、ipmcset.lua脚本的路径要根据实际路径进行更改：
```
alias ipmcget='lua /root/cli/ipmcget.lua'
alias ipmcset='lua /root/cli/ipmcset.lua'
```
即可注册ipmcget/ipmcset命令。
以上两条命令的作用是当命令行输入ipmcget或者ipmcset命令时，会分别自动执行对应路径下的ipmcget.lua和ipmcset.lua脚本。
### 2. 编写ipmcget.lua脚本把输入的命令发送给cli服务端。
* 当前只支持以下命令：
```
ipmcget -d version
```
### 3. 编写ipmcset.lua脚本把输入的命令发送给cli服务端。
* 暂未开发
### 4. skynet进程开启了一个cli服务，用于监听127.0.0.1:8888地址，并根据接收到的命令执行对应的动作，再把结果返回给客户端ipmcget.lua/ipmcget.lua脚本。

## 二、测试简述：
### 1. 进入cli/skynet目录，运行以下命令，编译skynet进程：
```
root@XTZJ-20220601ZL:~/cli/skynet# make linux
```
### 2. 进入项目根目录cli运行start.sh脚本，开启服务端：
```
root@XTZJ-20220601ZL:~/cli# sh ./start.sh
[:00000002] LAUNCH snlua bootstrap
[:00000003] LAUNCH snlua launcher
[:00000004] LAUNCH snlua cdummy
[:00000005] LAUNCH harbor 0 4
[:00000006] LAUNCH snlua datacenterd
[:00000007] LAUNCH snlua service_mgr
[:00000008] LAUNCH snlua main
[:00000008] -----start cli server------
[:00000009] LAUNCH snlua firmware_mgmt
[:00000009] -----start firmware service------
[:00000008] cli server listen to: 127.0.0.1 8888
[:00000002] KILL self
```
### 3. 客户端安装lua环境
省略...
### 4. 客户端安装luasocket：
安装教程：https://blog.csdn.net/songyulong8888/article/details/80363444
### 5. 客户端运行cli命令获取版本信息：
```
root@XTZJ-20220601ZL:~# ipmcget -d version
Version: 5.0.0.1
BuildNum: 005
ReleaseDate: 23:08:30 Oct 13 2022
```
## 三、其他说明：
* ipmcget.lua和ipmcset.lua只是作为客户端的入口脚本，它们可以引用其他lua脚本来实现更丰富的功能。
* 当前客户端和服务端使用字符串来传输消息，后续可以使用Protobuf协议传输信息来进行优化，这也是skynet比较推荐方式。
参考：
1. https://github.com/utmhikari/create-skynet
2. https://github.com/donnki/ddz_skynet
* 当前客户端使用非阻塞的方式来接收服务端的消息，后续可以根据业务来决定采用非阻塞还是阻塞的方式。