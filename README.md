# IFTimeoutBlock

Asynchronous execution block with timeout support

## Getting Started

### Install the Prerequisites

* OS X is requried for all iOS development
* [XCODE](https://developer.apple.com/xcode/) from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?ls=1&mt=12).
* [GIT](http://git-scm.com/download/mac) is required.
* [CocoaPods](http://beta.cocoapods.org/) is required for the iOS dependency management. You should have [ruby](http://www.interworks.com/blogs/ckaukis/2013/03/05/installing-ruby-200-rvm-and-homebrew-mac-os-x-108-mountain-lion) installed on your machine before install CocoaPods

### Install the library

Source code for the SDK is available on [GitHub](git@github.com:ifactorylab/IFTimeoutBlock.git)
```
$ git clone git@github.com:ifactorylab/IFTimeoutBlock.git
```

### Run CocoaPods

CocoaPods installs all dependencies for the library project
```
$ cd IFTimeoutBlock
$ pod install
$ open IFTimeoutBlock.xcodeproj
```

### Add rtmp-wrapper to your project

Create a Podfile if not exist, add the line below
```
pod 'IFTimeoutBlock',   '~> 1.0.0'
```

### Example

```
#import "IFTimeoutBlock.h"

IFTimeoutBlock *block = [[IFTimeoutBlock alloc] init];
  
IFTimeoutHandler timeoutBlock = ^(IFTimeoutBlock *block) {
  // do something to notify timeout.....
};
  
IFExecutionBlock executionBlock = ^(IFTimeoutBlock *block) {
  // send signal to the module to stop timeout timer
  [block signal];
    
  // If timedout, block.timedOut should be true
  XCTAssertFalse(block.timedOut);
};
  

[block setExecuteAsyncWithTimeout:2 // timeout in seconds
                      WithHandler:timeoutBlock
                andExecutionBlock:executionBlock];
[block release];

```

## Version detail

### 1.0.0
- first version
