//
//  IFTimeoutBlock.m
//  IFTimeoutBlock
//
//  Created by Min Kim on 2/18/14.
//  Copyright (c) 2014 iFactory Lab Limited. All rights reserved.
//

#import "IFTimeoutBlock.h"

@interface IFTimeoutBlock() {
  int signalsRemaining_;
  int expectedSignalCount_;
}

- (void)reset;

/*
@property (nonatomic, copy) IFExecutionBlock executionBlock;
@property (nonatomic, copy) IFTimeoutHandler timeoutBlock;
*/

@end

@implementation IFTimeoutBlock

@synthesize timedOut;
// @synthesize executionBlock;
// @synthesize timeoutBlock;

- (id)init {
  return [self initWithExpectedSignalCount:1];
}

- (id)initWithExpectedSignalCount:(NSInteger)expectedSignalCount {
  if (self = [super init]) {
    expectedSignalCount_ = expectedSignalCount;
    [self reset];
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)waitWithTimeout:(NSUInteger)timeout
        periodicHandler:(IFTimeoutPeriodicHandler)handler {
  NSDate *start = [NSDate date];
  
  // loop until the previous call completes
  while (signalsRemaining_ > 0) {
    [NSThread sleepForTimeInterval:.1];
    if (timeout > 0 &&
        [[NSDate date] timeIntervalSinceDate:start] > timeout) {
      // We only return when it's timed-out.
      if (handler) {
        handler(self);
        break;
      }
    }
  };
  [self reset];
}

- (void)signal {
  @synchronized (self) {
    --signalsRemaining_;
  }
}

- (void)reset {
  signalsRemaining_ = expectedSignalCount_;
}

static dispatch_queue_t timeout_block_queue() {
  static dispatch_queue_t if_timeout_block_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if_timeout_block_queue = dispatch_queue_create("com.ifactory.lab.timeout.block", DISPATCH_QUEUE_CONCURRENT);
  });
  
  return if_timeout_block_queue;
}

static dispatch_queue_t execution_block_queue() {
  static dispatch_queue_t if_execution_block_queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    if_execution_block_queue = dispatch_queue_create("com.ifactory.lab.execution.block", DISPATCH_QUEUE_CONCURRENT);
  });
  
  return if_execution_block_queue;
}


- (void)setExecuteAsyncWithTimeout:(int)timeout
                       WithHandler:(IFTimeoutHandler)handler
                 andExecutionBlock:(IFExecutionBlock)execution {
  dispatch_async(timeout_block_queue(), ^{
    [self waitWithTimeout:timeout periodicHandler:^(IFTimeoutBlock *block) {
      block.timedOut = YES;
      handler(block);
    }];
  });
  
  
  dispatch_async(execution_block_queue(), ^{
    execution(self);
  });
}

@end
