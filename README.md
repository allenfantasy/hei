# Cordova Browserify Bootstrap

Cordova启动项目，整合 [Grunt](http://gruntjs.com), [Browserify](http://browserify.org), [Coffeescript](http://coffeescript.org), [Less](http::/lesscss.org)

## 开发环境搭建

以下假设用户使用 Mac OS 进行开发，之后如果有时间，会补上在 linux 下开发环境的搭建。

### 安装 Android 开发环境和 Java Ant 编译工具

1. 安装 Java 环境：http://www.oracle.com/technetwork/java/javase/downloads/index.html
2. 下载并安装 Eclipse：https://www.eclipse.org/downloads/
3. 配置 Eclipse：http://www.cs.dartmouth.edu/~cs5/install/eclipse-osx
4. [在 Eclipse 中安装 ADT(Android Development Tools) 插件](http://developer.android.com/sdk/installing/installing-adt.html)，安装时指定 sdk 目录为`~/android-sdks`
5. 在`.bashrc`或`.zshrc`中加入：
    ```
    export ANDROID_HOME=~/android-sdks
    export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/build-tools:$PATH"
    ```
6. 在命令行中：
    ```
    . .bashrc # 或者 . .zshrc
    ```
7. 这时候在终端执行：`android` 可以打开 Android SDK Manager；在 Android SDK Manager 中安装 Android 4.4.2(API 19)，同时安装 Android SDK Build-tools
8. `brew install ant` 安装ant编译工具
9. 安装`Intel x86 Emulator Accelerator(HAXM installer)`：
  ```
  cd ANDROID_HOME/extras/intel/Hardware_Accelerated_Execution_Manager
  open .
  ```
  然后根据 Mac OS 的不同版本，双击安装 mpkg 文件

### 得到代码副本，进行初始化

```
$ git clone https://github.com/allenfantasy/cordova-browserify-famous-bootstrap.git hello-cordova
$ cd hello-cordova
$ make init # 初始化，安装需要的npm包，同时添加ios, android两个平台
$ npm install -g grunt-cli # 安装grunt
```

## 项目代码组织

package.json
  - 规定依赖的 npm 包和开发工具

Makefile
  - 使用 `make init` 初始化
  - 提供开发和发布用的指令

/src
  - 开发代码，包括 `coffee/`，`less/`
  - `coffee/`: Coffeescript 文件/模块，使用 Broswerify 和 Coffeeify 编译到最终的 js 文件
  - `less/`: Less 文件，使用 less 编译

/www
  - 对于 cordova webview 可见的（编译过的）静态文件
  - 不要将 *active* 的资源（js, css等）放在这个文件夹，可以将 *static* 的资源放在这里（如字体，图片等）

/tools
  - 帮助在 testflight 和 appstore 发布应用的脚本

## 开发流程

对于在开发过程中在本地浏览器进行快速测试，使用以下步骤，来完成编译资源和测试的流水线工作：

### 不涉及 Cordova 的 Native API 的情况下

在命令行中：

  ```shell
  $ grunt serve # 启动 web 服务并实时更新开发代码，在 `http://localhost:1337` 中查看
  ```

### 涉及 Cordova 的 Native API 的情况

TODO

### 技巧

* 典型的开发流程是在本地利用 ripple 进行开发，使用模拟器进行测试，最后在真机上测试。*必须* 要在发布应用前在真机上进行测试。

#### 使用Genymotion运行Cordova应用

1. 在 Genymotion 上安装 Android 虚拟机（注意版本要是4.4.2的）
2. 设置 Genymotion 的 ADB 为刚才安装Android SDK的路径
3. `adb devices`，正确的话应该是这样【TODO：来个图呗】
4. 打开刚才安装好的虚拟机
5. `cordova run android`，看到 LAUNCH SUCCESS 就对了

#### Android设备真机运行

1. 下载 [android file transfer package](https://www.android.com/filetransfer/) 并安装
2. 手机开启开发者模式，允许 USB 调试
3. 将手机通过 USB 接入，在手机弹出提示是否允许 USB 调试时（会有 RSA 密钥指纹），点击“确定”
4. 在命令行中执行 `adb devices`，应该能看到（以下的设备号在实际操作时会不同，但长度应该一致）：
```
List of devices attached
Y5AES89TCyL7RSLB       device
```
5. 然后在命令行执行 `cordova run android --device`，将生成好的 apk 安装到手机上运行
6. 如果一直出现`INSTALL_CANCELLED_BY_USER`的错误，那一定是……手机锁屏的缘故……

#### cordova emulate ios 黑屏

[TODO]

1. open Xcode
2. launch the simulator from Xcode
3. `cordova emulate ios` in terminal

### gotchas

* 不要在 `src`，`href` 属性或 CSS 的 `urls` 中使用绝对路径。在部署到设备或模拟器时使用绝对路径的内容将不会被加载。

## 发布流程

**推荐** 使用该 repo 的一个干净的副本（清除掉 git 的痕迹）

`/tools` 文件夹中的 `release` 脚本可以通过命令行新建一个发布版本。

### gotcha

These are items which cordova doesn't do by default (yet) when making a release build. Some of them have a work around in the release script.

`debuggable=false` should be set in AndroidManifest.xml (done in release script)

`TARGET_DEVICE_FAMILY = 1` for ios builds only for iphone (in build.xconfig ios platform dir, but not done automatically yet)
