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
-(void)trigger:(NSString *)identifier onSender:sender withUserdata:(NSDictionary*) userdata{

    [[NSNotificationCenter defaultCenter] postNotificationName:identifier
                                                        object:sender
                                                      userInfo: userdata];

    if([__internalMessageStorage objectForKey:identifier]) {
       [self removeByIdentifier:identifier withObject:sender];
    }
}

#pragma mark Registration Methods



-(void)on:(NSString*)name performAction:(SEL)msg observeOn:observedObject forget:(BOOL)forget {
    if(forget) {
        [__internalMessageStorage setObject:observedObject forKey:name];
    }
    [[NSNotificationCenter defaultCenter] addObserver:observedObject selector:msg name:name object:nil];
}

- (void)on:(NSString *)name performAction:(SEL)msg observeOn:(id)observedObject
{
    SMSMessage *message = [SMSMessage new];
    message.identifier = name;
    message.actionToPerform = msg;
    message.actionOn = observedObject;


    [self addEventToInternalStorage:name withMessage:message];
}


- (id)on:(NSString *)identifier performAction:(SEL)action observeOn:(id)observeOn observeFrom:(id)sender userData:(NSDictionary *)data block:(void (^) (NSNotification *notification))block {
    return nil;
}

#pragma mark Private Methods
- (void)removeByIdentifier:(NSString *)identifier withObject:(id)observedObject {

    [__internalMessageStorage removeObjectForKey:identifier];
    [[NSNotificationCenter defaultCenter] removeObserver:observedObject name:identifier object:nil];
}

- (void)addEventToInternalStorage:(NSString *)identifier withMessage:(SMSMessage *)message {

    if(![__internalMessageStorage objectForKey:identifier]){
        [__internalMessageStorage setObject:message forKey:identifier];
        [[NSNotificationCenter defaultCenter] addObserver:message.actionOn selector:message.actionToPerform name:message.identifier object:nil];
    }
}


- (void)addMessage:(SMSMessage *)message
{
    [self addEventToInternalStorage:message.identifier withMessage:message];
}
@end




