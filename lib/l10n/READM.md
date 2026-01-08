<!--  多语言添加流程 -->

在.arb 文件添加翻译 每一个语言创建对应语言.arb 文件

## arb 文件规则

1. app\_{语言代码}.arb
2. 示例：
   app_en.arb - 英语
   app_zh.arb - 中文
   app_ja.arb - 日语
   app_ko.arb - 韩语
   app_zh_TW.arb - 繁体中文（台湾）

## 模版文件

```json
{
  "@@locale": "en",
  "homeTitle": "Home",
  "noData": "No Data",
  "welcome": "Welcome, {name}!"
}
```

## 命令

添加后 跑命令

flutter gen-l10n

生成 dart 文件

每次运行 flutter run 或 flutter build 时会自动重新生成 app_localizations.dart。

## 国际化使用例子

```dart
Text(AppLocalizations.of(context)!.newField)

```
