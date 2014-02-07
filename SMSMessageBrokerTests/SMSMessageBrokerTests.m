//
//  SMSMessageBrokerTests.m
//  SMSMessageBrokerTests
//
//  Created by Tony Merante on 2/1/14.
//  Copyright (c) 2014 societymedia. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SMSMessageBroker.h"
#import "SMSMessage.h"

@interface SMSEventTestClass: NSObject
@property (nonatomic, assign) NSInteger callCount;
- (void)writeln;

@end

@implementation SMSEventTestClass
- (void)writeln
{
    self.callCount++;
    NSLog(@"writeln");
}
@end
@interface SMSMessageBrokerTests : XCTestCase

@end

@implementation SMSMessageBrokerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEventRegistration {

    SMSEventTestClass *testClass = [SMSEventTestClass new];


    NSLog(@"%@", [NSString stringWithFormat:@"%p", &testClass]);


    SMSMessage *message = [SMSMessage new];
    message.identifier =   [self eventNameForTest:testClass];
    message.actionToPerform = @selector(writeln);
    message.observeOn = testClass;


    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass] performAction:@selector(writeln) observeOn:testClass];
    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass] performAction:@selector(writeln) observeOn:testClass];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");

    [[SMSMessageBroker sharedInstance] trigger:[self eventNameForTest:testClass]];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");
}
- (void)testEventRegistrationForDuplicates {

    SMSEventTestClass *testClass = [SMSEventTestClass new];
    NSLog(@"%@", [NSString stringWithFormat:@"%p", &testClass]);

   [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass]  performAction:@selector(writeln) observeOn:testClass];
    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass]  performAction:@selector(writeln) observeOn:testClass];

    [[SMSMessageBroker sharedInstance] trigger:[self eventNameForTest:testClass]];

    NSLog(@"%d", testClass.callCount);
    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");

}
- (void)testEventRegistrationAndForget {


    SMSEventTestClass *testClass = [SMSEventTestClass new];

    NSLog(@"%@", [NSString stringWithFormat:@"%p", &testClass]);

    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass]  performAction:@selector(writeln) observeOn:testClass fireAndForget:YES];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");

    [[SMSMessageBroker sharedInstance] trigger:[self eventNameForTest:testClass]];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");

    [[SMSMessageBroker sharedInstance] trigger:[self eventNameForTest:testClass]];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");
}

- (void)testEventIdentifiers {


    SMSEventTestClass *testClass = [SMSEventTestClass new];

    NSLog(@"%@", [NSString stringWithFormat:@"%p", &testClass]);

    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass] performAction:@selector(writeln) observeOn:testClass fireAndForget:YES];


    [[SMSMessageBroker sharedInstance] trigger:@"EventName_wrong"];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");
}



#pragma mark ObservedFrom Tests

- (void)test_that_events_get_triggered_only_on_observedFrom {

    SMSEventTestClass *observeOn = [SMSEventTestClass new];
    SMSEventTestClass *observeFrom = [SMSEventTestClass new];

    NSString *eventName = [NSString stringWithFormat:@"%p%p", &observeOn, &observeFrom];
    [[SMSMessageBroker sharedInstance] on:eventName performAction:@selector(writeln) observeOn:observeOn observeFrom:observeFrom  fireAndForget:NO];


    [[SMSMessageBroker sharedInstance] trigger:eventName];

    XCTAssertTrue(observeOn.callCount == 0, @"Call Count should be 0");



    [[SMSMessageBroker sharedInstance] on:@"easdasdsad" performAction:@selector(writeln) observeOn:observeFrom fireAndForget:NO];
    [[SMSMessageBroker sharedInstance] trigger:@"easdasdsad"];


    XCTAssertTrue(observeOn.callCount == 1, @"Call Count should be 1");
}



#pragma mark Clean up tests
/*
    We want to make sure that the observedOn object is completely removed
    from NSNotification Center


 */

- (void)testThatObservedOnObjectIsRemovedFromNSNotificationCenter {

    SMSEventTestClass *testClass = [SMSEventTestClass new];

    NSLog(@"%@", [NSString stringWithFormat:@"%p", &testClass]);

    [[SMSMessageBroker sharedInstance] on:[self eventNameForTest:testClass] performAction:@selector(writeln) observeOn:testClass fireAndForget:YES];


    [[SMSMessageBroker sharedInstance] trigger:@"EventName_wrong"];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");
}




#pragma mark Private testing methods

- (NSString *)eventNameForTest:(SMSEventTestClass *)obj {

    NSString *eventName =  [NSString stringWithFormat:@"%p", &obj];
//                         NSLog(@"%@", eventName);
    return eventName;
}



@end
