fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios version
```
fastlane ios version
```
Current library version
### ios lint
```
fastlane ios lint
```
Run SwiftLint on the project
### ios test
```
fastlane ios test
```
Run the Button merchant library tests
### ios coverage
```
fastlane ios coverage
```

### ios generate_refdocs
```
fastlane ios generate_refdocs
```

### ios post_install_test
```
fastlane ios post_install_test
```
Run end-to-end post install test

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
