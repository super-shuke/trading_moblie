# Route Animations

这份文档只记录当前项目里的页面路由动画配置。

## 动画入口

- 动画实现文件: [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
- 路由定义文件: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:14)

## 当前支持的转场类型

- `fade`
- `slideLeft`
- `slideRight`

定义位置：
[lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:15)

## 动画实现位置

- `fade` 实现:
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
- `slide` 实现:
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:28)
- 统一封装入口:
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:58)

## 全局默认规则

- Tab 路由统一使用 `fade`
  设置位置：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:112)

- Secondary 路由默认使用 `slideRight`
  设置位置：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:141)

- Secondary 路由允许通过 `state.extra` 覆盖默认动画
  判断位置：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:135)

## 页面动画对照表

### Tab 路由

- `/explore`
  页面: `Home`
  动画: `fade`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:17)

- `/itinerary`
  页面: `ItineraryView`
  动画: `fade`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:24)

- `/profile`
  页面: `ProfileView`
  动画: `fade`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:31)

### Secondary 路由

- `/login`
  页面: `LoginScreen`
  默认动画: `slideRight`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:40)

- `/explore/city/:cityId`
  页面: `CityDetails`
  默认动画: `slideRight`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:48)

- `/explore/city/:cityId/poi/:poiId`
  页面: `PoiDetails`
  默认动画: `slideRight`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:57)

- `/explore/city/:cityId/poi/:poiId/tips`
  页面: `TipsView`
  默认动画: `slideRight`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:67)

- `/navigate/:poiId`
  页面: `NavigationView`
  默认动画: `slideRight`
  路由定义: [lib/route/routers.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/routers.dart:76)

## 如果你要改动画

### 改所有页面的默认动画

- 改 Tab 默认动画：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:112)
- 改 Secondary 默认动画：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:141)

### 改动画效果本身

- 改 `fade` 效果：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:9)
- 改 `slide` 效果：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:28)
- 改统一时长：
  [lib/route/index.dart](/Users/shuke/Desktop/develop/flutter_basic/lib/route/index.dart:66)

### 改某个页面的单独动画

- Secondary 路由可以在跳转时通过 `state.extra` 传 `PageTransition`
- 也就是说，如果你想让某个页面不是默认 `slideRight`，可以在跳转那一侧单独覆盖

## 当前结论

- Tab 页面现在全部是淡入淡出
- 二级详情页现在全部是右侧滑入
- 动画逻辑集中，入口比较统一，后面改起来成本不高

## go / push / pop 使用约定

这部分不是动画实现本身，但和“为什么某些页面 back 没反应”直接相关。

### 什么时候用 `go`

- 用于切换主页面、主 tab、固定目标页
- 特点:
  更像“直接切到某个位置”
  不适合深层详情页层层返回

当前项目里更适合用 `go` 的场景：
- `/explore`
- `/itinerary`
- `/profile`
- 登录完成后进入首页

### 什么时候用 `push`

- 用于从一个页面钻取到更深层页面
- 特点:
  会形成稳定的返回栈
  适合详情页、子详情页、导航页这种层级前进

当前项目里适合用 `push` 的场景：
- `Home -> CityDetails`
- `CityDetails -> PoiDetails`
- `PoiDetails -> TipsView`
- `PoiDetails -> NavigationView`

### 什么时候用 `pop`

- 用于从当前深层页面返回上一层
- 特点:
  依赖前面是通过 `push` 进入

当前项目里深层页面返回建议：
- `CityDetails` 优先 `pop`，兜底回 `/explore`
- `PoiDetails` 优先 `pop`，兜底回对应 `CityDetails`
- `NavigationView` 优先 `pop`，兜底回 `/explore`

## 当前已修正的深层返回链

- `Home -> CityDetails`
  现在使用 `push`
- `CityDetails -> PoiDetails`
  现在使用 `push`
- `PoiDetails -> TipsView`
  现在使用 `push`
- `PoiDetails -> NavigationView`
  现在使用 `push`

## 为什么以前会出现 back 没反应

- 因为前进时使用了 `go`
- `go` 更偏向位置切换，不是标准详情压栈
- 后面页面再调用 `pop()` 时，返回栈可能并没有你预期的上一层

## 现在这套路由导航语义

- 切主页面:
  `go`
- 进深层详情:
  `push`
- 从深层详情返回:
  `pop`
