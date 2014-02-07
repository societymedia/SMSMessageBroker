//
//  SMSMessageBroker.h
//  SMSMessageBroker
//
//  Created by Tony Merante on 2/1/14.
//  Copyright (c) 2014 societymedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SMSMessage;

@protocol SMSEventAgregatorProtocol <NSObject>
@end

@interface SMSMessageBroker : NSObject<SMSEventAgregatorProtocol> {}
+ (SMSMessageBroker *)sharedInstance;
- (void)trigger:(NSString *)name;

- (void)on:(NSString*)name performAction:(SEL)msg observeOn:(id)observeOn;
- (void)on:(NSString*)name performAction:(SEL)msg observeOn:(id)observeOn fireAndForget:(BOOL)fireAndForget;
- (void)on:(NSString*)name performAction:(SEL)msg observeOn:(id)observeOn observeFrom:(id)observeFrom;
- (void)on:(NSString*)name performAction:(SEL)msg observeOn:(id)observeOn observeFrom:(id)observeFrom fireAndForget:(BOOL)fireAndForget;



- (id)on:(NSString *)identifier performAction:(SEL)action observeOn:(id)observeOn observeFrom:(id)sender userData:(NSDictionary *)data block:(void (^) (NSNotification *notification))block;
- (void)addMessage:(SMSMessage *)message;
@end

