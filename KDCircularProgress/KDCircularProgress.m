//
//  KDCircularProgress.m
//  KDCircularProgressObjectiveCExample
//
//  Created by Eric Fisher on 7/22/15.
//  Copyright (c) 2015 Eric Fisher. All rights reserved.
//

#import "KDCircularProgress.h"

@interface KDCircularProgressViewLayer : CALayer

@property(nonatomic) NSArray *colorsArray;
@property(nonatomic) CGGradientRef gradientCache;
@property(nonatomic) NSArray *locationsCache;
@property(nonatomic) NSInteger *angle; // ???: NSManaged?

@end

@implementation KDCircularProgressViewLayer

// ???: colorsArray didSet?

@end


@interface KDCircularProgress ()

@property (nonatomic) KDCircularProgressViewLayer *progressLayer;
@property (nonatomic) CGFloat radius;

@end

@implementation KDCircularProgress

- (KDCircularProgressViewLayer *)progressLayer{
    // ???: is this correct?
    return (KDCircularProgressViewLayer*)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = NO;
        [self setInitialValues];
        [self refreshValues];
        [self checkAndSetIBColors];
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.userInteractionEnabled = NO;
        [self setInitialValues];
        [self refreshValues];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors {
    self = [super initWithFrame:frame];
    if (self) {
        [self setColors:colors];
    }
    return self;
}

+ (Class)layerClass {
    return [KDCircularProgressViewLayer class];
}

- (void)setColors:(NSArray *)colors{
    // ???: public and private method in swift
    _progressLayer.colorsArray = colors;
    [_progressLayer setNeedsDisplay];
}


- (void)animateFromAngle:(NSInteger)fromAngle animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(BOOL)completion{
    
}

- (void)animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(BOOL)completion{
    
}

#pragma  mark - Animations

- (void)pauseAnimation{
    KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[_progressLayer presentationLayer];
    NSInteger *currentValue = presentationLayer.angle;
    [_progressLayer removeAllAnimations];
    // TODO: animationCompletionBlock = nil;
    _angle = *currentValue;
}

- (void)stopAnimation{
    // ???: not sure why this first line is called, and why there is no warning in swift
    KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[_progressLayer presentationLayer];
    [_progressLayer removeAllAnimations];
    _angle = 0;
}
- (BOOL)isAnimating{
    return [_progressLayer animationForKey:(@"angle")] != nil;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    // TODO: animationCompletionBlock
}

#pragma  mark - UIView overrides

- (void)didMoveToWindow{
    // ???: this one was a bit messy
    UIWindow *window;
    if ((window = self.window)){
        _progressLayer.contentsScale = window->_screen.scale;
    }
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview == nil && [self isAnimating]){
        [self pauseAnimation];
    }
}
- (void)prepareForInterfaceBuilder{
    [self setInitialValues];
    [self refreshValues];
    [self checkAndSetIBColors];
    [_progressLayer setNeedsDisplay];
}




- (void)setInitialValues {
    _radius = (self.frame.size.width/2.0) * 0.8; //We always apply a 20% padding, stopping glows from being clipped
    self.backgroundColor = [UIColor clearColor];
    [self setColors:[[NSArray alloc] initWithObjects:[UIColor whiteColor],[UIColor redColor], nil]];
}



- (void)refreshValues {
    
}

- (void)checkAndSetIBColors {
    
}

@end
