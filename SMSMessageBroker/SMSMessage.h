//
// SMSMessage
// 
// Created by Tony Merante on 2/2/14.
//
// Copyright (c) 2014 Bottle Rocket Apps. All rights reserved.
#import <Foundation/Foundation.h>


@interface SMSMessage : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) SEL actionToPerform;
@property (nonatomic, strong) id observeOn;
@property(nonatomic) BOOL fireAndForget;
@property(nonatomic, strong) NSDictionary *userdata;
@property(nonatomic, strong) id observeFrom;
@end