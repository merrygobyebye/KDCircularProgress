//
//  KDCircularProgress.m
//  KDCircularProgressObjectiveCExample
//
//  Created by Eric Fisher on 7/22/15.
//  Copyright (c) 2015 Eric Fisher. All rights reserved.
//

#import "KDCircularProgress.h"

@interface KDCircularProgress ()

- (void) setInitialValues;
- (void) refreshValues;
- (void) checkAndSetIBColors;

@end

@implementation KDCircularProgress

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    // userInteractionEnabled?
    [self setInitialValues];
    [self refreshValues];
    [self checkAndSetIBColors];
    return self;
}

@end
