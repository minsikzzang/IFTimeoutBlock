//
//  IFTimeoutBlockTests.m
//  IFTimeoutBlockTests
//
//  Created by Min Kim on 2/18/14.
//  Copyright (c) 2014 iFactory Lab Limited. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IFTimeoutBlock.h"

@interface IFTimeoutBlockTests : XCTestCase

@end

@implementation IFTimeoutBlockTests

- (void)setUp {
  [super setUp];
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
}

- (void)testTimeout {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  IFTimeoutBlock *block = [[IFTimeoutBlock alloc] init];
  
  IFTimeoutHandler timeoutBlock = ^(IFTimeoutBlock *block) {
    XCTAssertTrue(YES);
  };
  
  IFExecutionBlock executionBlock = ^(IFTimeoutBlock *block) {
    sleep(2);
    [block signal];
    XCTAssertTrue(block.timedOut);      
    dispatch_semaphore_signal(semaphore);
  };
  
  [block setExecuteAsyncWithTimeout:1
                        WithHandler:timeoutBlock
                  andExecutionBlock:executionBlock];
  [block release];
  
  while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  }
  
  dispatch_release(semaphore);
}

- (void)testNonTimeout {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  IFTimeoutBlock *block = [[IFTimeoutBlock alloc] init];
  
  IFTimeoutHandler timeoutBlock = ^(IFTimeoutBlock *block) {
    XCTAssertTrue(YES);
  };
  
  IFExecutionBlock executionBlock = ^(IFTimeoutBlock *block) {
    [block signal];
    XCTAssertFalse(block.timedOut);
    dispatch_semaphore_signal(semaphore);
  };
  
  [block setExecuteAsyncWithTimeout:2
                        WithHandler:timeoutBlock
                  andExecutionBlock:executionBlock];
  [block release];
  
  while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  }
  
  dispatch_release(semaphore);
}

- (void)testWithMultiThreaad {
  NSThread *thread1 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadLoop)
                                                object:nil];
  NSThread *thread2 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadLoop)
                                                object:nil];
  NSThread *thread3 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadLoop)
                                                object:nil];
  [thread1 start];
  [thread2 start];
  [thread3 start];

  while (!thread1.isCancelled ||
         !thread2.isCancelled ||
         !thread3.isCancelled) {
    [NSThread sleepForTimeInterval:.1];
  }

  NSLog(@"thread1: %@, thread2: %@, thread3: %@", thread1.isCancelled ? @"Y" : @"N",
        thread2.isCancelled ? @"Y" : @"N", thread3.isCancelled ? @"Y" : @"N");

  [thread1 release];
  [thread2 release];
  [thread3 release];
}

- (void)threadLoop {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  IFTimeoutBlock *block = [[IFTimeoutBlock alloc] init];
  
  IFTimeoutHandler timeoutBlock = ^(IFTimeoutBlock *block) {
  };
  
  IFExecutionBlock executionBlock = ^(IFTimeoutBlock *block) {
    [block signal];
    XCTAssertFalse(block.timedOut);
    dispatch_semaphore_signal(semaphore);
  };
  
  [block setExecuteAsyncWithTimeout:2
                        WithHandler:timeoutBlock
                  andExecutionBlock:executionBlock];
  
  while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  }
  
  [block release];
  dispatch_release(semaphore);
  
  [[NSThread currentThread] cancel];
}

- (void)testWithMultiThreaadTimeout {
  NSThread *thread1 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadTimeoutLoop)
                                                object:nil];
  NSThread *thread2 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadTimeoutLoop)
                                                object:nil];
  NSThread *thread3 = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadTimeoutLoop)
                                                object:nil];
  [thread1 start];
  [thread2 start];
  [thread3 start];
  
  while (!thread1.isCancelled ||
         !thread2.isCancelled ||
         !thread3.isCancelled) {
    [NSThread sleepForTimeInterval:.1];
  }
 
  [thread1 release];
  [thread2 release];
  [thread3 release];
}

- (void)threadTimeoutLoop {
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  IFTimeoutBlock *block = [[IFTimeoutBlock alloc] init];
  
  IFTimeoutHandler timeoutBlock = ^(IFTimeoutBlock *block) {
  };
  
  IFExecutionBlock executionBlock = ^(IFTimeoutBlock *block) {
    sleep(2);
    [block signal];
    XCTAssertTrue(block.timedOut);
    dispatch_semaphore_signal(semaphore);
  };
  
  [block setExecuteAsyncWithTimeout:1
                        WithHandler:timeoutBlock
                  andExecutionBlock:executionBlock];
  
  while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  }
  [block release];
  dispatch_release(semaphore);
  
  [[NSThread currentThread] cancel];
}

@end
