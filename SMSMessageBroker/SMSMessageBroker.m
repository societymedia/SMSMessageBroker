//
//  SMSMessageBroker.m
//  SMSMessageBroker
//
//  Created by Tony Merante on 2/1/14.
//  Copyright (c) 2014 societymedia. All rights reserved.
//

#import "SMSMessageBroker.h"
#import "SMSMessage.h"

@implementation SMSMessageBroker{
    NSMutableDictionary *__internalMessageStorage;
}


+ (SMSMessageBroker *)sharedInstance
{
    static SMSMessageBroker *__messageBroker= nil;

    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        __messageBroker = [[SMSMessageBroker alloc] init];
    });

    return __messageBroker;
}

- (id)init {
    self = [super init];
    if (self) {
        __internalMessageStorage = [[NSMutableDictionary alloc] init];
    }

    return self;
}


#pragma mark Trigger Methods
-(void)trigger:(NSString *)identifier {

    SMSMessage *message = [__internalMessageStorage objectForKey:identifier];

    if(message) {
        [[NSNotificationCenter defaultCenter] postNotificationName:identifier
                                                            object:message.observeOn

                                                          userInfo:message.userdata];


        if(message.fireAndForget) {
            [self removeMessage:message];
        }
    }
}



#pragma mark Registration Methods





- (void)on:(NSString *)name performAction:(SEL)msg observeOn:(id)observeOn
{
    [self on:name performAction:msg observeOn:observeOn fireAndForget:NO];
}

- (void)on:(NSString *)name performAction:(SEL)msg observeOn:(id)observeOn fireAndForget:(BOOL)fireAndForget
{
    [self on:name performAction:msg observeOn:observeOn observeFrom:nil fireAndForget:fireAndForget];
}

- (void)on:(NSString *)name performAction:(SEL)msg observeOn:(id)observeOn observeFrom:(id)observeFrom
{
   [self on:name performAction:msg observeOn:observeOn observeFrom:observeFrom fireAndForget:NO];
}

- (void)on:(NSString *)name performAction:(SEL)msg observeOn:(id)observedOn observeFrom:(id)observeFrom fireAndForget:(BOOL)fireAndForget
{
    SMSMessage *message = [SMSMessage new];
    message.identifier = name;
    message.actionToPerform = msg;
    message.observeOn = observedOn;
    message.observeFrom = observeFrom;
    message.fireAndForget = fireAndForget;

    
    [self addEventToInternalStorage:name withMessage:message];
}

- (id)on:(NSString *)identifier performAction:(SEL)action observeOn:(id)observeOn observeFrom:(id)sender userData:(NSDictionary *)data block:(void (^) (NSNotification *notification))block {
    return nil;
}

#pragma mark Private Methods

- (void)removeMessage:(SMSMessage *)message
{
    [__internalMessageStorage removeObjectForKey:message.identifier];
    [[NSNotificationCenter defaultCenter] removeObserver:message.observeOn name:message.identifier object:nil];
}

- (void)addEventToInternalStorage:(NSString *)identifier withMessage:(SMSMessage *)message {
    
    // we only want to add the message once 
    if(![__internalMessageStorage objectForKey:identifier]){
        [__internalMessageStorage setObject:message forKey:identifier];
        [[NSNotificationCenter defaultCenter] addObserver:message.observeOn selector:message.actionToPerform name:message.identifier object:message.observeFrom];
    }
}


- (void)addMessage:(SMSMessage *)message
{
    [self addEventToInternalStorage:message.identifier withMessage:message];
}
@end




