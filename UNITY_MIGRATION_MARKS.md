# Unity Migration Marks

这份清单用于标记当前项目里“未来应该交给 Unity / 原生 3D 容器处理”的位置。

目标：
- 先明确哪些必须先改，才能让 Unity 真正接入。
- 再区分哪些可以后改，避免一开始改动面过大。
- 最后标出哪些现在只是占位，未来可以直接删掉或收缩。

## 必须先改

### 1. 地球组件统一入口

- 文件: [lib/component/travel/earth_globe.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/earth_globe.dart:1)
- 当前状态:
  `TravelEarthGlobe` 是业务页面唯一依赖的地球入口。
- 为什么必须先改:
  这是 Flutter 页面和 Unity 运行时之间最核心的边界。
- 后续要做:
  保留这个入口，不让页面直接依赖 Unity SDK 或 `PlatformView`。
  所有 Unity 地球参数都从这里统一下发。

### 2. Unity 容器层

- 文件: [lib/component/travel/globe/unity_globe_container.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/globe/unity_globe_container.dart:1)
- 当前状态:
  这里只是 Flutter 壳层，不是真实 Unity 容器。
- 为什么必须先改:
  这是后面承载地球、城市、导航场景的真实宿主。
- 后续要做:
  用真正的 Unity 容器替换当前 `Container` 占位结构。
  这里以后应该承接：
  `size`
  `cities`
  `userLocation`
  `userLabel`
  `onCityTap`

### 3. 首页主地球区

- 文件: [lib/views/Home.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Home.dart:45)
- 当前状态:
  首页主舞台已经通过 `TravelEarthGlobe` 接入。
- 为什么必须先改:
  这是 Unity 地球最直接的主使用场景。
- 后续要做:
  先让这里跑通真实 Unity 地球。
  然后把城市点击、镜头聚焦、当前位置反馈接回来。

### 4. 登录页顶部地球区

- 文件: [lib/views/Login/login_screen.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Login/login_screen.dart:128)
- 当前状态:
  `_LoginGlobeStage` 已经接入 `TravelEarthGlobe`。
- 为什么必须先改:
  登录页是第二个直接依赖地球组件的主界面。
- 后续要做:
  为地球组件增加展示模式。
  这里通常不需要完整交互，应该偏展示型，例如自动旋转或限制点击。

### 5. 导航页背景场景

- 文件: [lib/views/secondDetails/Navigation.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/Navigation.dart:27)
- 当前状态:
  背景仍然是 `TravelPlaceholderImage(seed: 'map-$poiId')`。
- 为什么必须先改:
  如果你未来要做 3D 城市、导航路径、镜头跟随，这一页是最应该交给 Unity 的页面之一。
- 后续要做:
  保留当前页面的 `Stack` 和底部说明卡结构。
  只把背景层替换成真实 Unity 场景。

## 可后改

### 6. 个人页地球区

- 文件: [lib/views/Profile.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Profile.dart:52)
- 当前状态:
  这里用的是较小尺寸地球。
- 为什么可以后改:
  它不是核心交互入口，更偏展示。
- 后续要做:
  可以继续用 Unity 低交互模式。
  也可以最终换成 Unity 截图、短动画或预渲染缩略图。

### 7. 首页城市卡片缩略图

- 文件: [lib/views/Home.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Home.dart:165)
- 当前状态:
  城市卡片左侧仍然是 `TravelPlaceholderImage`。
- 为什么可以后改:
  不影响 Unity 地球接入本身。
- 后续要做:
  改成真实城市封面图，或 Unity 输出的城市缩略图。

### 8. 登录页背景图

- 文件: [lib/views/Login/login_screen.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Login/login_screen.dart:79)
- 当前状态:
  整页背景仍是 `TravelPlaceholderImage(seed: 'login-hero')`。
- 为什么可以后改:
  不影响 Unity 容器层打通。
- 后续要做:
  可替换为品牌静态图、Unity 静态帧，或全屏 hero 场景。

### 9. 城市详情页头图和 POI 缩略图

- 文件: [lib/views/secondDetails/CityDetails.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/CityDetails.dart:46)
- 文件: [lib/views/secondDetails/CityDetails.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/CityDetails.dart:137)
- 当前状态:
  城市头图和 POI 卡片图都还是占位图。
- 为什么可以后改:
  这部分更偏内容资产升级，而不是 Unity 接入阻塞点。
- 后续要做:
  城市页头图可改成 Unity 城市场景空镜。
  POI 卡片图可改成 Unity 渲染缩略图或真实素材。

### 10. POI 详情页头图

- 文件: [lib/views/secondDetails/PoiDetails.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/PoiDetails.dart:53)
- 当前状态:
  `FlexibleSpaceBar` 背景还是占位图。
- 为什么可以后改:
  它不阻塞 Unity 地球或 Unity 导航先落地。
- 后续要做:
  改成真实 POI 图片或 Unity 渲染视图。

## 可以直接删除或收缩

### 11. 占位图组件本体

- 文件: [lib/component/travel/kit.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/kit.dart:95)
- 当前状态:
  `TravelPlaceholderImage` 用 seed 算渐变色，属于明显占位实现。
- 为什么可以删或收缩:
  当城市图、POI 图、地图背景、登录主视觉逐步被真实素材或 Unity 替换后，这个组件会迅速失去主要用途。
- 建议:
  后续可以：
  1. 直接删除
  2. 或保留成纯开发占位组件，仅在调试环境使用

### 12. Unity 容器里的 Flutter 装饰壳

- 文件: [lib/component/travel/globe/unity_globe_container.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/globe/unity_globe_container.dart:22)
- 当前状态:
  现在的 `RadialGradient`、图标、`TravelPill`、中间文字卡片都只是接入前的视觉占位。
- 为什么可以删或收缩:
  一旦真实 Unity view 进来，这些视觉壳大概率不应该继续存在。
- 建议:
  接入真实 Unity 容器后，把这部分装饰缩到最少，只保留必要 loading / fallback UI。

## 不建议因为 Unity 而现在删除

### 13. 页面转场动画

- 文件: [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
- 当前状态:
  路由切换用了 `FadeTransition` 和 `SlideTransition`。
- 说明:
  这是普通 Flutter UI 动画，不属于伪 3D 渲染，不需要因为 Unity 接入而删。

### 13.1 路由动画设置入口

- 动画实现文件: [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
- 路由定义文件: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:14)
- 当前结构:
  `PageTransition` 枚举定义在 `lib/route/routers.dart`
  可选值有：
  `fade`
  `slideLeft`
  `slideRight`
- 当前动画实现:
  `_buildFadeTransition()` 在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
  `_buildSlideTransition()` 在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:28)
  统一封装入口 `buildPageWithAnimation()` 在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:58)
- 当前默认规则:
  Tab 路由统一走 `fade`，设置位置在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:112)
  次级路由默认走 `slideRight`，设置位置在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:141)
- 当前覆盖方式:
  次级路由可以通过 `state.extra` 传入 `PageTransition` 覆盖默认动画，判断位置在 [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:135)
- 如果你后面要改全局路由动画:
  优先改 `buildPageWithAnimation()`
- 如果你后面要改单个页面动画:
  优先改路由跳转时传入的 `state.extra`

### 14. 弹窗动画

- 文件: [lib/component/common/dialog/custom_dialog.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/common/dialog/custom_dialog.dart:66)
- 当前状态:
  弹窗用了 `AnimationController`、缩放和位移动画。
- 说明:
  这也是普通 UI 动画，不需要因为 Unity 接入而删。

### 15. 评分条组件

- 文件: [lib/component/travel/kit.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/kit.dart:142)
- 当前状态:
  `TravelRatingBars` 是普通 2D 评分 UI。
- 说明:
  这不属于 Unity 替换范围，除非你以后明确要把评分呈现也做成 3D 信息层。

## 推荐实施顺序

1. 先改 [lib/component/travel/globe/unity_globe_container.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/globe/unity_globe_container.dart:1)，完成真实 Unity 容器接入。
2. 再打通 [lib/views/Home.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Home.dart:45) 和 [lib/views/Login/login_screen.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Login/login_screen.dart:128) 的地球展示。
3. 接着替换 [lib/views/secondDetails/Navigation.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/Navigation.dart:27) 的背景层，做 Unity 导航场景。
4. 最后逐步清理 [lib/component/travel/kit.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/kit.dart:95) 的占位图用途，并替换城市 / POI 封面。

## 最终目标

- Flutter 负责:
  页面结构、表单、登录、底部卡片、常规 UI 动画、导航壳层
- Unity 负责:
  地球仪、3D 城市、导航场景、镜头控制、贴图、空间动画、场景交互

## Unity 接入任务拆分

### Flutter 侧

#### A. 组件边界

- 保留 [lib/component/travel/earth_globe.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/earth_globe.dart:1) 作为统一入口。
- 不让业务页面直接依赖 Unity SDK、原生 view 或 channel 细节。
- 让页面继续只关心：
  `size`
  `cities`
  `userLocation`
  `userLabel`
  `onCityTap`

#### B. 容器组件

- 把 [lib/component/travel/globe/unity_globe_container.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/globe/unity_globe_container.dart:1) 从占位壳替换成真实容器组件。
- 给容器补充必要状态：
  `loading`
  `ready`
  `error`
- 约定 fallback UI：
  Unity 未就绪时显示简单 loading，不再显示现在的假球体外观。

#### C. 页面接入

- 首页: [lib/views/Home.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Home.dart:45)
  先打通真实地球点击城市跳转。
- 登录页: [lib/views/Login/login_screen.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Login/login_screen.dart:128)
  增加展示模式，只做 hero 展示，不一定需要完整交互。
- 个人页: [lib/views/Profile.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Profile.dart:52)
  先保留，后续决定是否降级成截图或轻量展示。
- 导航页: [lib/views/secondDetails/Navigation.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/secondDetails/Navigation.dart:27)
  把背景层改成 Unity 场景容器。

#### D. Flutter 和 Unity 的消息模型

- 建议至少定义这些事件：
  `onGlobeReady`
  `onCitySelected`
  `onPoiSelected`
  `onCameraChanged`
  `onRouteFinished`
- 建议至少定义这些 Flutter -> Unity 指令：
  `setMode`
  `setCities`
  `focusCity`
  `focusPoi`
  `setUserLocation`
  `startNavigation`

### iOS / Android 原生容器层

#### A. 平台容器

- Android:
  实现 Unity view 宿主，供 Flutter `PlatformView` 挂载。
- iOS:
  实现 Unity view 宿主，供 Flutter 原生视图嵌入。

#### B. 生命周期

- 处理 Unity 引擎初始化时机。
- 明确页面切换时 Unity view 是：
  1. 常驻单例引擎
  2. 每页创建销毁
- 一般更建议：
  Unity 引擎常驻，页面只切换宿主 view。

#### C. 消息桥

- Flutter -> 原生 -> Unity
- Unity -> 原生 -> Flutter
- 不要让 Flutter 直接感知平台差异。
- 原生层负责把消息格式统一后转发。

#### D. 风险点

- iOS 前后台切换恢复
- Android 页面返回栈与 Unity view 恢复
- 输入事件冲突
- 内存占用和首帧加载耗时

### Unity 侧

#### A. 地球场景

- 提供真实地球仪场景
- 支持贴图、光照、旋转、缩放、相机控制
- 支持不同模式：
  `hero`
  `interactive`
  `profile`

#### B. 城市与 POI 数据接收

- 接收 Flutter 传入的城市列表
- 接收用户定位
- 接收聚焦目标：
  `cityId`
  `poiId`
- 接收到指令后更新 marker、镜头和场景状态

#### C. 导航场景

- 提供 3D 导航背景
- 支持路线高亮
- 支持目标点高亮
- 支持相机跟随或固定演示模式

#### D. 回传事件

- 城市点击回传 `cityId`
- POI 点击回传 `poiId`
- 场景 ready 回传初始化完成状态
- 可选回传：
  当前镜头状态、当前聚焦对象、导航完成状态

## 建议先做的最小闭环

1. Flutter 保留 [lib/component/travel/earth_globe.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/earth_globe.dart:1) 入口不动。
2. 把 [lib/component/travel/globe/unity_globe_container.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/component/travel/globe/unity_globe_container.dart:1) 接成真实 Unity 容器。
3. 先只在 [lib/views/Home.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/views/Home.dart:45) 跑通地球展示。
4. 实现一个最小事件：
  Unity 点击城市 -> Flutter 收到 `cityId` -> 跳转城市详情。
5. 然后再扩展到登录页 hero 展示和导航页 3D 背景。
