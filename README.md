# MimChucker

A powerful, modern network inspector for Flutter applications, built with a beautiful Shadcn UI interface. MimChucker allows you to inspect HTTP requests and responses directly within your app.

## Features

- 🔍 Inspect HTTP requests and responses
- 🎨 Beautiful Shadcn UI design
- 🚀 Floating draggable button for easy access
- 📊 Filter by status code, method, or search by content
- 🔌 Support for Dio, Http, and Chopper
- 🌗 Light and Dark mode support
- � JSON viewer with syntax highlighting

## Installation

You can use MimChucker by resolving it from GitHub or using a local path.

### Git Dependency

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  mim_chucker:
    git:
      url: https://github.com/ahmet-ozberk/mim_chucker.git
      ref: main
```

### Local Path Dependency

If you have the package locally:

```yaml
dependencies:
  mim_chucker:
    path: ../modules/mim_chucker
```

## Usage

### 1. Wrap your App

Wrap your root `MaterialApp` (or `CupertinoApp`) with `MimChucker.app`. This automatically adds the floating inspector button.

Also, add `MimChucker.navigatorObserver` to your `navigatorObservers` to handle overlay navigation correctly.

```dart
import 'package:mim_chucker/mim_chucker.dart';

// ...

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // It's recommended to only enable MimChucker in debug mode
    final enableChucker = kDebugMode; 

    return MimChucker.app(
      enabled: enableChucker, 
      child: MaterialApp(
        title: 'My App',
        home: MyHomePage(),
      ),
    );
  }
}
```

### 2. Add Interceptors

Integrate MimChucker with your HTTP client to start capturing requests.

#### Dio

```dart
import 'package:dio/dio.dart';
import 'package:mim_chucker/mim_chucker.dart';

final dio = Dio();
dio.interceptors.add(MimDioInterceptor());
```

#### http

Not: `http` paketini kullanırken `MimHttpClient` wrapper'ını kullanın.

```dart
import 'package:http/http.dart' as http;
import 'package:mim_chucker/mim_chucker.dart';

final client = MimHttpClient(http.Client());
final response = await client.get(Uri.parse('https://api.example.com'));
```

#### Chopper

```dart
import 'package:chopper/chopper.dart';
import 'package:mim_chucker/mim_chucker.dart';

final chopper = ChopperClient(
  interceptors: [
    MimChopperInterceptor(),
  ],
  // ...
);
```

## Configuration

You can configure global settings for MimChucker:

```dart
// Enable/Disable on release builds (default: false)
MimChucker.showOnRelease = true;

// Set custom notification duration
MimChucker.setNotificationDuration(3);
```
