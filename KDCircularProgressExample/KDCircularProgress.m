//
//  KDCircularProgress.m
//  KDCircularProgressObjectiveCExample
//
//  Created by Eric Fisher on 7/22/15.
//  Copyright (c) 2015 Eric Fisher. All rights reserved.
//

#pragma mark - KDCircularProgressUtilityFunctions

#import "KDCircularProgress.h"

@interface KDCircularProgressUtilityFunctions : NSObject

+ (NSInteger)mod:(NSInteger)value range:(NSInteger)range min:(NSInteger)min max:(NSInteger)max;
+ (CGFloat)clamp:(CGFloat)value min:(CGFloat)min max:(CGFloat)max;
+ (CGFloat)radiansToDegrees:(CGFloat)value;
+ (CGFloat)degreesToRadians:(CGFloat)value;


@end

@implementation KDCircularProgressUtilityFunctions

# pragma mark - Utility Functions

+ (NSInteger)mod:(NSInteger)value range:(NSInteger)range min:(NSInteger)min max:(NSInteger)max{
    NSAssert(labs(range) <= labs(min-max), @"range should be <= the interval");
    if (value >= min && value <= max){
        return value;
    }
    if (value < min) {
        return [self mod:(value + range) range:range min:min max:max];
    }
    return [self mod:(value-range) range:range min:min max:max];
}

+ (CGFloat)clamp:(CGFloat)value min:(CGFloat)min max:(CGFloat)max{
    if (value < min){
        return min;
    }
    if (value > max) {
        return max;
    }
    return value;
}

#pragma mark - Conversion Functions

+ (CGFloat)degreesToRadians:(CGFloat)value{
    return value * (CGFloat)M_PI / 180.0;
}

+ (CGFloat)radiansToDegrees:(CGFloat)value{
    return value * 180.0 / (CGFloat)M_PI;
}

@end

#pragma mark - KDCircularProgressViewLayer

@interface KDCircularProgressViewLayer : CALayer

@property(nonatomic) NSArray                        *colorsArray;
@property(nonatomic) CGGradientRef                  gradientCache;
@property(nonatomic) NSArray                        *locationsCache;
@property(nonatomic) NSInteger                      angle;
@property(nonatomic) NSInteger                      startAngle;
@property(nonatomic) BOOL                           clockwise;
@property(nonatomic) CGFloat                        gradientRotateSpeed;
@property(nonatomic) CGFloat                        glowAmount;
@property(nonatomic) KDCircularProgressGlowMode     glowMode;
@property(nonatomic) CGFloat                        progressThickness;
@property(nonatomic) CGFloat                        trackThickness;
@property(nonatomic) UIColor                        *trackColor;
@property(nonatomic) CGFloat                        radius;
@property(nonatomic) BOOL                           roundedCorners;

@end

# pragma mark - KDCircularProgressViewLayer

@implementation KDCircularProgressViewLayer

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
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

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"angle"] ? YES : [super needsDisplayForKey:key];
}

#pragma mark - Custom Accessors

- (void)setColorsArray:(NSArray *)colorsArray{
    if ([_colorsArray isEqual:colorsArray]){
        return;
    }
    _gradientCache = nil;
    _locationsCache = nil;
    _colorsArray = [colorsArray copy];
}



# pragma mark - Drawing Functions

- (CGFloat)glowAmountForAngle:(NSInteger)angle glowAmount:(CGFloat)glowAmount glowMode:(KDCircularProgressGlowMode)glowMode size:(CGFloat)size{
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

-(void)drawInContext:(CGContextRef)ctx{
    UIGraphicsPushContext(ctx);
    CGRect rect = self.bounds;
    CGSize size = rect.size;
    CGFloat trackLineWidth = self.radius * self.trackThickness;
    CGFloat progressLineWidth = self.radius * self.progressThickness;
    CGFloat arcRadius = MAX(self.radius - trackLineWidth/2, self.radius - progressLineWidth/2);
    CGContextAddArc(ctx, (CGFloat)size.width/2.0, (CGFloat)size.height/2.0, arcRadius, 0, (CGFloat)M_PI*2, 0);
    [self.trackColor set];
    CGContextSetLineWidth(ctx, trackLineWidth);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0);
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    NSInteger reducedAngle = [KDCircularProgressUtilityFunctions mod:self.angle range:360 min:0 max:360];
    CGFloat fromAngle = [KDCircularProgressUtilityFunctions degreesToRadians:(CGFloat)self.startAngle * -1];
    CGFloat toAngle = [KDCircularProgressUtilityFunctions degreesToRadians:(CGFloat)(self.clockwise == YES ? reducedAngle * -1 : reducedAngle) - self.startAngle];
    CGContextAddArc(imageCtx, (CGFloat)size.width/2.0, (CGFloat)size.height/2.0, arcRadius, fromAngle, toAngle, self.clockwise == true ? 1 : 0);
    CGFloat glowValue = [self glowAmountForAngle:reducedAngle glowAmount:self.glowAmount glowMode:self.glowMode size:size.width];
    if (glowValue > 0){
        CGContextSetShadowWithColor(imageCtx, CGSizeZero, glowValue, [UIColor blackColor].CGColor);
    }
    CGContextSetLineCap(imageCtx, self.roundedCorners == YES ? kCGLineCapRound : kCGLineCapButt);
    CGContextSetLineWidth(imageCtx, progressLineWidth);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    CGImageRef drawMask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, self.bounds, drawMask);
    
    //Gradient - Fill
    if ([self.colorsArray count] > 1){
        NSMutableArray *componentsArrayMutable = [[NSMutableArray alloc] init];
        NSMutableArray *rgbColorsArray = [[NSMutableArray alloc] init];
        for (UIColor *color in self.colorsArray){
            if (CGColorGetNumberOfComponents(color.CGColor) == 2){
                CGFloat whiteValue = CGColorGetComponents(color.CGColor)[0];
                [rgbColorsArray addObject:[UIColor colorWithRed:whiteValue green:whiteValue blue:whiteValue alpha:1.0]];
            }
            else{
                [rgbColorsArray addObject:color];
            }
        }
        for (UIColor *color in rgbColorsArray){
            const CGFloat *colorComponents = CGColorGetComponents(color.CGColor);

            
            NSArray *colorsToAdd = [NSArray arrayWithObjects:[NSNumber numberWithFloat:colorComponents[0]], [NSNumber numberWithFloat:colorComponents[1]], [NSNumber numberWithFloat:colorComponents[2]], @1.0, nil];
            [componentsArrayMutable addObjectsFromArray:colorsToAdd];
        }
        NSArray *componentsArray = [componentsArrayMutable copy];
        [self drawGradientWithContext:ctx componentsArray:componentsArray];
    }
    else{
        if (self.colorsArray.count == 1){
            [self fillRectWithContext:ctx color:self.colorsArray[0]];
        }
        else{
            [self fillRectWithContext:ctx color:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
        }
    }
    
    CGContextRestoreGState(ctx);
    UIGraphicsPopContext();
}

- (void)drawGradientWithContext:(CGContextRef)ctx componentsArray:(NSArray*)componentsArray{
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *locationsArray = self.locationsCache.count > 0 ? [self.locationsCache copy] : [self gradientLocationsFromColorCount:componentsArray.count/4 gradientWidth:self.bounds.size.width];
    CGGradientRef gradient;
    if (self.gradientCache){
        gradient = self.gradientCache;
    }
    else{
        CGFloat *components = malloc(sizeof(CGFloat)*[componentsArray count]);
        CGFloat *locations = malloc(sizeof(CGFloat)*[locationsArray count]);
        int i = 0;
        for (NSNumber *num in componentsArray){
            components[i++] = [num floatValue];
        }
        i = 0;
        for (NSNumber *num in locationsArray){
            locations[i++] = [num floatValue];
        }
        
        CGGradientRef g = CGGradientCreateWithColorComponents(baseSpace, components, locations, componentsArray.count/4);
        self.gradientCache = g;
        gradient = g;
        free(components);
        free(locations);
    }
    
    CGFloat halfX = self.bounds.size.width/2.0;
    CGFloat floatPi = (CGFloat)M_PI;
    CGFloat rotateSpeed = self.clockwise == YES ? self.gradientRotateSpeed : self.gradientRotateSpeed * -1;
    CGFloat angleInRadians = [KDCircularProgressUtilityFunctions degreesToRadians:rotateSpeed * (CGFloat)self.angle - 90];
    CGFloat oppositeAngle = angleInRadians > floatPi ? angleInRadians - floatPi : angleInRadians + floatPi;
    
    CGPoint startPoint = CGPointMake((cos(angleInRadians) * halfX) + halfX, (sin(angleInRadians) * halfX) + halfX);
    CGPoint endPoint   = CGPointMake((cos(oppositeAngle) * halfX) + halfX, (sin(oppositeAngle) * halfX) + halfX);
    
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
}

- (void)fillRectWithContext:(CGContextRef)ctx color:(UIColor*)color{
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, self.bounds);
}

- (NSArray*)gradientLocationsFromColorCount:(NSInteger)colorCount gradientWidth:(CGFloat)gradientWidth{
    if (colorCount == 0 || gradientWidth == 0){
        return [[NSArray alloc] init];
    }
    else{
        NSMutableArray *locationsArrayMutable = [[NSMutableArray alloc] init];
        CGFloat progressLineWidth = self.radius * self.progressThickness;
        CGFloat firstPoint = gradientWidth/2 - (self.radius - progressLineWidth/2);
        CGFloat increment = (gradientWidth - (2*firstPoint))/(CGFloat)(colorCount - 1);
        
        for (int i = 0; i < colorCount; ++i){
            [locationsArrayMutable addObject:[NSNumber numberWithFloat:(firstPoint + ((CGFloat)i * increment))]];
        }
        NSAssert(locationsArrayMutable.count == colorCount, @"color counts should be equal");
        NSMutableArray *result = [[NSMutableArray alloc] init];
        for (NSNumber *num in locationsArrayMutable){
            [result addObject:@([num floatValue] / gradientWidth)];
        }
        self.locationsCache = [result copy];
        return [result copy];
    }
}

@end


# pragma mark - KDCircularProgress

@interface KDCircularProgress ()

@property(nonatomic) KDCircularProgressViewLayer    *progressLayer;
@property(nonatomic) CGFloat                        radius;
@property(nonatomic) IBInspectable UIColor          *IBColor1;
@property(nonatomic) IBInspectable UIColor          *IBColor2;
@property(nonatomic) IBInspectable UIColor          *IBColor3;
@property(nonatomic, copy) void                     (^animationCompletionBlock)(BOOL);

@end

@implementation KDCircularProgress

@synthesize progressColors = _progressColors;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeInspectableValues];
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
        [self initializeInspectableValues];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        self.userInteractionEnabled = NO;
        [self setInitialValues];
        [self refreshValues];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame colors:(NSArray *)colors {
    self = [self initWithFrame:frame];
    if (self) {
        [self updateColors:colors];
    }
    return self;
}

- (void)awakeFromNib{
    [self checkAndSetIBColors];
}

+ (Class)layerClass {
    return [KDCircularProgressViewLayer class];
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
    [self.progressLayer setNeedsDisplay];
}

#pragma mark - Initial setup

- (void)setInitialValues {
    self.radius = (self.frame.size.width/2.0) * 0.8; //We always apply a 20% padding, stopping glows from being clipped
    self.backgroundColor = [UIColor clearColor];
    [self updateColors:@[[UIColor whiteColor],[UIColor redColor]]];
}

- (void)checkAndSetIBColors {
    NSMutableArray *mutableColors = [[NSMutableArray alloc] init];
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
        [self updateColors:colors];
    }
}

- (void)refreshValues {
    
    self.progressLayer.angle = self.angle;
    self.progressLayer.startAngle = [KDCircularProgressUtilityFunctions mod:self.startAngle range:360 min:0 max:360];
    self.progressLayer.clockwise = self.clockwise;
    self.progressLayer.roundedCorners = self.roundedCorners;
    self.progressLayer.gradientRotateSpeed = self.gradientRotateSpeed;
    self.progressLayer.glowAmount = [KDCircularProgressUtilityFunctions clamp:self.glowAmount min:0 max:1];
    self.progressLayer.glowMode = self.glowMode;
    self.progressLayer.progressThickness = self.progressThickness/2;
    self.progressLayer.trackColor = self.trackColor;
    self.progressLayer.trackThickness = self.trackThickness/2;
}

- (void)updateColors:(NSArray *)colors{
    self.progressLayer.colorsArray = [colors copy];
    [self.progressLayer setNeedsDisplay];
}

#pragma mark - Custom Accessors

- (KDCircularProgressViewLayer *)progressLayer {
   return (KDCircularProgressViewLayer *)self.layer;
}

- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    self.progressLayer.radius = radius;
}

- (void)initializeInspectableValues{
    _angle = 0;
    _startAngle = 0;
    _clockwise = YES;
    _roundedCorners = YES;
    _gradientRotateSpeed = (CGFloat)0;
    _glowAmount = (CGFloat)1.0;
    _glowMode = Forward;
    _progressThickness = (CGFloat)0.4;
    _trackThickness = (CGFloat)0.5;
    _trackColor = [UIColor blackColor];
}

- (void)setAngle:(NSInteger)angle{
    
    _angle = angle;
    if ([self isAnimating]){
        [self pauseAnimation];
    }
    self.progressLayer.angle = angle;
    [self.progressLayer setNeedsDisplay];
    
}

- (void)setStartAngle:(NSInteger)startAngle{
    if (_startAngle == startAngle){
        return;
    }
    
    _startAngle = startAngle;
    self.progressLayer.startAngle = [KDCircularProgressUtilityFunctions mod:startAngle range:360 min:0 max:360];
    [self.progressLayer setNeedsDisplay];
}

- (void)setClockwise:(BOOL)clockwise{
    if (_clockwise == clockwise){
        return;
    }
    
    _clockwise = clockwise;
    self.progressLayer.clockwise = clockwise;
    [self.progressLayer setNeedsDisplay];
}

- (void)setRoundedCorners:(BOOL)roundedCorners{
    if (_roundedCorners == roundedCorners){
        return;
    }
    
    _roundedCorners = roundedCorners;
    self.progressLayer.roundedCorners = roundedCorners;
}

- (void)setGradientRotateSpeed:(CGFloat)gradientRotateSpeed{
    if (_gradientRotateSpeed == gradientRotateSpeed){
        return;
    }
    
    _gradientRotateSpeed = gradientRotateSpeed;
    self.progressLayer.gradientRotateSpeed = gradientRotateSpeed;
}

- (void)setGlowAmount:(CGFloat)glowAmount{
    if (_glowAmount == glowAmount){
        return;
    }
    
    _glowAmount = glowAmount;
    self.progressLayer.glowAmount = [KDCircularProgressUtilityFunctions clamp:glowAmount min:0 max:1];
}

- (void)setGlowMode:(KDCircularProgressGlowMode)glowMode{
    if (_glowMode == glowMode){
        return;
    }
    
    _glowMode = glowMode;
    self.progressLayer.glowMode = glowMode;
}

- (void)setProgressThickness:(CGFloat)progressThickness{
    if (_progressThickness == progressThickness){
        return;
    }
    
    _progressThickness = progressThickness;
    _progressThickness = [KDCircularProgressUtilityFunctions clamp:_progressThickness min:0 max:1];
    self.progressLayer.progressThickness = progressThickness/2;
}

- (void)setTrackThickness:(CGFloat)trackThickness{
    if (_trackThickness == trackThickness){
        return;
    }
    
    _trackThickness = trackThickness;
    _trackThickness = [KDCircularProgressUtilityFunctions clamp:_trackThickness min:0 max:1];
}

- (void)setTrackColor:(UIColor *)trackColor{
    if (_trackColor == trackColor){
        return;
    }
    
    _trackColor = trackColor;
    self.progressLayer.trackColor = trackColor;
    [self.progressLayer setNeedsDisplay];
}

- (void)setProgressColors:(NSArray *)progressColors{
    if ([_progressColors isEqualToArray:progressColors]){
        return;
    }
    
    _progressColors = [progressColors copy];
    [self updateColors:_progressColors];
}

- (NSArray *)progressColors{
    return self.progressLayer.colorsArray;
}

#pragma mark  - Animations

- (void)animateFromAngle:(NSInteger)fromAngle animateToAngle:(NSInteger)toAngle animateDuration:(NSTimeInterval)duration animateCompletion:(void (^)(BOOL completed))animationCompletion{
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

- (void)pauseAnimation{
    KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[self.progressLayer presentationLayer];
    NSInteger currentValue = presentationLayer.angle;
    [self.progressLayer removeAllAnimations];
    self.animationCompletionBlock = nil;
    _angle = currentValue;
}

- (void)stopAnimation{
    KDCircularProgressViewLayer *presentationLayer = (KDCircularProgressViewLayer *)[_progressLayer presentationLayer];
    [self.progressLayer removeAllAnimations];
    _angle = 0;
}
- (BOOL)isAnimating{
    return [self.progressLayer animationForKey:(@"angle")] != nil;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    void (^animationCompletionBlock)(BOOL) = self.animationCompletionBlock;
    if (animationCompletionBlock){
        animationCompletionBlock(flag);
        self.animationCompletionBlock = nil;
    }
}

@end
