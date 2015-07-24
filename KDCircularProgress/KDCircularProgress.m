//
//  KDCircularProgress.m
//  KDCircularProgressObjectiveCExample
//
//  Created by Eric Fisher on 7/22/15.
//  Copyright (c) 2015 Eric Fisher. All rights reserved.
//

#import "KDCircularProgress.h"

@interface KDCircularProgressViewLayer : CALayer

@property(nonatomic) NSArray                    *colorsArray;
@property(nonatomic) CGGradientRef              gradientCache;
@property(nonatomic) NSArray                    *locationsCache;
@property(nonatomic) NSInteger                  angle; // ???: NSManaged?
@property(nonatomic) NSInteger                  startAngle;
@property(nonatomic) BOOL                       clockwise;
@property(nonatomic) CGFloat                    gradientRotateSpeed;
@property(nonatomic) CGFloat                    glowAmount;
@property(nonatomic) KDCircularProgressGlowMode glowMode;
@property(nonatomic) CGFloat                    progressThickness;
@property(nonatomic) CGFloat                    trackThickness;
@property(nonatomic) UIColor                    *trackColor;
@property(nonatomic) CGFloat                    radius;
@property(nonatomic) BOOL                       roundedCorners;



@end

@implementation KDCircularProgressViewLayer

// ???: colorsArray didSet?
- (CGFloat)glowAmountForAngle:(NSInteger*)angle glowAmount:(CGFloat)glowAmount glowMode:(KDCircularProgressGlowMode)glowMode size:(CGFloat)size{
    const CGFloat sizeToGlowRatio = 0.00015;
    switch (glowMode)
    {
        case Forward:
            return (CGFloat)self.angle * size * sizeToGlowRatio * glowAmount;
        case Reverse:
            return (CGFloat)(360 - self.angle) * size * sizeToGlowRatio * glowAmount;
        case Constant:
            return 360 * size * sizeToGlowRatio * glowAmount;
        default:
            return 0;
    }
}

- (instancetype)initWithLayer:(id)layer{
    self = [super initWithLayer:layer];
    if (self){
        KDCircularProgressViewLayer *progressLayer = (KDCircularProgressViewLayer *)layer;
        _radius = progressLayer.radius;
        _angle = progressLayer.angle;
        _startAngle = progressLayer.startAngle;
        _clockwise = progressLayer.clockwise;
        _roundedCorners = progressLayer.roundedCorners;
        _gradientRotateSpeed = progressLayer.gradientRotateSpeed;
        _glowAmount = progressLayer.glowAmount;
        _glowMode = progressLayer.glowMode;
        _progressThickness = progressLayer.progressThickness;
        _trackThickness = progressLayer.trackThickness;
        _trackColor = progressLayer.trackColor;
        _colorsArray = progressLayer.colorsArray;
    }
    return self;
}

- (void)setColorsArray:(NSArray *)colorsArray{
    if ([_colorsArray isEqual:colorsArray]){
        return;
    }
    _gradientCache = nil;
    _locationsCache = nil;
    _colorsArray = [colorsArray copy];
}

@end


@interface KDCircularProgress ()

@property(nonatomic) KDCircularProgressViewLayer       *progressLayer;
@property(nonatomic) CGFloat                           radius;
@property(nonatomic) IBInspectable UIColor              *IBColor1;
@property(nonatomic) IBInspectable UIColor              *IBColor2;
@property(nonatomic) IBInspectable UIColor              *IBColor3;
@property(nonatomic, copy) void                         (^animationCompletionBlock)(BOOL);

@end

@implementation KDCircularProgress

/*
- (KDCircularProgressViewLayer *)progressLayer{
    // ???: is this correct?
   return (KDCircularProgressViewLayer*)self.layer;
}
 */

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
    _progressLayer.colorsArray = [colors copy];
    [_progressLayer setNeedsDisplay];
}


- (void)animateFromAngle:(NSInteger)fromAngle animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL))animationCompletion{
    if ([self isAnimating]){
        [self pauseAnimation];
    }
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:(@"angle")];
    animation.fromValue = [NSNumber numberWithInteger:fromAngle];
    animation.toValue = [NSNumber numberWithInteger:toAngle];
    animation.duration = duration;
    animation.delegate = self;
    self.angle = (NSInteger)toAngle;
    self.animationCompletionBlock = animationCompletion;
    
    [self.progressLayer addAnimation:animation forKey:@"angle"];
    
}

- (void)animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL completed))animationCompletion{
    if ([self isAnimating]){
        [self pauseAnimation];
    }
    
    [self animateFromAngle:self.angle animateToAngle:toAngle animateDuration:duration animateCompletion:animationCompletion];
}

#pragma  mark - Animations

- (void)pauseAnimation{
    KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[_progressLayer presentationLayer];
    NSInteger currentValue = presentationLayer.angle;
    [_progressLayer removeAllAnimations];
    // TODO: animationCompletionBlock = nil;
    _angle = currentValue;
}

- (void)stopAnimation{
    // ???: not sure why this first line is called, and why there is no warning in swift
    //KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[_progressLayer presentationLayer];
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
    UIWindow *window;
    if ((window = self.window)){
        self.progressLayer.contentsScale = window.screen.scale;
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
    [self setColors:@[[UIColor whiteColor],[UIColor redColor]]];
}



- (void)refreshValues {
    self.progressLayer.angle = self.angle;
    self.progressLayer.startAngle = [self mod:self.startAngle range:360 min:0 max:360];
    self.progressLayer.clockwise = self.clockwise;
    self.progressLayer.roundedCorners = self.roundedCorners;
    self.progressLayer.gradientRotateSpeed = self.gradientRotateSpeed;
    self.progressLayer.glowAmount = [self clamp:self.glowAmount min:0 max:1];
    self.progressLayer.glowMode = self.glowMode;
    self.progressLayer.progressThickness = self.progressThickness/2;
    self.progressLayer.trackColor = self.trackColor;
    self.progressLayer.trackThickness = self.trackThickness/2;
}

- (void)checkAndSetIBColors {
    // TODO: Kludge
    NSMutableArray *mutableColors = [[NSMutableArray init] alloc];
    if (self.IBColor1){
        [mutableColors addObject:self.IBColor1];
    }
    if (self.IBColor2){
        [mutableColors addObject:self.IBColor2];
    }
    if (self.IBColor3){
        [mutableColors addObject:self.IBColor3];
    }
    
    NSArray *colors = [mutableColors copy];
    if ([mutableColors count] > 0){
        [self setColors:colors];
    }
}

# pragma mark - Utility Functions
- (NSInteger)mod:(NSInteger)value range:(NSInteger)range min:(NSInteger)min max:(NSInteger)max{
    NSAssert(labs(range) <= labs(min-max), @"range should be <= the interval");
    if (value >= min && value <= max){
        return value;
    }
    if (value < min) {
        return [self mod:(value + range) range:range min:min max:max];
    }
    return [self mod:(value-range) range:range min:min max:max];
}

- (CGFloat)clamp:(CGFloat)value min:(CGFloat)min max:(CGFloat)max{
    if (value < min){
        return min;
    }
    if (value > max) {
        return max;
    }
    return value;
}

@end
