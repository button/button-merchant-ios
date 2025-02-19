fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build

```sh
[bundle exec] fastlane ios build
```

Build an XCFramework

### ios version

```sh
[bundle exec] fastlane ios version
```

Current library version

### ios lint

```sh
[bundle exec] fastlane ios lint
```

Run SwiftLint on the project

### ios test

```sh
[bundle exec] fastlane ios test
```

Run the Button merchant library tests

### ios coverage

```sh
[bundle exec] fastlane ios coverage
```



### ios generate_refdocs

```sh
[bundle exec] fastlane ios generate_refdocs
```



### ios post_install_test

```sh
[bundle exec] fastlane ios post_install_test
```

Run end-to-end post install test

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
