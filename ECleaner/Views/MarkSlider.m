//
//  MarkSlider.m
//  ECleaner
//
//  Created by alexey sorochan on 14.04.2022.
//

#import "MarkSlider.h"

@interface MarkSlider()

@property (nonatomic) CGFloat sideOffset;

@end

@implementation MarkSlider

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self setupDefaultSettings];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setupDefaultSettings];
	}
	return self;
}

- (void)setupDefaultSettings{
	self.markColor = [UIColor orangeColor];
	self.lineWitdh = 2.0f;
	self.markWidth = 7.0f;
	self.minimumTrackTintColor = [UIColor blueColor];
	self.maximumTrackTintColor = [UIColor lightGrayColor];
	self.sideOffset = 12.0f;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];

	CGRect innerRect = CGRectInset(rect, 1.0, 10.0);
	UIGraphicsBeginImageContextWithOptions(innerRect.size, NO, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIImage *minimumTrack = [self trackImageWithContext:&context innerRect:innerRect color:self.minimumTrackTintColor ];
	[minimumTrack drawAtPoint:CGPointMake(0,0)];
	[self addMarksOnContext:&context innerRect:innerRect];
	[self setMinimumTrackImage:[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero]
					  forState:UIControlStateNormal
	 ];

	UIImage *maximumTrack = [self trackImageWithContext:&context innerRect:innerRect color:self.maximumTrackTintColor];
	[maximumTrack drawAtPoint:CGPointMake(0,0)];
	[self addMarksOnContext:&context innerRect:innerRect];
	[self setMaximumTrackImage:[UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero]
					  forState:UIControlStateNormal
	 ];
	UIGraphicsEndImageContext();
}

/**
 *  create bar image
 */
- (UIImage *)trackImageWithContext:(CGContextRef *)context innerRect:(CGRect)innerRect color:(UIColor *)color {
	CGContextSetLineWidth(*context,_lineWitdh);
	CGContextSetLineCap(*context, kCGLineCapRound);
	CGContextMoveToPoint(*context, _sideOffset, CGRectGetHeight(innerRect)/2);
	CGContextAddLineToPoint(*context, innerRect.size.width - _sideOffset, CGRectGetHeight(innerRect)/2);
	CGContextSetStrokeColorWithColor(*context, [color CGColor]);
	CGContextStrokePath(*context);
	return [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsZero];
}

/**
 *  add marks at bar
 */
- (void)addMarksOnContext:(CGContextRef *)context innerRect:(CGRect)innerRect  {
	for (NSNumber *point in _markPoints) {
		float position = [point floatValue] * (innerRect.size.width - _sideOffset * 2) + _sideOffset;
		CGContextSetLineWidth(*context, _markWidth);
		CGContextSetLineCap(*context, kCGLineCapRound);
		CGContextMoveToPoint(*context, position, CGRectGetHeight(innerRect)/2.0f);
		CGContextAddLineToPoint(*context, position, CGRectGetHeight(innerRect)/2.0f);
		CGContextSetStrokeColorWithColor(*context, [_markColor CGColor]);
		CGContextStrokePath(*context);
	}
}

@end
