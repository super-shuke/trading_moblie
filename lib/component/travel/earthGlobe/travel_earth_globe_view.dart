import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/misc.dart';
import 'package:flutter_earth_globe/point.dart' as earth;
import 'package:flutter_earth_globe/sphere_style.dart';
import 'package:traveling_app/service/travel_data.dart';
import 'package:traveling_app/styles/theme/app_common.dart';

/// 基于 [flutter_earth_globe] 封装的旅行地球组件。
///
/// **控制地球大小的几个维度**（按生效顺序）：
///   1. [size] / [width] / [height]
///      → 组件外层 SizedBox 的尺寸，决定地球能活动的总空间
///   2. [_globeRadius]（内部计算）
///      → 地球本体的物理半径，默认 = 宽高较小值 / 2（球填满容器较小边）
///   3. [FlutterEarthGlobe.alignment]
///      → 地球在容器内的位置，当前固定 (0, -0.6) 偏上方
///   4. [backgroundSize] + [globeAlignment]
///      → 给地球一个比自身大的舞台，控制球在舞台里的位置
///   5. [zoom]
///      → 相机缩放（视觉远近），不改变物理半径
///
/// **典型用法**：
///   - 登录页装饰球：`TravelEarthGlobeView(size: 340)`
///   - 满屏探索：`TravelEarthGlobeView(size: MediaQuery.of(context).size.width)`
///   - 列表预览：`TravelEarthGlobeView(size: 80, showBackground: false)`
class TravelEarthGlobeView extends StatefulWidget {
  // ─── 尺寸控制 ────────────────────────────────────────

  /// 组件正方形边长（默认形态）。当 [width]/[height] 都没设时使用这个值。
  ///
  /// 决定 SizedBox 的宽高，**也间接决定球的大小**——因为球半径取自宽高较小值的一半。
  final double? size;

  /// 自定义组件宽度（覆盖 [size]）。设置后变长方形。
  final double? width;

  /// 自定义组件高度（覆盖 [size]）。设置后变长方形。
  final double? height;

  /// 背景画布尺寸（可选）。
  ///
  /// 设了这个之后，**组件外层会展开成 [backgroundSize] 大小的舞台**，
  /// 地球缩在自己的 width/height 区域里，用 [globeAlignment] 决定球在舞台里的位置。
  ///
  /// 适合场景：地球只占屏幕一部分，但需要在更大的区域内对齐。
  /// 例如：让球居中并偏上，下方留出空间给标题文字。
  final Size? backgroundSize;

  // ─── 数据 ───────────────────────────────────────────

  /// 城市数据，每个城市会作为一个 marker 显示在地球上。
  final List<City> cities;

  /// 用户当前位置（特殊样式：金色，更大）。
  final UserLocation userLocation;

  /// 城市 marker 点击回调。当为 null 时禁用 marker 点击 + 禁用缩放。
  final void Function(City city)? onCityTap;

  // ─── 行为 ───────────────────────────────────────────

  /// 是否自动旋转。
  final bool autoRotate;

  /// 旋转速度（包内单位）。默认 0.08 比较温和。
  final double rotationSpeed;

  /// 最多显示多少个城市 marker（性能保护，避免上百个点拖慢渲染）。
  final int maxMarkers;

  /// 是否显示 marker 旁的城市名字标签。
  final bool showLabels;

  /// 相机初始缩放（**不是地球物理大小**）。
  ///
  /// 范围由 [minZoom](-0.6) / [maxZoom](1.4) 限制：
  ///   - 负值 → 视觉上球更小（相机拉远）
  ///   - 正值 → 视觉上球更大（相机推近）
  ///   - 0 → 默认
  final double zoom;

  /// 地球在 [backgroundSize] 舞台里的对齐方式。
  ///
  /// 只在设置了 [backgroundSize] 时生效。常用值：
  ///   - `Alignment.center` 居中
  ///   - `Alignment.topCenter` 置顶
  ///   - `Alignment(0, -0.5)` 偏上一半
  final Alignment globeAlignment;

  /// 是否显示星空背景图。关闭后底色是透明的（适合放在已有背景上）。
  final bool showBackground;

  const TravelEarthGlobeView({
    super.key,
    this.width,
    this.height,
    this.size = 400,
    this.backgroundSize,
    required this.cities,
    required this.userLocation,
    this.onCityTap,
    this.autoRotate = true,
    this.rotationSpeed = 0.08,
    this.maxMarkers = 18,
    this.showLabels = false,
    this.zoom = 0,
    this.globeAlignment = Alignment.center,
    this.showBackground = true,
  });

  @override
  State<TravelEarthGlobeView> createState() => _TravelEarthGlobeViewState();
}

class _TravelEarthGlobeViewState extends State<TravelEarthGlobeView> {
  /// 地球控制器：管理旋转、缩放、点位、视觉效果等。
  late final FlutterEarthGlobeController _controller;

  /// 标记是否已经把 cities/userLocation 同步到控制器了。
  /// 防止 didChangeDependencies 在初次渲染时被多次调用导致重复添加。
  bool _didSyncPoints = false;

  @override
  void initState() {
    super.initState();
    _controller = FlutterEarthGlobeController(
      // ─── 贴图 ────────────────────────────────────────
      surface: Image.asset('assets/earth_globe/2k_earth-day.jpg').image,
      nightSurface: Image.asset('assets/earth_globe/2k_earth-night.jpg').image,
      background: widget.showBackground
          ? Image.asset('assets/earth_globe/2k_stars.jpg').image
          : null,

      // ─── 旋转 ────────────────────────────────────────
      isRotating: widget.autoRotate,
      rotationSpeed: widget.rotationSpeed,

      // ─── 缩放（相机距离，不是球大小）────────────────────
      zoom: widget.zoom,
      minZoom: -0.6, // 最小缩放（最远）
      maxZoom: 1.4, // 最大缩放（最近）
      isZoomEnabled: widget.onCityTap != null, // 只有可点击时才允许缩放
      panSensitivity: 0.75, // 拖拽灵敏度
      zoomSensitivity: 0.55, // 缩放灵敏度
      // ─── 大气层 ───────────────────────────────────────
      showAtmosphere: true,
      atmosphereOpacity: 0.28, // 透明度（0 全透 ~ 1 不透）
      atmosphereThickness: 0.04, // 大气厚度
      atmosphereBlur: 30, // 模糊度（越大越柔和）
      // ─── 光照 ─────────────────────────────────────────
      surfaceLightingEnabled: true,
      lightAngle: -35, // 光源角度（度数）
      lightIntensity: 0.72, // 光照强度
      ambientLight: 0.58, // 环境光（决定阴影区有多亮）
      // ─── 昼夜循环 ─────────────────────────────────────
      isDayNightCycleEnabled: true,
      dayNightMode: DayNightMode.simulated, // 模拟的昼夜（不依赖真实时间）
      simulatedNightColor: const Color(0xFF081326),
      simulatedNightIntensity: 0.24, // 夜晚区域有多暗
      // ─── 球体样式（阴影 + 渐变叠加） ────────────────────
      sphereStyle: const SphereStyle(
        shadowColor: Color(0x663AA8FF), // 球体外发光颜色（蓝色）
        shadowBlurSigma: 22, // 发光模糊度
        showGradientOverlay: true, // 是否叠加渐变滤镜
        gradientOverlay: RadialGradient(
          center: Alignment(-0.32, -0.36), // 高光中心位置（左上）
          colors: [
            Colors.transparent,
            Color(0x08000000),
            Color(0x52000000), // 边缘变暗的程度
          ],
          stops: [0.08, 0.62, 1.0],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 首次构建时同步 marker 点。
    // 用 _didSyncPoints flag 防止重复，因为 didChangeDependencies 可能被多次调用。
    if (!_didSyncPoints) {
      _didSyncPoints = true;
      _syncPoints();
    }
  }

  @override
  void didUpdateWidget(TravelEarthGlobeView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当 cities / userLocation / showLabels / maxMarkers 变化时，重建 marker 点。
    if (oldWidget.cities != widget.cities ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.showLabels != widget.showLabels ||
        oldWidget.maxMarkers != widget.maxMarkers) {
      _syncPoints();
    }

    // 旋转相关属性变化时，重新启动/停止旋转。
    if (oldWidget.autoRotate != widget.autoRotate ||
        oldWidget.rotationSpeed != widget.rotationSpeed) {
      if (widget.autoRotate) {
        _controller.startRotation(rotationSpeed: widget.rotationSpeed);
      } else {
        _controller.stopRotation();
      }
    }
  }

  @override
  void dispose() {
    // ⚠️ 注意：当前没有 _controller.dispose()，
    // 如果 FlutterEarthGlobeController 有 dispose 方法，应该在这里调用以释放资源。
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 模式 A：设了 backgroundSize → 把球放到一个更大的"舞台"里
    //
    // 适合场景：球只想占屏幕一部分，但要在更大区域内做对齐
    // 例如：500x800 的容器里，球只有 340x340，居上 Alignment(0, -0.5)
    if (widget.backgroundSize != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // 计算实际舞台尺寸：如果 backgroundSize 是有限值就用它，否则填满父容器
          final viewport = Size(
            widget.backgroundSize!.width.isFinite
                ? widget.backgroundSize!.width
                : constraints.maxWidth,
            widget.backgroundSize!.height.isFinite
                ? widget.backgroundSize!.height
                : constraints.maxHeight,
          );

          return SizedBox(
            width: viewport.width,
            height: viewport.height,
            child: Align(
              alignment: widget.globeAlignment, // 球在舞台里的位置
              child: _globe(),
            ),
          );
        },
      );
    }

    // 模式 B：默认 → 球占据整个 width × height 区域
    return SizedBox(width: _globeWidth, height: _globeHeight, child: _globe());
  }

  /// 渲染地球本身。
  Widget _globe() {
    return SizedBox(
      width: _globeWidth,
      height: _globeHeight,
      child: FlutterEarthGlobe(
        controller: _controller,
        radius: _globeRadius,
        // 球在自己的 _globeWidth × _globeHeight 容器里的对齐方式。
        //
        // 这是包内部参数（注意区别于上面的 globeAlignment）：
        //   - globeAlignment → 在外层"舞台"里的位置（模式 A 才用）
        //   - 这里的 alignment → 球在自己 SizedBox 里的位置
        alignment: const Alignment(0, -0.55),
      ),
    );
  }

  // ─── 尺寸计算 ────────────────────────────────────────

  /// 组件实际宽度：优先用 [width]，否则用正方形 [size]。
  double get _globeWidth => widget.width ?? widget.size!;

  /// 组件实际高度：优先用 [height]，否则用正方形 [size]。
  double get _globeHeight => widget.height?? widget.size!;

  /// 地球物理半径 = 宽高较小值的一半。
  ///
  /// 这个公式让球**恰好填满**容器的较小边：
  ///   - 正方形 340×340 → 半径 170（球占满）
  ///   - 长方形 400×600 → 半径 200（横向占满，纵向有余量）
  ///
  /// **想让球更小**（容器里留白）：在末尾乘一个 < 1 的系数。
  /// 例如 `* 0.8` 表示球只占容器较小边的 80%。
  double get _globeRadius =>
      (_globeWidth < _globeHeight ? _globeWidth : _globeHeight) / 2 * 0.8;

  // ─── 点位管理 ────────────────────────────────────────

  /// 把 widget.cities 和 widget.userLocation 同步到地球控制器。
  ///
  /// 每次调用会**先清空**所有 marker 再重新添加，避免重复。
  void _syncPoints() {
    _controller.points.clear();
    _controller.addPoint(_userPoint());

    // 限制 marker 数量，超过 maxMarkers 的城市丢弃
    for (final city in widget.cities.take(widget.maxMarkers)) {
      _controller.addPoint(_cityPoint(city));
    }
  }

  /// 用户位置 marker：金色、稍大、高亮。
  earth.Point _userPoint() {
    return earth.Point(
      id: widget.userLocation.id,
      coordinates: GlobeCoordinates(
        widget.userLocation.coordinates.lat,
        widget.userLocation.coordinates.lon,
      ),
      label: widget.userLocation.city,
      isLabelVisible: widget.showLabels,
      style: const earth.PointStyle(
        size: 6, // 点大小（用户位置稍大）
        color: Color(0xFFFFD166), // 金色
        altitude: 0.015, // 凸出球面的高度
        transitionDuration: 350, // 过渡动画
      ),
      labelTextStyle: _labelStyle(const Color(0xFFFFD166)),
    );
  }

  /// 城市 marker：用主题色，较小。
  earth.Point _cityPoint(City city) {
    final markerColor = Theme.of(
      context,
    ).extension<AppCommon>()!.textPrimarySameBtn;

    return earth.Point(
      id: city.id,
      coordinates: GlobeCoordinates(city.location.lat, city.location.lon),
      label: city.name,
      isLabelVisible: widget.showLabels,
      labelOffset: const Offset(8, -8), // 标签相对点的偏移
      style: earth.PointStyle(
        size: 4, // 点大小
        color: markerColor,
        altitude: 0.012,
        transitionDuration: 350,
        merge: true, // 临近的点会合并（性能优化）
      ),
      labelTextStyle: _labelStyle(markerColor),
      onTap: widget.onCityTap == null ? null : () => widget.onCityTap!(city),
    );
  }

  /// 统一的标签字体样式（带阴影提高可读性）。
  TextStyle _labelStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
    );
  }
}
