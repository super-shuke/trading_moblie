# Unity Local Globe Context for Codex Desktop

## Project Paths

- Flutter app: `/Users/shuke/Desktop/develop/flutter_basic`
- Unity project: `/Users/shuke/Desktop/develop/first3D`

## Goal

Replace the current Cesium-based Home globe with a local Unity-rendered visual globe:

- No Cesium ion attribution on the Home page.
- No network dependency for the Home globe.
- Fully custom marker rendering and click behavior.
- Keep the existing Flutter -> Unity bridge object names and methods where possible.
- Later, real map/3D data can still be used on detail pages if needed.

## Existing Flutter Bridge Contract

Flutter currently sends messages to these Unity object names:

- `GlobeOverviewCamera`
- `MarkerManager`

Important methods Flutter expects:

- `GlobeOverviewCamera.SetCamera(string json)`
- `GlobeOverviewCamera.SetAutoRotateEnabled(string value)`
- `GlobeOverviewCamera.SetAutoRotateSpeed(string value)`
- `GlobeOverviewCamera.SetGesturesEnabled(string value)`
- `MarkerManager.LoadPlacesFromJson(string json)`

Flutter expects Unity ready messages such as:

```json
{"evt":"ready","data":{"version":"..."}}
```

Flutter marker tap handling accepts messages like:

```json
{"type":"cityTap","id":"tokyo"}
```

## Unity Project Current State

The Unity project currently has Cesium-based scene assets and scripts:

- `Assets/Scenes/SampleScene.unity`
- `Assets/Scripts/OrbitGlobeController.cs`
- `Assets/Scripts/MarkerManager.cs`

Those existing scripts depend on Cesium:

- `CesiumGeoreference`
- `CesiumGlobeAnchor`
- `Cesium World Terrain`
- `CesiumIonRasterOverlay`
- `Cesium3DTileset`

The existing Cesium approach renders but shows Cesium attribution and is not ideal for a lightweight Home globe.

## New Local Globe Files Added

Created under:

```text
/Users/shuke/Desktop/develop/first3D/Assets/Scripts/LocalGlobe/
```

Files:

- `LocalGlobeMath.cs`
- `LocalGlobeController.cs`
- `LocalMarkerManager.cs`
- `LocalEarthBootstrap.cs`
- `Editor/LocalGlobeSceneBuilder.cs`

Also added resources:

```text
Assets/Resources/earth_day.jpg
Assets/Resources/earth_night.jpg
```

These were copied from Flutter:

```text
/Users/shuke/Desktop/develop/flutter_basic/assets/earth_globe/2k_earth-day.jpg
/Users/shuke/Desktop/develop/flutter_basic/assets/earth_globe/2k_earth-night.jpg
```

Modified:

```text
Assets/Mock/PlaceData.cs
```

Added field:

```csharp
public string kind;
```

This lets Unity distinguish Flutter user location marker:

```json
{"kind":"userLocation"}
```

## New Local Globe Architecture

### `LocalGlobeMath.cs`

Utility for:

- Convert longitude/latitude to sphere normal.
- Normalize longitude.
- Clamp values.

### `LocalGlobeController.cs`

Attached to Unity object named:

```text
GlobeOverviewCamera
```

Purpose:

- Move camera around a local sphere.
- Keep the same Flutter-facing API names as `OrbitGlobeController`.
- Send ready message to Flutter.
- Support auto-rotate, camera height, basic gesture controls.

Important fields:

- `globe`
- `targetCamera`
- `longitude`
- `latitude`
- `height`
- `globeRadius`
- `transparentBackground`

Current default intended for Unity Editor preview:

```csharp
transparentBackground = false;
```

### `LocalMarkerManager.cs`

Attached to Unity object named:

```text
MarkerManager
```

Purpose:

- Receive Flutter JSON through `LoadPlacesFromJson`.
- Convert each place longitude/latitude to local globe position.
- Create custom runtime marker objects.
- Add click target that sends:

```json
{"type":"cityTap","id":"..."}
```

Important fields:

- `globe`
- `globeRadius`
- `markerAltitude`
- `markerScale`
- `cityColor`
- `userColor`

### `LocalEarthBootstrap.cs`

Purpose:

- Find or create `LocalEarth`.
- Apply local Earth texture.
- Optionally create atmosphere.
- Setup basic lighting.

Current important defaults:

```csharp
createAtmosphere = false;
setupLighting = true;
```

Atmosphere was disabled because the first version rendered as a blue shell in URP and obscured the Earth texture.

### `Editor/LocalGlobeSceneBuilder.cs`

Adds Unity menu:

```text
GeoTravel/Create Local Globe Scene
```

Expected behavior:

- Creates new scene `Assets/Scenes/LocalGlobeScene.unity`.
- Creates `LocalEarth` sphere at origin.
- Applies `Assets/Resources/earth_day.jpg` as material texture.
- Creates `GlobeOverviewCamera` with `LocalGlobeController`.
- Creates `MarkerManager` with `LocalMarkerManager`.
- Creates key directional light.

## Current Problem

When running in Unity Editor, the local globe view still looks wrong.

Observed user report:

- "本地地球似乎就是一个蓝色的框架啥都没有"
- After changes, user says direct Unity run still displays incorrectly.

Likely areas to inspect:

1. Whether `LocalEarth` actually has a Mesh Renderer material with `earth_day.jpg`.
2. Whether URP material properties are correctly assigned:
   - `_BaseMap`
   - `_BaseColor`
3. Whether Game View is using `GlobeOverviewCamera`.
4. Whether `LocalEarth` is inside the camera frustum.
5. Whether camera distance mapping places camera too close/too far.
6. Whether sphere normal/camera orientation is correct.
7. Whether lighting/shader makes texture invisible.
8. Whether `earth_day.jpg` import settings are valid in Unity.

## Important Recent Fixes Already Tried

Disabled default atmosphere:

```csharp
public bool createAtmosphere = false;
```

Scene builder now creates `LocalEarth` at edit time instead of only at runtime.

Scene builder sets:

```csharp
earth.transform.localScale = Vector3.one * 20f;
controller.globe = earth.transform;
markerManager.globe = earth.transform;
camera.backgroundColor = Color.black;
controller.transparentBackground = false;
```

Material assignment attempts:

```csharp
material.mainTexture = texture;

if (material.HasProperty("_BaseMap"))
    material.SetTexture("_BaseMap", texture);

if (material.HasProperty("_BaseColor"))
    material.SetColor("_BaseColor", Color.white);
```

## Suggested Next Task for Codex Desktop

Please open `/Users/shuke/Desktop/develop/first3D` in Unity/Codex Desktop and debug the local globe scene.

Steps:

1. Open Unity project:

```text
/Users/shuke/Desktop/develop/first3D
```

2. In Unity menu, run:

```text
GeoTravel/Create Local Globe Scene
```

3. Open:

```text
Assets/Scenes/LocalGlobeScene.unity
```

4. Press Play and inspect Game View.

5. Fix local globe rendering until:

- `LocalEarth` is clearly visible.
- Earth texture is visible, not a blue shell.
- Camera frames the globe correctly.
- Background is black in Unity Editor preview.
- Marker manager still receives JSON and places custom markers.
- Object names remain:
  - `GlobeOverviewCamera`
  - `MarkerManager`

6. Prefer robust Unity-side fixes over Flutter changes.

## Strong Preference

Do not continue with the Flutter third-party globe package as final Home implementation.

The desired final Home globe should be Unity-based because:

- marker visuals need full custom control;
- marker animation and hit areas need full custom control;
- globe shader/material/lighting needs full custom control;
- Home should avoid Cesium attribution and online load cost.

## Possible Better Implementation Direction

If the current runtime-created primitive sphere approach is fragile, replace it with explicit Unity assets:

- Create a real `LocalEarth` prefab.
- Create a material asset `M_LocalEarth`.
- Assign texture asset manually or through editor script.
- Create marker prefab asset.
- Use a simple unlit or custom URP shader first.
- Only after texture/camera/markers work, add atmosphere shader.

Recommended first stable visual:

- Unlit textured sphere.
- No atmosphere.
- No transparent materials.
- Black camera background.
- Camera at fixed distance looking at origin.

After that:

- Add subtle atmosphere as separate shader.
- Add cloud layer.
- Add marker scaling by camera distance.
- Add marker billboarding / surface normal alignment.
