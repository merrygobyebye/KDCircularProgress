//
//  KDCircularProgress.h
//  KDCircularProgressObjectiveCExample
//
//  Created by Eric Fisher on 7/22/15.
//  Copyright (c) 2015 Eric Fisher. All rights reserved.
//

@import UIKit;
@import Foundation;

typedef NS_ENUM(NSInteger, KDCircularProgressGlowMode){
    Forward,
    Reverse,
    Constant,
    NoGlow
};

IB_DESIGNABLE
@interface KDCircularProgress : UIView

#pragma mark - Public Properties
@property (nonatomic) IBInspectable NSInteger angle;
@property (nonatomic) IBInspectable NSInteger startAngle;
@property (nonatomic) IBInspectable BOOL clockwise;
@property (nonatomic) IBInspectable BOOL roundedCorners;
@property (nonatomic) IBInspectable CGFloat gradientRotateSpeed;
@property (nonatomic) IBInspectable CGFloat glowAmount;
@property (nonatomic) IBInspectable CGFloat progressThickness;
@property (nonatomic) IBInspectable CGFloat trackThickness;
@property (nonatomic) IBInspectable UIColor *trackColor;
@property (nonatomic, copy) IBInspectable NSArray *progressColors;
@property (nonatomic) IBInspectable KDCircularProgressGlowMode glowMode;

#pragma mark - Public Lifecycle
- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors;

- (void)didMoveToWindow;

- (void)willMoveToSuperview:(UIView *)newSuperview;

- (void)prepareForInterfaceBuilder;

#pragma mark - Public
- (void)updateColors:(NSArray *)colors;

- (void)animateFromAngle:(NSInteger)fromAngle animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL complete))animationCompletion;

- (void)animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL complete))animationCompletion;

- (void)pauseAnimation;

- (void)stopAnimation;

- (BOOL)isAnimating;

@end