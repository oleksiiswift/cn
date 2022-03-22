//
//  StepSlider.m
//  StepSlider
//


#import "StepSlider.h"

#define GENERATE_SETTER(PROPERTY, TYPE, SETTER, UPDATER) \
- (void)SETTER:(TYPE)PROPERTY { \
    if (_##PROPERTY != PROPERTY) { \
        _##PROPERTY = PROPERTY; \
        UPDATER \
        [self setNeedsLayout]; \
    } \
}

static NSString * const kTrackAnimation = @"kTrackAnimation";

typedef void (^withoutAnimationBlock)(void);
void withoutCAAnimation(withoutAnimationBlock code)
{
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    code();
    [CATransaction commit];
}

@interface StepSlider ()
{
    CAShapeLayer *_trackLayer;
    CAShapeLayer *_sliderCircleLayer;
    NSMutableArray <CAShapeLayer *> *_trackCirclesArray;
    NSMutableArray <CATextLayer *> *_trackLabelsArray;
    NSMutableDictionary <NSNumber *, UIImage *> *_trackCircleImages;

    UIImpactFeedbackGenerator* _selectFeedback;
    
    BOOL animateLayouts;
    
    CGFloat maxRadius;
    CGFloat diff;
    
    CGPoint startTouchPosition;
    CGPoint startSliderPosition;
    
    CGSize contentSize;
}

@end

@implementation StepSlider

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _index = 2;
        [self generalSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self generalSetup];
    }
    return self;
}

- (void)addLayers
{
    _dotsInteractionEnabled = YES;
    _trackCirclesArray = [[NSMutableArray alloc] init];
    _trackLabelsArray  = [[NSMutableArray alloc] init];
    _trackCircleImages = [[NSMutableDictionary alloc] init];
    
    _trackLayer = [CAShapeLayer layer];
    _sliderCircleLayer = [CAShapeLayer layer];
    _sliderCircleLayer.contentsScale = [UIScreen mainScreen].scale;
    _sliderCircleLayer.actions = @{@"contents": [NSNull null]};

    [self.layer addSublayer:_sliderCircleLayer];
    [self.layer addSublayer:_trackLayer];
    
    _labelFont = [UIFont systemFontOfSize:15.f];
    contentSize = self.bounds.size;
}

- (void)generalSetup
{
    [self addLayers];
    
    if (_maxCount == 0) {
        _maxCount = 4;
    }
    if (_trackHeight == 0.f) {
        _trackHeight = 4.f;
    }
    if (_trackCircleRadius == 0.f) {
        _trackCircleRadius = 5.f;
    }
    if (_sliderCircleRadius == 0.f) {
        _sliderCircleRadius = 12.5f;
    }
    if (_labelOffset == 0.f) {
        _labelOffset = 20.f;
    }
    if (!_trackColor) {
        _trackColor = [UIColor colorWithWhite:0.41f alpha:1.f];
    }
    if (!_sliderCircleColor) {
        _sliderCircleColor = [UIColor whiteColor];
    }
    if (!_labelColor) {
        _labelColor = [UIColor whiteColor];
    }

    [self updateMaxRadius];
    [self setNeedsLayout];
}

- (CGSize)intrinsicContentSize
{
    return contentSize;
}

#pragma mark - Draw

- (void)prepareForInterfaceBuilder
{
    [self updateMaxRadius];
    [super prepareForInterfaceBuilder];
}

- (void)layoutLayersAnimated:(BOOL)animated
{
    NSInteger indexDiff  = fabsf(roundf([self indexCalculate]) - self.index);
    BOOL left = (roundf([self indexCalculate]) - self.index) < 0;
    
    CGFloat contentWidth = self.bounds.size.width - 2 * maxRadius;
    CGFloat stepWidth    = contentWidth / (self.maxCount - 1);
    
    CGFloat sliderHeight = fmaxf(maxRadius, self.trackHeight / 2.f) * 2.f;
    CGFloat labelsHeight = [self labelHeightWithMaxWidth:stepWidth] + self.labelOffset;
    CGFloat totalHeight  = sliderHeight + labelsHeight;
    
    contentSize = CGSizeMake(fmaxf(44.f, self.bounds.size.width), fmaxf(44.f, totalHeight));
    if (!CGSizeEqualToSize(self.bounds.size, contentSize)) {
        if (self.constraints.count) {
            [self invalidateIntrinsicContentSize];
        } else {
            CGRect newFrame = self.frame;
            newFrame.size   = contentSize;
            self.frame = newFrame;
        }
    }
    
    CGFloat contentFrameY = (self.bounds.size.height - totalHeight) / 2.f;
    
    if (self.labelOrientation == StepSliderTextOrientationUp && self.labels.count) {
        contentFrameY += labelsHeight;
    }
    
    CGRect contentFrame = CGRectMake(maxRadius, contentFrameY, contentWidth, sliderHeight);
    
    CGFloat circleFrameSide = self.trackCircleRadius * 2.f;
    CGFloat sliderDiameter  = self.sliderCircleRadius * 2.f;
    
    CGPoint oldPosition = _sliderCircleLayer.position;
    
    CAShapeLayer * trackLayerCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_trackLayer]];
    
    CGPathRef oldPath   = trackLayerCopy.path;
    
    CGFloat labelsY     = self.labelOrientation ? (self.bounds.size.height - totalHeight) / 2.f : (CGRectGetMaxY(contentFrame) + self.labelOffset);
    
    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }

       
    if (self.sliderCircleImage) {
        _sliderCircleLayer.path     = NULL;
        _sliderCircleLayer.frame    = CGRectMake(0.f, 0.f, fmaxf(self.sliderCircleImage.size.width, 44.f), fmaxf(self.sliderCircleImage.size.height, 44.f));
        _sliderCircleLayer.contents = (__bridge id)self.sliderCircleImage.CGImage;
        _sliderCircleLayer.contentsGravity = kCAGravityCenter;
    } else {

        
        CGFloat sliderFrameSide = fmaxf(self.sliderCircleRadius * 2.f, 44.f);
        CGRect  sliderDrawRect  = CGRectMake((sliderFrameSide - sliderDiameter) / 2.f, (sliderFrameSide - sliderDiameter) / 2.f, sliderDiameter, sliderDiameter);
        
        _sliderCircleLayer.contents  = nil;
        _sliderCircleLayer.frame     = CGRectMake(0.f, 0.f, sliderFrameSide, sliderFrameSide);
        _sliderCircleLayer.path      = [UIBezierPath bezierPathWithRoundedRect:sliderDrawRect cornerRadius:sliderFrameSide / 2].CGPath;
        _sliderCircleLayer.fillColor = [self.sliderCircleColor CGColor];
        
        _sliderCircleLayer.strokeColor = [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:0.2f].CGColor;
        _sliderCircleLayer.lineWidth   = 1.0f;
        
        _sliderCircleLayer.shadowRadius = 1.5f;
        _sliderCircleLayer.shadowColor  = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.4f].CGColor;
        _sliderCircleLayer.shadowOffset = CGSizeMake(3.0f, 2.0f);
        _sliderCircleLayer.shadowOpacity = 0.4f;
    }
    _sliderCircleLayer.position = CGPointMake(contentFrame.origin.x + stepWidth * self.index, CGRectGetMidY(contentFrame));

    if (animated) {
        CABasicAnimation *basicSliderAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        basicSliderAnimation.duration = [CATransaction animationDuration];
        basicSliderAnimation.fromValue = [NSValue valueWithCGPoint:(oldPosition)];
        [_sliderCircleLayer addAnimation:basicSliderAnimation forKey:@"position"];
    }
    
    _trackLayer.frame = CGRectMake(contentFrame.origin.x,
                                   CGRectGetMidY(contentFrame) - self.trackHeight / 2.f,
                                   contentFrame.size.width,
                                   self.trackHeight);
    _trackLayer.path            = [self fillingPath];
    _trackLayer.backgroundColor = [self.trackColor CGColor];
    _trackLayer.fillColor       = [self.tintColor CGColor];
    
    if (animated) {
        CABasicAnimation *basicTrackAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        basicTrackAnimation.duration = [CATransaction animationDuration];
        basicTrackAnimation.fromValue = (__bridge id _Nullable)(oldPath);
        [_trackLayer addAnimation:basicTrackAnimation forKey:@"path"];
    }

    
    _trackCirclesArray = [self clearExcessLayers:_trackCirclesArray];
    
    CGFloat currentWidth = self.adjustLabel ? _trackLabelsArray.firstObject.bounds.size.width * 2 : _trackLabelsArray.firstObject.bounds.size.width;
    if ((currentWidth > 0 && currentWidth != stepWidth) || !self.labels.count) {
        [self removeLabelLayers];
    }
    
    NSTimeInterval animationTimeDiff = 0;
    if (indexDiff > 0) {
        animationTimeDiff = (left ? [CATransaction animationDuration] : -[CATransaction animationDuration]) / indexDiff;
    }
    NSTimeInterval animationTime = left ? animationTimeDiff : [CATransaction animationDuration] + animationTimeDiff;
    CGFloat circleAnimation      = circleFrameSide / _trackLayer.frame.size.width;
    
    for (NSUInteger i = 0; i < self.maxCount; i++) {
        CAShapeLayer *trackCircle;
        CATextLayer *trackLabel;
        
        if (self.labels.count) {
            trackLabel = [self textLayerWithSize:CGSizeMake([self roundForTextDrawing:stepWidth], labelsHeight - self.labelOffset) index:i];
        }
        
        if (i < _trackCirclesArray.count) {
            trackCircle = _trackCirclesArray[i];
        } else {
            trackCircle = [CAShapeLayer layer];
            trackCircle.actions = @{@"fillColor": [NSNull null],
                                    @"contents": [NSNull null]};
            
            [self.layer addSublayer:trackCircle];
            
            [_trackCirclesArray addObject:trackCircle];
        }
        
        /// hardcore move circle upper !!!!
        trackCircle.bounds   = CGRectMake(0.f, 0.f, circleFrameSide, circleFrameSide);
        trackCircle.position = CGPointMake(contentFrame.origin.x + stepWidth * i, CGRectGetMidY(contentFrame) - 0.7f);
        
        CGImageRef trackCircleImage = [self trackCircleImage:trackCircle];
        if (!trackCircleImage) {
            trackCircle.path = [UIBezierPath bezierPathWithRoundedRect:trackCircle.bounds cornerRadius:circleFrameSide / 2].CGPath;
            trackCircle.contents = nil;
        } else {
            trackCircle.path = NULL;
        }

        trackLabel.position        = CGPointMake(contentFrame.origin.x + stepWidth * i, labelsY);
        trackLabel.foregroundColor = self.labelColor.CGColor;
        
        if (animated) {
            if (trackCircleImage) {
                CGImageRef oldImage = (__bridge CGImageRef)(trackCircle.contents);
                
                if (oldImage != trackCircleImage) {
                    [self animateTrackCircleChanges:trackCircle from:(__bridge id)(oldImage) to:(__bridge id)(trackCircleImage) keyPath:@"contents" beginTime:animationTime duration:circleAnimation];
                    animationTime += animationTimeDiff;
                }
            } else {
                CGColorRef newColor = [self trackCircleColor:trackCircle];
                CGColorRef oldColor = trackCircle.fillColor;

                if (!CGColorEqualToColor(newColor, oldColor)) {
                    [self animateTrackCircleChanges:trackCircle from:(__bridge id)(oldColor) to:(__bridge id)(newColor) keyPath:@"fillColor" beginTime:animationTime duration:circleAnimation];
                    animationTime += animationTimeDiff;
                }
            }
        } else {
            if (trackCircleImage) {
                trackCircle.contents = (__bridge id _Nullable)(trackCircleImage);
            } else {
                trackCircle.fillColor = [self trackCircleColor:trackCircle];
            }
        }
        
    }
    
    if (!animated) {
        [CATransaction commit];
    }
    
    [_sliderCircleLayer removeFromSuperlayer];
    [self.layer addSublayer:_sliderCircleLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutLayersAnimated:animateLayouts];
    animateLayouts = NO;
}

#pragma mark - Helpers

- (void)animateTrackCircleChanges:(CAShapeLayer *)trackCircle from:(id)fromValue to:(id)toValue keyPath:(NSString *)keyPath beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
{
    CABasicAnimation *basicTrackCircleAnimation = [CABasicAnimation animationWithKeyPath:kTrackAnimation];
    basicTrackCircleAnimation.fillMode  = kCAFillModeBackwards;
    basicTrackCircleAnimation.beginTime = CACurrentMediaTime() + beginTime;
    basicTrackCircleAnimation.duration  = [CATransaction animationDuration] * duration;
    basicTrackCircleAnimation.keyPath   = keyPath;
    basicTrackCircleAnimation.fromValue = fromValue;
    basicTrackCircleAnimation.toValue   = toValue;

    [trackCircle addAnimation:basicTrackCircleAnimation forKey:kTrackAnimation];
    [trackCircle setValue:basicTrackCircleAnimation.toValue forKey:basicTrackCircleAnimation.keyPath];
}

- (NSMutableArray *)clearExcessLayers:(NSMutableArray *)layers
{
    if (layers.count > self.maxCount) {
        
        for (NSUInteger i = self.maxCount; i < layers.count; i++) {
            [layers[i] removeFromSuperlayer];
        }
        
        return [[layers subarrayWithRange:NSMakeRange(0, self.maxCount)] mutableCopy];
    }
    
    return layers;
}

- (CGFloat)labelHeightWithMaxWidth:(CGFloat)maxWidth
{
    if (self.labels.count) {
        CGFloat labelHeight = 0.f;
        
        for (NSUInteger i = 0; i < self.labels.count; i++) {
            CGSize size;
            if (self.adjustLabel && (i == 0 || i == self.labels.count - 1)) {
                size = CGSizeMake([self roundForTextDrawing:maxWidth / 2.f + maxRadius], CGFLOAT_MAX);
            } else {
                size = CGSizeMake([self roundForTextDrawing:maxWidth], CGFLOAT_MAX);
            }

            CGFloat height;

            if ([self.labels[i] isKindOfClass:[NSString class]]) {
                height = [self.labels[i] boundingRectWithSize:size
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName : self.labelFont}
                                                      context:nil].size.height;
            } else {
                height = [self.labels[i] boundingRectWithSize:size
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                      context:nil].size.height;
            }
            labelHeight = fmax(ceil(height), labelHeight);
        }
        return labelHeight;
    }
    
    return 0;
}

/*
 Calculate distance from trackCircle center to point where circle cross track line.
 */
- (void)updateDiff
{
    diff = sqrtf(fmaxf(0.f, powf(self.trackCircleRadius, 2.f) - pow(self.trackHeight / 2.f, 2.f)));
}

- (void)updateMaxRadius
{
    maxRadius = fmaxf(self.trackCircleRadius, self.sliderCircleRadius);
}

- (void)updateIndex
{
    NSAssert(self.maxCount > 1, @"Elements count must be greater than 1!");
    if (_index > (self.maxCount - 1)) {
        _index = self.maxCount - 1;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (CGPathRef)fillingPath
{
    CGRect fillRect     = _trackLayer.bounds;
    fillRect.size.width = self.sliderPosition;
    
    return [UIBezierPath bezierPathWithRect:fillRect].CGPath;
}

- (CGFloat)sliderPosition
{
    return _sliderCircleLayer.position.x - maxRadius;
}

- (CGFloat)trackCirclePosition:(CAShapeLayer *)trackCircle
{
    return trackCircle.position.x - maxRadius;
}

- (CGFloat)indexCalculate
{
    return self.sliderPosition / (_trackLayer.bounds.size.width / (self.maxCount - 1));
}

- (BOOL)trackCircleIsSeleceted:(CAShapeLayer *)trackCircle
{
    return self.sliderPosition + diff >= [self trackCirclePosition:trackCircle];
}

#pragma mark - Track circle

- (CGColorRef)trackCircleColor:(CAShapeLayer *)trackCircle
{
    return [self trackCircleIsSeleceted:trackCircle] ? self.tintColor.CGColor : self.trackColor.CGColor;
}

- (CGImageRef)trackCircleImage:(CAShapeLayer *)trackCircle
{
    return [self trackCircleImageForState:[self trackCircleIsSeleceted:trackCircle] ? UIControlStateSelected : UIControlStateNormal].CGImage;
}

- (void)setTrackCircleImage:(UIImage *)image forState:(UIControlState)state
{
    _trackCircleImages[@(state)] = image;
    [self setNeedsLayout];
}

- (UIImage *)trackCircleImageForState:(UIControlState)state
{
    return _trackCircleImages[@(state)] ? : _trackCircleImages[@(UIControlStateNormal)];
}

#pragma mark - Touches

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    } else {
        CGPoint position = [gestureRecognizer locationInView:self];
        return !CGRectContainsPoint(self.bounds, position);
    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    startTouchPosition = [touch locationInView:self];
    startSliderPosition = _sliderCircleLayer.position;

    if (self.enableHapticFeedback && ![[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
        _selectFeedback = [[UIImpactFeedbackGenerator alloc] init];
    }

    [_selectFeedback prepare];
    if (CGRectContainsPoint(_sliderCircleLayer.frame, startTouchPosition)) {
        return YES;
    } else if (self.isDotsInteractionEnabled) {
        for (NSUInteger i = 0; i < _trackCirclesArray.count; i++) {
            CALayer *dot = _trackCirclesArray[i];
            
            CGFloat dotRadiusDiff = 22 - self.trackCircleRadius;
            CGRect frameToCheck = dotRadiusDiff > 0 ? CGRectInset(dot.frame, -dotRadiusDiff, -dotRadiusDiff) : dot.frame;
            
            if (CGRectContainsPoint(frameToCheck, startTouchPosition)) {
                NSUInteger oldIndex = _index;
                
                _index = i;
                
                if (oldIndex != _index) {
                    [self sendActionsForControlEvents:UIControlEventValueChanged];
                    [_selectFeedback impactOccurred];
                    [_selectFeedback prepare];
                }
                animateLayouts = YES;
                [self setNeedsLayout];
                return NO;
            }
        }
        return NO;
    }
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGFloat position = startSliderPosition.x - (startTouchPosition.x - [touch locationInView:self].x);
    CGFloat limitedPosition = fminf(fmaxf(maxRadius, position), self.bounds.size.width - maxRadius);
    
    withoutCAAnimation(^{
        self->_sliderCircleLayer.position = CGPointMake(limitedPosition, self->_sliderCircleLayer.position.y);
        self->_trackLayer.path = [self fillingPath];
        
        NSUInteger index = (self.sliderPosition + self->diff) / (self->_trackLayer.bounds.size.width / (self.maxCount - 1));
        if (self->_index != index) {
            for (CAShapeLayer *trackCircle in self->_trackCirclesArray) {
                CGImageRef trackCircleImage = [self trackCircleImage:trackCircle];
                
                if (trackCircleImage) {
                    trackCircle.contents = (__bridge id _Nullable)(trackCircleImage);
                } else {
                    trackCircle.fillColor = [self trackCircleColor:trackCircle];
                }
            }
            self->_index = index;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            [self->_selectFeedback impactOccurred];
            [self->_selectFeedback prepare];
        }
    });
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self endTouches];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self endTouches];
}

- (void)endTouches
{
    NSUInteger newIndex = roundf([self indexCalculate]);
    
    if (newIndex != _index) {
        _index = newIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    animateLayouts = YES;
    [self setNeedsLayout];
    _selectFeedback = nil;
}

#pragma mark - Texts

- (CATextLayer *)textLayerWithSize:(CGSize)size index:(NSUInteger)index
{
    if (index >= _trackLabelsArray.count) {
        CATextLayer *trackLabel = [CATextLayer layer];
        
        CGPoint anchorPoint = CGPointMake(0.5f, 0.f);
        NSString *alignmentMode = kCAAlignmentCenter;
        
        if (self.adjustLabel) {
            if (index == 0) {
                alignmentMode = kCAAlignmentLeft;
                size.width = size.width / 2.f + maxRadius;
                anchorPoint.x = maxRadius / size.width;
            } else if (index == self.labels.count - 1) {
                alignmentMode = kCAAlignmentRight;
                size.width = size.width / 2.f + maxRadius;
                anchorPoint.x = 1.f - maxRadius / size.width;
            }
        }
        
        trackLabel.alignmentMode = alignmentMode;
        trackLabel.wrapped       = YES;
        trackLabel.contentsScale = [UIScreen mainScreen].scale;
        trackLabel.anchorPoint   = anchorPoint;
        
        CFStringRef fontName = (__bridge CFStringRef)self.labelFont.fontName;
        CGFontRef fontRef    = CGFontCreateWithFontName(fontName);
        
        trackLabel.font     = fontRef;
        trackLabel.fontSize = self.labelFont.pointSize;
        CGFontRelease(fontRef);
        
        trackLabel.string = self.labels[index];
        trackLabel.bounds = CGRectMake(0.f, 0.f, size.width, size.height);
        
        [self.layer addSublayer:trackLabel];
        [_trackLabelsArray addObject:trackLabel];
        
        return trackLabel;
    } else {
        return _trackLabelsArray[index];
    }
}

- (void)removeLabelLayers
{
    for (CALayer *label in _trackLabelsArray) {
        [label removeFromSuperlayer];
    }
    [_trackLabelsArray removeAllObjects];
}

- (CGFloat)roundForTextDrawing:(CGFloat)value
{
    return floor(value * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
}

#pragma mark - Access methods

- (void)setIndex:(NSUInteger)index animated:(BOOL)animated
{
    animateLayouts = animated;
    self.index = index;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self setNeedsLayout];
}

- (void)setLabels:(NSArray *)labels
{
    NSAssert(labels.count != 1, @"Labels count can not be equal to 1!");

    NSMutableArray *mLabels = [NSMutableArray arrayWithArray:labels];
    for (NSUInteger i = 0; i < labels.count; i++) {
        BOOL isAttributedString = [labels[i] isKindOfClass:[NSAttributedString class]];
        NSAssert([labels[i] isKindOfClass:[NSString class]] || isAttributedString, @"Labels must be an instance of NSString or NSAttributedString!");

        if (isAttributedString) {
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: labels[i]];
            NSRange fullRange = NSMakeRange(0, attributedString.length);

            [attributedString enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {

                if (!value) {
                    [attributedString addAttribute:NSFontAttributeName value:self.labelFont range:range];
                }
            }];
            [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:fullRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {

                if (!value) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:self.labelColor range:range];
                }
            }];

            mLabels[i] = attributedString;
        }
    }

    if (_labels != mLabels) {
        _labels = mLabels;
        
        if (_labels.count > 0) {
            _maxCount = _labels.count;
        }
        
        [self updateIndex];
        [self removeLabelLayers];
        [self setNeedsLayout];
    }
}

- (void)setMaxCount:(NSUInteger)maxCount
{
    if (_maxCount != maxCount && !self.labels.count) {
        _maxCount = maxCount;
        [self updateIndex];
        [self setNeedsLayout];
    }
}

GENERATE_SETTER(index, NSUInteger, setIndex, [self updateIndex]; [self sendActionsForControlEvents:UIControlEventValueChanged];);

GENERATE_SETTER(trackHeight, CGFloat, setTrackHeight, [self updateDiff];);
GENERATE_SETTER(trackCircleRadius, CGFloat, setTrackCircleRadius, [self updateDiff]; [self updateMaxRadius];);
GENERATE_SETTER(trackColor, UIColor*, setTrackColor, );

GENERATE_SETTER(sliderCircleRadius, CGFloat, setSliderCircleRadius, [self updateMaxRadius];);
GENERATE_SETTER(sliderCircleColor, UIColor*, setSliderCircleColor, );
GENERATE_SETTER(sliderCircleImage, UIImage*, setSliderCircleImage, );

GENERATE_SETTER(labelFont, UIFont*, setLabelFont, [self removeLabelLayers];);
GENERATE_SETTER(labelColor, UIColor*, setLabelColor, );
GENERATE_SETTER(labelOffset, CGFloat, setLabelOffset, );
GENERATE_SETTER(labelOrientation, StepSliderTextOrientation, setLabelOrientation, );
GENERATE_SETTER(adjustLabel, BOOL, setAdjustLabel, );

@end



// MARK: //// re edit slider and customized - fail
//
//static NSString * const kTrackAnimation = @"kTrackAnimation";
//
//typedef void (^withoutAnimationBlock)(void);
//void withoutCAAnimation(withoutAnimationBlock code)
//{
//    [CATransaction begin];
//    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
//    code();
//    [CATransaction commit];
//}
//
//@interface StepSlider ()
//{
//    CAShapeLayer *_trackLayer;
//    CAShapeLayer *_sliderCircleLayer;
//
//    CAShapeLayer *_segmentTrackLayer;
//    NSMutableArray <CAShapeLayer *> *_trackSegmentArray;
//
//    NSMutableArray <CAShapeLayer *> *_trackCirclesArray;
//    NSMutableArray <CATextLayer *> *_trackLabelsArray;
//    NSMutableDictionary <NSNumber *, UIImage *> *_trackCircleImages;
//
//    UIImpactFeedbackGenerator* _selectFeedback;
//
//    BOOL animateLayouts;
//
//    CGFloat maxRadius;
//    CGFloat diff;
//
//    CGPoint startTouchPosition;
//    CGPoint startSliderPosition;
//
//    CGSize contentSize;
//}
//
//@end
//
//@implementation StepSlider
//
//#pragma mark - Init
//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        _index = 2;
//        [self generalSetup];
//    }
//    return self;
//}
//
//- (instancetype)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self) {
//        [self generalSetup];
//    }
//    return self;
//}
//
//- (void)addLayers
//{
//    _dotsInteractionEnabled = YES;
//    _trackCirclesArray = [[NSMutableArray alloc] init];
//    _trackLabelsArray  = [[NSMutableArray alloc] init];
//    _trackCircleImages = [[NSMutableDictionary alloc] init];
//
//    _trackSegmentArray = [[NSMutableArray alloc] init];
//    _segmentTrackLayer = [CAShapeLayer layer];
//
//    _trackLayer = [CAShapeLayer layer];
//    _sliderCircleLayer = [CAShapeLayer layer];
//    _sliderCircleLayer.contentsScale = [UIScreen mainScreen].scale;
//    _sliderCircleLayer.actions = @{@"contents": [NSNull null]};
//
//    [self.layer addSublayer:_segmentTrackLayer];
//    [self.layer addSublayer:_sliderCircleLayer];
//    [self.layer addSublayer:_trackLayer];
//
//    _labelFont = [UIFont systemFontOfSize:15.f];
//    contentSize = self.bounds.size;
//}
//
//- (void)generalSetup
//{
//    [self addLayers];
//
//    if (_maxCount == 0) {
//        _maxCount = 4;
//    }
//    if (_trackHeight == 0.f) {
//        _trackHeight = 4.f;
//    }
//    if (_trackCircleRadius == 0.f) {
//        _trackCircleRadius = 5.f;
//    }
//    if (_sliderCircleRadius == 0.f) {
//        _sliderCircleRadius = 12.5f;
//    }
//    if (_labelOffset == 0.f) {
//        _labelOffset = 20.f;
//    }
//    if (!_trackColor) {
//        _trackColor = [UIColor colorWithWhite:0.41f alpha:1.f];
//    }
//    if (!_sliderCircleColor) {
//        _sliderCircleColor = [UIColor whiteColor];
//    }
//    if (!_labelColor) {
//        _labelColor = [UIColor whiteColor];
//    }
//
//    [self updateMaxRadius];
//    [self setNeedsLayout];
//}
//
//- (CGSize)intrinsicContentSize
//{
//    return contentSize;
//}
//
//#pragma mark - Draw
//
//- (void)prepareForInterfaceBuilder
//{
//    [self updateMaxRadius];
//    [super prepareForInterfaceBuilder];
//}
//
//- (void)layoutLayersAnimated:(BOOL)animated
//{
//    NSInteger indexDiff = fabsf(roundf([self indexCalculate]) - self.index);
//    BOOL left = (roundf([self indexCalculate]) - self.index) < 0;
//
//    CGFloat contentWidth = self.bounds.size.width - 2 * maxRadius;
//    CGFloat stepWidth    = contentWidth / (self.maxCount - 1);
//
//    CGFloat sliderHeight = fmaxf(maxRadius, self.trackHeight / 2.f) * 2.f;
//    CGFloat labelsHeight = [self labelHeightWithMaxWidth:stepWidth] + self.labelOffset;
//    CGFloat totalHeight  = sliderHeight + labelsHeight;
//
//    contentSize = CGSizeMake(fmaxf(44.f, self.bounds.size.width), fmaxf(44.f, totalHeight));
//    if (!CGSizeEqualToSize(self.bounds.size, contentSize)) {
//        if (self.constraints.count) {
//            [self invalidateIntrinsicContentSize];
//        } else {
//            CGRect newFrame = self.frame;
//            newFrame.size = contentSize;
//            self.frame = newFrame;
//        }
//    }
//
//    CGFloat contentFrameY = (self.bounds.size.height - totalHeight) / 2.f;
//
//    if (self.labelOrientation == StepSliderTextOrientationUp && self.labels.count) {
//        contentFrameY += labelsHeight;
//    }
//
//    CGRect contentFrame = CGRectMake(maxRadius, contentFrameY, contentWidth, sliderHeight);
//
//    CGFloat circleFrameSide = self.trackCircleRadius * 2.f;
//    CGFloat sliderDiameter  = self.sliderCircleRadius * 2.f;
//
////    CGPoint oldSegmentPosition = _segmentTrackLayer.position;
////    CAShapeLayer * trackSegmentLayerCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_trackLayer]];
////    CGPathRef oldSegmentPath = trackSegmentLayerCopy.path;
//
//    CGPoint oldPosition = _sliderCircleLayer.position;
//    CAShapeLayer * trackLayerCopy = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_trackLayer]];
//    CGPathRef oldPath   = trackLayerCopy.path;
//
//    CGFloat labelsY     = self.labelOrientation ? (self.bounds.size.height - totalHeight) / 2.f : (CGRectGetMaxY(contentFrame) + self.labelOffset);
//
//    if (!animated) {
//        [CATransaction begin];
//        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//    }
//
//
//    if (self.sliderCircleImage) {
//        _sliderCircleLayer.path     = NULL;
//        _sliderCircleLayer.frame    = CGRectMake(0.f, 0.f, fmaxf(self.sliderCircleImage.size.width, 44.f), fmaxf(self.sliderCircleImage.size.height, 44.f));
//        _sliderCircleLayer.contents = (__bridge id)self.sliderCircleImage.CGImage;
//        _sliderCircleLayer.contentsGravity = kCAGravityCenter;
//    } else {
//        CGFloat sliderFrameSide = fmaxf(self.sliderCircleRadius * 2.f, 44.f);
//        CGRect  sliderDrawRect  = CGRectMake((sliderFrameSide - sliderDiameter) / 2.f, (sliderFrameSide - sliderDiameter) / 2.f, sliderDiameter, sliderDiameter);
//
//        _sliderCircleLayer.contents  = nil;
//        _sliderCircleLayer.frame     = CGRectMake(0.f, 0.f, sliderFrameSide, sliderFrameSide);
//        _sliderCircleLayer.path      = [UIBezierPath bezierPathWithRoundedRect:sliderDrawRect cornerRadius:sliderFrameSide / 2].CGPath;
//        _sliderCircleLayer.fillColor = [self.sliderCircleColor CGColor];
//
//        _sliderCircleLayer.strokeColor = [UIColor colorWithRed:142.f/255.f green:142.f/255.f blue:142.f/255.f alpha:0.3f].CGColor;
//        _sliderCircleLayer.lineWidth   = 1.0f;
//
//        _sliderCircleLayer.shadowRadius = 1.5f;
//        _sliderCircleLayer.shadowColor  = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.4f].CGColor;
//        _sliderCircleLayer.shadowOffset = CGSizeMake(3.0f, 2.0f);
//        _sliderCircleLayer.shadowOpacity = 0.8f;
//
////        _segmentTrackLayer.contents = nil;
////        _segmentTrackLayer.frame = CGRectMake(10, 0.f, sliderFrameSide, 20);
////        _segmentTrackLayer.path = [UIBezierPath bezierPathWithRoundedRect:sliderDrawRect cornerRadius:10.f].CGPath;
////        _segmentTrackLayer.fillColor = [self.sliderCircleColor CGColor];
//    }
//    _sliderCircleLayer.position = CGPointMake(contentFrame.origin.x + stepWidth * self.index, CGRectGetMidY(contentFrame));
////    _segmentTrackLayer.position = CGPointMake(contentFrame.origin.x + 2 + (stepWidth - 2) * self.index, CGRectGetMidY(contentFrame));
//
//    if (animated) {
//        CABasicAnimation *basicSliderAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//        basicSliderAnimation.duration = [CATransaction animationDuration];
//        basicSliderAnimation.fromValue = [NSValue valueWithCGPoint:(oldPosition)];
//        [_sliderCircleLayer addAnimation:basicSliderAnimation forKey:@"position"];
//    }
//
//    _trackLayer.frame = CGRectMake(contentFrame.origin.x,
//                                   CGRectGetMidY(contentFrame) - self.trackHeight / 2.f,
//                                   contentFrame.size.width,
//                                   self.trackHeight);
//    _trackLayer.path            = [self fillingPath];
//    _trackLayer.backgroundColor = [self.trackColor CGColor];
//    _trackLayer.fillColor       = [self.tintColor CGColor];
//
//    if (animated) {
//        CABasicAnimation *basicTrackAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//        basicTrackAnimation.duration = [CATransaction animationDuration];
//        basicTrackAnimation.fromValue = (__bridge id _Nullable)(oldPath);
//        [_trackLayer addAnimation:basicTrackAnimation forKey:@"path"];
//    }
//
//    _trackCirclesArray = [self clearExcessLayers:_trackCirclesArray];
//    _trackSegmentArray = [self clearExcessLayers:_trackSegmentArray];
//
//    CGFloat currentWidth = self.adjustLabel ? _trackLabelsArray.firstObject.bounds.size.width * 2 : _trackLabelsArray.firstObject.bounds.size.width;
//    if ((currentWidth > 0 && currentWidth != stepWidth) || !self.labels.count) {
//        [self removeLabelLayers];
//    }
//
//    NSTimeInterval animationTimeDiff = 0;
//    if (indexDiff > 0) {
//        animationTimeDiff = (left ? [CATransaction animationDuration] : -[CATransaction animationDuration]) / indexDiff;
//    }
//    NSTimeInterval animationTime = left ? animationTimeDiff : [CATransaction animationDuration] + animationTimeDiff;
//    CGFloat circleAnimation      = circleFrameSide / _trackLayer.frame.size.width;
//
//    for (NSUInteger i = 0; i < self.maxCount; i++) {
//        CAShapeLayer *trackSegment;
//        CAShapeLayer *trackCircle;
//        CATextLayer *trackLabel;
//
//        if (self.labels.count) {
//            trackLabel = [self textLayerWithSize:CGSizeMake([self roundForTextDrawing:stepWidth], labelsHeight - self.labelOffset) index:i];
//        }
//
//        if (i < _trackCirclesArray.count) {
//            trackCircle = _trackCirclesArray[i];
//            trackSegment = _trackSegmentArray[i];
//        } else {
//            trackCircle = [CAShapeLayer layer];
//            trackCircle.actions = @{@"fillColor": [NSNull null],
//                                    @"contents": [NSNull null]};
//
//            [self.layer addSublayer:trackCircle];
//            [_trackCirclesArray addObject:trackCircle];
//
//            trackSegment = [CAShapeLayer layer];
//            trackSegment.actions = @{@"fillColor": [NSNull null],
//                                     @"contents" : [NSNull null]};
//
//            [self.layer addSublayer:trackSegment];
//            [_trackSegmentArray addObject:trackSegment];
//        }
//
//        trackCircle.bounds   = CGRectMake(0.f, 0.f, circleFrameSide, circleFrameSide);
//        trackCircle.position = CGPointMake(contentFrame.origin.x + stepWidth * i, CGRectGetMidY(contentFrame));
//
//        trackSegment.bounds = CGRectMake(0.f, 0.f, stepWidth - trackCircle.bounds.size.width * 2, circleFrameSide / 2.5);
//        trackSegment.position = CGPointMake((contentFrame.origin.x) + stepWidth * i + trackSegment.bounds.size.width / 2.4 + trackCircle.bounds.size.width, CGRectGetMidY(contentFrame));
//
//        CGImageRef trackCircleImage = [self trackCircleImage:trackCircle];
//        if (!trackCircleImage) {
//            trackCircle.path = [UIBezierPath bezierPathWithRoundedRect:trackCircle.bounds cornerRadius:circleFrameSide / 2].CGPath;
//            trackCircle.contents = nil;
//
//            trackSegment.path = [UIBezierPath bezierPathWithRoundedRect:trackSegment.bounds cornerRadius:10].CGPath;
//            trackSegment.contents =nil;
//
//        } else {
//            trackCircle.path = NULL;
//            trackSegment.path = NULL;
//        }
//
//        trackLabel.position        = CGPointMake(contentFrame.origin.x + stepWidth * i, labelsY);
//        trackLabel.foregroundColor = self.labelColor.CGColor;
//
//        if (animated) {
//            if (trackCircleImage) {
//                CGImageRef oldImage = (__bridge CGImageRef)(trackCircle.contents);
//
//                if (oldImage != trackCircleImage) {
//                    [self animateTrackCircleChanges:trackCircle from:(__bridge id)(oldImage) to:(__bridge id)(trackCircleImage) keyPath:@"contents" beginTime:animationTime duration:circleAnimation];
//                    animationTime += animationTimeDiff;
//                }
//            } else {
//                CGColorRef newColor = [self trackCircleColor:trackCircle];
//                CGColorRef oldColor = trackCircle.fillColor;
//
//                if (!CGColorEqualToColor(newColor, oldColor)) {
//                    [self animateTrackCircleChanges:trackCircle from:(__bridge id)(oldColor) to:(__bridge id)(newColor) keyPath:@"fillColor" beginTime:animationTime duration:circleAnimation];
//                    animationTime += animationTimeDiff;
//                }
//                trackSegment.fillColor = [self trackSegmentColor:trackSegment];
//            }
//        } else {
//            if (trackCircleImage) {
//                trackCircle.contents = (__bridge id _Nullable)(trackCircleImage);
//            } else {
//                trackCircle.fillColor = [self trackCircleColor:trackCircle];
//                trackSegment.fillColor = [self trackSegmentColor:trackSegment];
//            }
//        }
//
//
//        if (i == 4) {
//            trackSegment.fillColor = [UIColor clearColor].CGColor;
//        }
//    }
//
//    if (!animated) {
//        [CATransaction commit];
//    }
//
//    [_sliderCircleLayer removeFromSuperlayer];
//    [_segmentTrackLayer removeFromSuperlayer];
//    [self.layer addSublayer:_sliderCircleLayer];
//    [self.layer addSublayer:_segmentTrackLayer];
//}
//
//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    [self layoutLayersAnimated:animateLayouts];
//    animateLayouts = NO;
//}
//
//#pragma mark - Helpers
//
//- (void)animateTrackCircleChanges:(CAShapeLayer *)trackCircle from:(id)fromValue to:(id)toValue keyPath:(NSString *)keyPath beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
//{
//    CABasicAnimation *basicTrackCircleAnimation = [CABasicAnimation animationWithKeyPath:kTrackAnimation];
//    basicTrackCircleAnimation.fillMode  = kCAFillModeBackwards;
//    basicTrackCircleAnimation.beginTime = CACurrentMediaTime() + beginTime;
//    basicTrackCircleAnimation.duration  = [CATransaction animationDuration] * duration;
//    basicTrackCircleAnimation.keyPath   = keyPath;
//    basicTrackCircleAnimation.fromValue = fromValue;
//    basicTrackCircleAnimation.toValue   = toValue;
//
//    [trackCircle addAnimation:basicTrackCircleAnimation forKey:kTrackAnimation];
//    [trackCircle setValue:basicTrackCircleAnimation.toValue forKey:basicTrackCircleAnimation.keyPath];
//}
//
////- (void)animateTrackSegmentChanges:(CAShapeLayer *)trackSegment from:(id)fromValue to:(id)toValue keyPath:(NSString *)keyPath beginTime:(CFTimeInterval)beginTime duration:(CFTimeInterval)duration
////{
////    CABasicAnimation *basicTrackSegmentAnimation = [CABasicAnimation animationWithKeyPath:kTrackAnimation];
////    basicTrackSegmentAnimation.fillMode  = kCAFillModeBackwards;
////    basicTrackSegmentAnimation.beginTime = CACurrentMediaTime() + beginTime;
////    basicTrackSegmentAnimation.duration  = [CATransaction animationDuration] * duration;
////    basicTrackSegmentAnimation.keyPath   = keyPath;
////    basicTrackSegmentAnimation.fromValue = fromValue;
////    basicTrackSegmentAnimation.toValue   = toValue;
////
////    [trackSegment addAnimation:basicTrackSegmentAnimation forKey:kTrackAnimation];
////    [trackSegment setValue:basicTrackSegmentAnimation forKey:basicTrackSegmentAnimation.keyPath];
////}
//
//
//- (NSMutableArray *)clearExcessLayers:(NSMutableArray *)layers
//{
//    if (layers.count > self.maxCount) {
//
//        for (NSUInteger i = self.maxCount; i < layers.count; i++) {
//            [layers[i] removeFromSuperlayer];
//        }
//
//        return [[layers subarrayWithRange:NSMakeRange(0, self.maxCount)] mutableCopy];
//    }
//
//    return layers;
//}
//
//- (CGFloat)labelHeightWithMaxWidth:(CGFloat)maxWidth
//{
//    if (self.labels.count) {
//        CGFloat labelHeight = 0.f;
//
//        for (NSUInteger i = 0; i < self.labels.count; i++) {
//            CGSize size;
//            if (self.adjustLabel && (i == 0 || i == self.labels.count - 1)) {
//                size = CGSizeMake([self roundForTextDrawing:maxWidth / 2.f + maxRadius], CGFLOAT_MAX);
//            } else {
//                size = CGSizeMake([self roundForTextDrawing:maxWidth], CGFLOAT_MAX);
//            }
//
//            CGFloat height;
//
//            if ([self.labels[i] isKindOfClass:[NSString class]]) {
//                height = [self.labels[i] boundingRectWithSize:size
//                                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                                   attributes:@{NSFontAttributeName : self.labelFont}
//                                                      context:nil].size.height;
//            } else {
//                height = [self.labels[i] boundingRectWithSize:size
//                                                      options:NSStringDrawingUsesLineFragmentOrigin
//                                                      context:nil].size.height;
//            }
//            labelHeight = fmax(ceil(height), labelHeight);
//        }
//        return labelHeight;
//    }
//
//    return 0;
//}
//
///*
// Calculate distance from trackCircle center to point where circle cross track line.
// */
//- (void)updateDiff
//{
//    diff = sqrtf(fmaxf(0.f, powf(self.trackCircleRadius, 2.f) - pow(self.trackHeight / 2.f, 2.f)));
//}
//
//- (void)updateMaxRadius
//{
//    maxRadius = fmaxf(self.trackCircleRadius, self.sliderCircleRadius);
//}
//
//- (void)updateIndex
//{
//    NSAssert(self.maxCount > 1, @"Elements count must be greater than 1!");
//    if (_index > (self.maxCount - 1)) {
//        _index = self.maxCount - 1;
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
//    }
//}
//
//- (CGPathRef)fillingPath
//{
//    CGRect fillRect     = _trackLayer.bounds;
//    fillRect.size.width = self.sliderPosition;
//    return [UIBezierPath bezierPathWithRect:fillRect].CGPath;
//}
//
//- (CGPathRef)fillSegmentPath
//{
//    NSInteger currentIntex = (NSInteger) (floor(self.indexCalculate));
//    CGRect _trackSegment = _trackSegmentArray[currentIntex].bounds;
//    CGFloat _circleFrameSide = self.trackCircleRadius * 2.f;
//
//    CGFloat _contentWidth = self.bounds.size.width - 2 * maxRadius;
//    CGFloat _stepWidth = _contentWidth / (self.maxCount - 1);
//    CGFloat _sliderHeight = fmaxf(maxRadius, self.trackHeight / 2.f) * 2.f;
//    CGFloat _labelsHeight = [self labelHeightWithMaxWidth:_stepWidth] + self.labelOffset;
//    CGFloat _totalHeigh = _sliderHeight + _labelsHeight;
//    CGFloat _contentFrameY = (self.bounds.size.height - _totalHeigh) / 2.f;
//    CGRect _contentFrame = CGRectMake(maxRadius, _contentFrameY, _contentWidth, _sliderHeight);
//
//    CGPoint _startingSegmentPoint = CGPointMake((_contentFrame.origin.x) + _stepWidth * _index + _trackSegment.size.width / 1.2 + _circleFrameSide, CGRectGetMidY(_contentFrame));
//
////    NSLog(@"_startingSegmentPoint :: %@", _startingSegmentPoint);
//
//    CGRect fillSegmentRect = _segmentTrackLayer.bounds;
//    fillSegmentRect.size.width = abs(self.sliderPosition - _startingSegmentPoint.x);
//    return [UIBezierPath bezierPathWithRect:fillSegmentRect].CGPath;
//
//
////    CGFloat contentWidth = self.bounds.size.width - 2 * maxRadius;
//    //    CGFloat calculatePosition = self.sliderPosition
//    //    fillSegmentRect.size.width = self.sliderPosition - contentWidth + stepWidth * currentIntex - 10;
//    //        trackSegment.position = CGPointMake((contentFrame.origin.x) + stepWidth * i + trackSegment.bounds.size.width / 2 + trackCircle.bounds.size.width,
//
//    //        CGFloat circleFrameSide = self.trackCircleRadius * 2.f;
//    //        trackCircle.bounds   = CGRectMake(0.f, 0.f, circleFrameSide, circleFrameSide);
//    //    CGRect fillSegmentRect = _segmentTrackLayer.bounds;
//    //    fillSegmentRect.size.width = self.sliderPosition;
//
////    _trackSegmentArray[currentIntex].path = [UIBezierPath bezierPathWithRect:fillSegmentRect].CGPath;
//}
////GPointMake((contentFrame.origin.x) + stepWidth * i + trackSegment.bounds.size.width / 2 + trackCircle.bounds.size.width, CGRectGetMidY(contentFrame));
//
//
//
//
//- (CGFloat)sliderPosition
//{
//    return _sliderCircleLayer.position.x - maxRadius;
//}
//
//- (CGFloat)trackCirclePosition:(CAShapeLayer *)trackCircle
//{
//    return trackCircle.position.x - maxRadius;
//}
//
//- (CGFloat)indexCalculate
//{
//    return self.sliderPosition / (_trackLayer.bounds.size.width / (self.maxCount - 1));
//}
//
//- (BOOL)trackCircleIsSeleceted:(CAShapeLayer *)trackCircle
//{
//    return self.sliderPosition + diff >= [self trackCirclePosition:trackCircle];
//}
//
//-(BOOL)trackSegmentIsSelected:(CAShapeLayer *)trackSegment
//{
//    return self.sliderPosition >= [self trackCirclePosition:trackSegment];
//}
//
//
////-(BOOL)trackSegmentIsSelected:(CAShapeLayer *)trackSegment
////{
////    return self.sliderPosition + diff >= [self trackCirclePosition:trackSegment];
////}
//
//#pragma mark - Track circle
//
///// tracking color
//- (CGColorRef)trackCircleColor:(CAShapeLayer *)trackCircle
//{
//    return [self trackCircleIsSeleceted:trackCircle] ? [UIColor colorWithRed:10.f/255 green:176.f/255.f blue:214.f/255.f alpha:1.f].CGColor : [UIColor colorWithRed:214.f/255.f green:217.f/255 blue:219.f/255 alpha:1.f].CGColor;
//}
//
//- (CGColorRef)trackSegmentColor:(CAShapeLayer *)trackSegment
//{
//    return  [self trackSegmentIsSelected:trackSegment] ? [UIColor colorWithRed:10.f/255 green:176.f/255.f blue:214.f/255.f alpha:1.f].CGColor : [UIColor colorWithRed:214.f/255.f green:217.f/255 blue:219.f/255 alpha:1.f].CGColor;
//}
//
//- (CGImageRef)trackCircleImage:(CAShapeLayer *)trackCircle
//{
//    return [self trackCircleImageForState:[self trackCircleIsSeleceted:trackCircle] ? UIControlStateSelected : UIControlStateNormal].CGImage;
//}
//
//- (void)setTrackCircleImage:(UIImage *)image forState:(UIControlState)state
//{
//    _trackCircleImages[@(state)] = image;
//    [self setNeedsLayout];
//}
//
//- (UIImage *)trackCircleImageForState:(UIControlState)state
//{
//    return _trackCircleImages[@(state)] ? : _trackCircleImages[@(UIControlStateNormal)];
//}
//
//#pragma mark - Touches
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//        return NO;
//    } else {
//        CGPoint position = [gestureRecognizer locationInView:self];
//        return !CGRectContainsPoint(self.bounds, position);
//    }
//}
//
//- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    startTouchPosition = [touch locationInView:self];
//    startSliderPosition = _sliderCircleLayer.position;
//
//    if (self.enableHapticFeedback && ![[NSProcessInfo processInfo] isLowPowerModeEnabled]) {
//        _selectFeedback = [[UIImpactFeedbackGenerator alloc] init];
//    }
//
//    [_selectFeedback prepare];
//    if (CGRectContainsPoint(_sliderCircleLayer.frame, startTouchPosition)) {
//        return YES;
//    } else if (self.isDotsInteractionEnabled) {
//        for (NSUInteger i = 0; i < _trackCirclesArray.count; i++) {
//            CALayer *dot = _trackCirclesArray[i];
//
//            CGFloat dotRadiusDiff = 22 - self.trackCircleRadius;
//            CGRect frameToCheck = dotRadiusDiff > 0 ? CGRectInset(dot.frame, -dotRadiusDiff, -dotRadiusDiff) : dot.frame;
//
//            if (CGRectContainsPoint(frameToCheck, startTouchPosition)) {
//                NSUInteger oldIndex = _index;
//
//                _index = i;
//
//                if (oldIndex != _index) {
//                    [self sendActionsForControlEvents:UIControlEventValueChanged];
//                    [_selectFeedback impactOccurred];
//                    [_selectFeedback prepare];
//                }
//                animateLayouts = YES;
//                [self setNeedsLayout];
//                return NO;
//            }
//        }
//        return NO;
//    }
//    return NO;
//}
//
//- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    CGFloat position = startSliderPosition.x - (startTouchPosition.x - [touch locationInView:self].x);
//    CGFloat limitedPosition = fminf(fmaxf(maxRadius, position), self.bounds.size.width - maxRadius);
//
//    withoutCAAnimation(^{
//        self->_sliderCircleLayer.position = CGPointMake(limitedPosition, self->_sliderCircleLayer.position.y);
//        self->_trackLayer.path = [self fillingPath];
////        self->_segmentTrackLayer.path = [self fillSegmentPath];
//
//
////        self->_trackSegmentArray[self->_index].path = [self fillingPath];
////        self->_trackSegmentArray[self->_index].fillColor = [self trackSegmentColor:self->_trackSegmentArray[self->_index]];
//
////        self->_segmentTrackLayer.fillColor = [UIColor redColor].CGColor;
////        self->_trackSegmentArray[self->_index].path = [self fillSegmentPath];
////        self->_trackSegmentArray[self->_index].fillColor = [self fillSegmentPath];
//
////        trackSegment.path = [UIBezierPath bezierPathWithRoundedRect:trackSegment.bounds cornerRadius:10].CGPath;
////        self->_segmentTrackLayer.fillColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.4f].CGColor;
////        self->_segmentTrackLayer.strokeColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.4f].CGColor;
////        self->_trackSegmentArray[self->_index].fillColor = [UIColor colorWithRed:0.f/255.f green:0.f/255.f blue:0.f/255.f alpha:0.4f].CGColor;
//
//        NSUInteger index = (self.sliderPosition + self->diff) / (self->_trackLayer.bounds.size.width / (self.maxCount - 1));
//        if (self->_index != index) {
//
//            for (CAShapeLayer *trackCircle in self->_trackCirclesArray) {
//                CGImageRef trackCircleImage = [self trackCircleImage:trackCircle];
//
//                if (trackCircleImage) {
//                    trackCircle.contents = (__bridge id _Nullable)(trackCircleImage);
//                } else {
//                    trackCircle.fillColor = [self trackCircleColor:trackCircle];
//                }
//            }
//
//            int i = 0;
//
//            for (CAShapeLayer *trackSegment in self->_trackSegmentArray) {
//                i++;
//                if (i != 5) {
//                    trackSegment.fillColor = [self trackSegmentColor:trackSegment];
//                } else {
//                    trackSegment.fillColor = [UIColor clearColor].CGColor;
//                }
//            }
//
//            self->_index = index;
//            [self sendActionsForControlEvents:UIControlEventValueChanged];
//            [self->_selectFeedback impactOccurred];
//            [self->_selectFeedback prepare];
//        }
//    });
//
//    return YES;
//}
//
//- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
//{
//    [self endTouches];
//}
//
//- (void)cancelTrackingWithEvent:(UIEvent *)event
//{
//    [self endTouches];
//}
//
//- (void)endTouches
//{
//    NSUInteger newIndex = roundf([self indexCalculate]);
//
//    if (newIndex != _index) {
//        _index = newIndex;
//        [self sendActionsForControlEvents:UIControlEventValueChanged];
//    }
//
//    animateLayouts = YES;
//    [self setNeedsLayout];
//    _selectFeedback = nil;
//}
//
//#pragma mark - Texts
//
//- (CATextLayer *)textLayerWithSize:(CGSize)size index:(NSUInteger)index
//{
//    if (index >= _trackLabelsArray.count) {
//        CATextLayer *trackLabel = [CATextLayer layer];
//
//        CGPoint anchorPoint = CGPointMake(0.5f, 0.f);
//        NSString *alignmentMode = kCAAlignmentCenter;
//
//        if (self.adjustLabel) {
//            if (index == 0) {
//                alignmentMode = kCAAlignmentLeft;
//                size.width = size.width / 2.f + maxRadius;
//                anchorPoint.x = maxRadius / size.width;
//            } else if (index == self.labels.count - 1) {
//                alignmentMode = kCAAlignmentRight;
//                size.width = size.width / 2.f + maxRadius;
//                anchorPoint.x = 1.f - maxRadius / size.width;
//            }
//        }
//
//        trackLabel.alignmentMode = alignmentMode;
//        trackLabel.wrapped       = YES;
//        trackLabel.contentsScale = [UIScreen mainScreen].scale;
//        trackLabel.anchorPoint   = anchorPoint;
//
//        CFStringRef fontName = (__bridge CFStringRef)self.labelFont.fontName;
//        CGFontRef fontRef    = CGFontCreateWithFontName(fontName);
//
//        trackLabel.font     = fontRef;
//        trackLabel.fontSize = self.labelFont.pointSize;
//        CGFontRelease(fontRef);
//
//        trackLabel.string = self.labels[index];
//        trackLabel.bounds = CGRectMake(0.f, 0.f, size.width, size.height);
//
//        [self.layer addSublayer:trackLabel];
//        [_trackLabelsArray addObject:trackLabel];
//
//        return trackLabel;
//    } else {
//        return _trackLabelsArray[index];
//    }
//}
//
//- (void)removeLabelLayers
//{
//    for (CALayer *label in _trackLabelsArray) {
//        [label removeFromSuperlayer];
//    }
//    [_trackLabelsArray removeAllObjects];
//}
//
//- (CGFloat)roundForTextDrawing:(CGFloat)value
//{
//    return floor(value * [UIScreen mainScreen].scale) / [UIScreen mainScreen].scale;
//}
//
//#pragma mark - Access methods
//
//- (void)setIndex:(NSUInteger)index animated:(BOOL)animated
//{
//    animateLayouts = animated;
//    self.index = index;
//}
//
//- (void)setTintColor:(UIColor *)tintColor
//{
//    [super setTintColor:tintColor];
//    [self setNeedsLayout];
//}
//
//- (void)setLabels:(NSArray *)labels
//{
//    NSAssert(labels.count != 1, @"Labels count can not be equal to 1!");
//
//    NSMutableArray *mLabels = [NSMutableArray arrayWithArray:labels];
//    for (NSUInteger i = 0; i < labels.count; i++) {
//        BOOL isAttributedString = [labels[i] isKindOfClass:[NSAttributedString class]];
//        NSAssert([labels[i] isKindOfClass:[NSString class]] || isAttributedString, @"Labels must be an instance of NSString or NSAttributedString!");
//
//        if (isAttributedString) {
//            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString: labels[i]];
//            NSRange fullRange = NSMakeRange(0, attributedString.length);
//
//            [attributedString enumerateAttribute:NSFontAttributeName inRange:fullRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//
//                if (!value) {
//                    [attributedString addAttribute:NSFontAttributeName value:self.labelFont range:range];
//                }
//            }];
//            [attributedString enumerateAttribute:NSForegroundColorAttributeName inRange:fullRange options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
//
//                if (!value) {
//                    [attributedString addAttribute:NSForegroundColorAttributeName value:self.labelColor range:range];
//                }
//            }];
//
//            mLabels[i] = attributedString;
//        }
//    }
//
//    if (_labels != mLabels) {
//        _labels = mLabels;
//
//        if (_labels.count > 0) {
//            _maxCount = _labels.count;
//        }
//
//        [self updateIndex];
//        [self removeLabelLayers];
//        [self setNeedsLayout];
//    }
//}
//
//- (void)setMaxCount:(NSUInteger)maxCount
//{
//    if (_maxCount != maxCount && !self.labels.count) {
//        _maxCount = maxCount;
//        [self updateIndex];
//        [self setNeedsLayout];
//    }
//}
//
//GENERATE_SETTER(index, NSUInteger, setIndex, [self updateIndex]; [self sendActionsForControlEvents:UIControlEventValueChanged];);
//
//GENERATE_SETTER(trackHeight, CGFloat, setTrackHeight, [self updateDiff];);
//GENERATE_SETTER(trackCircleRadius, CGFloat, setTrackCircleRadius, [self updateDiff]; [self updateMaxRadius];);
//GENERATE_SETTER(trackColor, UIColor*, setTrackColor, );
//
//GENERATE_SETTER(sliderCircleRadius, CGFloat, setSliderCircleRadius, [self updateMaxRadius];);
//GENERATE_SETTER(sliderCircleColor, UIColor*, setSliderCircleColor, );
//GENERATE_SETTER(sliderCircleImage, UIImage*, setSliderCircleImage, );
//
//GENERATE_SETTER(labelFont, UIFont*, setLabelFont, [self removeLabelLayers];);
//GENERATE_SETTER(labelColor, UIColor*, setLabelColor, );
//GENERATE_SETTER(labelOffset, CGFloat, setLabelOffset, );
//GENERATE_SETTER(labelOrientation, StepSliderTextOrientation, setLabelOrientation, );
//GENERATE_SETTER(adjustLabel, BOOL, setAdjustLabel, );
//
//@end