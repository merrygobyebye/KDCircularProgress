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


/* already exposed to implementation file
- (instancetype) initWithFrame:(CGRect)frame;
 - (instancetype) initWithCoder:(NSCoder *)aDecoder;
 - (void)awakeFromNib;
 */

// Convenience initializer
- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors;

// TODO: layerClass needed? probably not, not used in examples

- (void)updateColors:(NSArray *)colors;

- (void)animateFromAngle:(NSInteger)fromAngle animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL complete))animationCompletion;

- (void)animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL complete))animationCompletion;

- (void)pauseAnimation;
- (void)stopAnimation;
- (BOOL)isAnimating;
//- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag;
- (void)didMoveToWindow;
- (void)willMoveToSuperview:(UIView *)newSuperview;
- (void)prepareForInterfaceBuilder;



@end