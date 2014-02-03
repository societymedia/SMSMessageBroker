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

    SMSMessage *message = [SMSMessage new];
    message.identifier = @"EventName";
    message.actionToPerform = @selector(writeln);
    message.actionOn = testClass;


    [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass];
    [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");

    [[SMSMessageBroker sharedInstance] trigger:@"EventName" onSender:testClass withUserdata:nil];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");
}
- (void)testEventRegistrationForDuplicates {

    SMSEventTestClass *testClass = [SMSEventTestClass new];

   [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass];
    [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass];

    [[SMSMessageBroker sharedInstance] trigger:@"EventName" onSender:testClass withUserdata:nil];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");

}
- (void)testEventRegistrationAndForget {


    SMSEventTestClass *testClass = [SMSEventTestClass new];
    [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass forget:YES];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");

    [[SMSMessageBroker sharedInstance] trigger:@"EventName" onSender:testClass withUserdata:nil];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");

    [[SMSMessageBroker sharedInstance] trigger:@"EventName" onSender:testClass withUserdata:nil];

    XCTAssertTrue(testClass.callCount == 1, @"Call Count should be 1");
}

- (void)testEventIdentifiers {


    SMSEventTestClass *testClass = [SMSEventTestClass new];
    [[SMSMessageBroker sharedInstance] on:@"EventName" performAction:@selector(writeln) observeOn:testClass forget:YES];


    [[SMSMessageBroker sharedInstance] trigger:@"EventName_wrong" onSender:testClass withUserdata:nil];

    XCTAssertTrue(testClass.callCount == 0, @"Call Count should be 0");
}


@end
