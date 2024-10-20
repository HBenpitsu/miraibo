# Miraibo

## Explanation

An application to help users manage their finances, focusing on balancing payments. This app provides features to estimate and visualize the user's financial situation **in the future**. It is particularly useful for young people, such as students.

## Generic Name

Life Planer

# Development

## Development Environment

We use Flutter to develop this app. If you have FVM (Flutter Version Management) installed, you can start development immediately after cloning this repository.

To get started, try running:

```console
fvm flutter run
```

If this works, you can proceed with development.

If not, you may need to:

- Install FVM or set up the Flutter environment.
- Ensure the proper version of Flutter is installed by running:

```console
fvm install stable
```

If you prefer not to use FVM, you can still proceed, but please ensure you have the correct version of Flutter installed and configured.

To get dependencies, execute following commands:

```console
fvm flutter pub get
fvm dart run sqflite_common_ffi_web:setup
```

## Way to Develop

You only need to edit files in the `lib` directory. The `doc` directory, created by `hbenpitsu`, contains documentation that I highly recommend consulting when reading code in the `lib` directory. Additionally, please update the documentation when you write new code.

## Documentation for flutter

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [online documentation](https://docs.flutter.dev/)
