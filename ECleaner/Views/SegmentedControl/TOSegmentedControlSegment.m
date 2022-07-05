//
//  TOSegmentedControlItem.m
//
//  Copyright 2019 Timothy Oliver. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOSegmentedControlSegment.h"
#import "TOSegmentedControl.h"
#import <UIKit/UIKit.h>

// -------------------------------------------------
// Access to private properties in segmented control parent

@interface TOSegmentedControl ()
@property (nonatomic, readonly) UIView *trackView;
@property (nonatomic, readonly) UIImage *arrowImage;
@end

// -------------------------------------------------
// Private Interface

@interface TOSegmentedControlSegment ()

// Weak reference to our parent segmented control
@property (nonatomic, weak) TOSegmentedControl *segmentedControl;

// Read-write access to the item view
@property (nonatomic, strong, readwrite) UIView *itemView;

// When made reversible, the container for arrow image view to show
@property (nonatomic, strong, readwrite) UIView *arrowView;

// When made reversible, the arrow image view to show
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation TOSegmentedControlSegment

#pragma mark - Object Lifecyle -

- (instancetype)initWithObject:(id)object
           forSegmentedControl:(TOSegmentedControl *)segmentedControl
{
    if (![object isKindOfClass:NSString.class] && ![object isKindOfClass:UIImage.class]) {
        return nil;
    }
    
    if (self = [super init]) {
        if ([object isKindOfClass:NSString.class]) {
            _title = (NSString *)object;
        }
        else {
            _image = (UIImage *)object;
        }
        _segmentedControl = segmentedControl;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
          forSegmentedControl:(nonnull TOSegmentedControl *)segmentedControl
{
    if (self = [super init]) {
        _title = [title copy];
        _segmentedControl = segmentedControl;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
          forSegmentedControl:(nonnull TOSegmentedControl *)segmentedControl
{
    if (self = [super init]) {
        _image = image;
        _segmentedControl = segmentedControl;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                   reversible:(BOOL)reversible
          forSegmentedControl:(nonnull TOSegmentedControl *)segmentedControl
{
    if (self = [super init]) {
        _title = [title copy];
        _isReversible = reversible;
        _segmentedControl = segmentedControl;
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithImage:(UIImage *)image
                   reversible:(BOOL)reversible
          forSegmentedControl:(nonnull TOSegmentedControl *)segmentedControl
{
    if (self = [super init]) {
        _image = image;
        _isReversible = reversible;
        _segmentedControl = segmentedControl;
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc
{
    [self.itemView removeFromSuperview];
}

#pragma mark - Comnvenience Initializers -

+ (NSArray *)segmentsWithObjects:(NSArray *)objects forSegmentedControl:(nonnull TOSegmentedControl *)segmentedControl
{
    NSMutableArray *array = [NSMutableArray array];
    
    // Create an object for each item in the array.
    // Skip anything that isn't an image or a label
    for (id object in objects) {
        TOSegmentedControlSegment *item = nil;
        if ([object isKindOfClass:NSString.class]) {
            item = [[TOSegmentedControlSegment alloc] initWithTitle:object
                                             forSegmentedControl:segmentedControl];
        }
        else if ([object isKindOfClass:UIImage.class]) {
            item = [[TOSegmentedControlSegment alloc] initWithImage:object
                                             forSegmentedControl:segmentedControl];
        }

        if (item) { [array addObject:item]; }
    }
    
    return [NSArray arrayWithArray:array];
}

#pragma mark - Set-up -

- (void)commonInit
{    
    // Create the initial image / label view
    [self refreshItemView];
    
    // Refresh the reversible state
    [self refreshReversibleView];
}

#pragma mark - Reversible Management -

- (void)refreshReversibleView
{
    // If we're no longer (Or never were) reversible,
    // hide and exit out
    if (!self.isReversible) {
        self.arrowView.hidden = YES;
        return;
    }
    
    // Create the arrow view if we haven't done so yet
    if (self.arrowView == nil && self.arrowImageView == nil) {
        UIImage *arrow = self.segmentedControl.arrowImage;
        self.arrowView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, arrow.size}];
        self.arrowView.alpha = 0.0f;
        [self.segmentedControl.trackView addSubview:self.arrowView];

        self.arrowImageView = [[UIImageView alloc] initWithImage:arrow];
        self.arrowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.arrowView addSubview:self.arrowImageView];
    }

    // Perform these updates, but never animate them
    [UIView performWithoutAnimation:^{
        // Set the tint color
        self.arrowImageView.tintColor = self.segmentedControl.itemColor;
    }];
}

#pragma mark - View Management -

- (UILabel *)makeLabelForTitle:(NSString *)title
{
    if (title.length == 0) { return nil; }
    
    // Object is a string. Create a label
    UILabel *label = [[UILabel alloc] init];
    
    
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//    attachment.image = [UIImage imageNamed:@"MyIcon.png"];
//
//    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
//
//    NSMutableAttributedString *myString= [[NSMutableAttributedString alloc] initWithString:@"My label text"];
//    [myString appendAttributedString:attachmentString];

 //   myLabel.attributedText = myString;
    
    NSArray *stringArray = [[title componentsSeparatedByString: @";"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    
    
//    if ([[UIScreen mainScreen] bounds].size.width == 320.0) {
//
//    }
    
    NSString *text1 = stringArray[0];
    NSString *text2 = stringArray[1];
    NSString *text3 = stringArray[2];
    NSString *text4 = stringArray[3];

    CGFloat sizeHeightFirst = 20.0;
    CGFloat sizeHeightSecond = 12.0;
    CGFloat sizeHeightThird = 11.0;
  
  
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        sizeHeightFirst = 24.0;
        sizeHeightSecond = 16.0;
        sizeHeightThird = 15.0;
    }
        
    
//    if ( [ThemeManager sharedInstance].darkMode) {
//
//
//        UIFont *textFont1 = [UIFont fontWithName:@"SFProText-Bold" size:sizeHeightFirstTitle];
//        UIColor *color1 = [UIColor whiteColor];
//        NSMutableAttributedString *attributedString1 =
//        [[NSMutableAttributedString alloc] initWithString:text1 attributes:@{
//        NSFontAttributeName : textFont1, NSForegroundColorAttributeName : color1}];
//        NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle1 setAlignment:NSTextAlignmentCenter];
//        [paragraphStyle1 setLineSpacing:9];
//        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [attributedString1 length])];
//
//        if ([text2 rangeOfString:@"7"].location == 2) {
//            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//            attachment.image = [UIImage imageNamed:@"fireAdsBlack.pdf"];
//            CGFloat imageOffsetY;
//              if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//                          imageOffsetY = 0.0;
//                      } else {
//                         imageOffsetY = -2.0;
//
//                      }
//            attachment.bounds = CGRectMake(0.0, imageOffsetY, attachment.image.size.width, attachment.image.size.height + 10.0);
//            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
//            [attributedString1 appendAttributedString:attachmentString];
//
//        }
//
//        UIFont *textFont2 = [UIFont fontWithName:@"SFProText-Regular" size:sizeHeight];
//        UIColor *color2 = [UIColor whiteColor];
//        NSMutableAttributedString *attributedString2 =
//        [[NSMutableAttributedString alloc] initWithString:text2 attributes:@{
//        NSFontAttributeName : textFont2, NSForegroundColorAttributeName : color2}];
//        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle2 setAlignment:NSTextAlignmentCenter];
//        [paragraphStyle2 setLineSpacing:11];
//        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [attributedString2 length])];
//
//        [attributedString1 appendAttributedString:attributedString2];
//
//        UIFont *textFont3 = [UIFont fontWithName:@"SFProText-Bold" size:sizeHeight];
//        UIColor *color3 = [UIColor whiteColor];
//        NSMutableAttributedString *attributedString3 =
//        [[NSMutableAttributedString alloc] initWithString:text3 attributes:@{
//        NSFontAttributeName : textFont3, NSForegroundColorAttributeName : color3}];
//        NSMutableParagraphStyle *paragraphStyle3 = [[NSMutableParagraphStyle alloc] init];
//        [paragraphStyle3 setAlignment:NSTextAlignmentCenter];
//        [paragraphStyle3 setLineSpacing:1];
//        [attributedString3 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle3 range:NSMakeRange(0, [attributedString3 length])];
//
//        [attributedString1 appendAttributedString:attributedString3];
//
//
//        UIFont *textFont4 = [UIFont fontWithName:@"SFProText-Bold" size:sizeHeight];
//               UIColor *color4 = [UIColor whiteColor];
//               NSMutableAttributedString *attributedString4 =
//               [[NSMutableAttributedString alloc] initWithString:text4 attributes:@{
//               NSFontAttributeName : textFont4, NSForegroundColorAttributeName : color4}];
//               NSMutableParagraphStyle *paragraphStyle4 = [[NSMutableParagraphStyle alloc] init];
//               [paragraphStyle4 setAlignment:NSTextAlignmentCenter];
//               [paragraphStyle4 setLineSpacing:4];
//               [attributedString4 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle4 range:NSMakeRange(0, [attributedString4 length])];
//
//        [attributedString1 appendAttributedString:attributedString4];
//
//        [label setAttributedText:attributedString1];
//
//
//    } else {
  
        UIColor *textColor = [UIColor colorWithRed:13.0/255.0 green:63.0/255.0 blue:135.0/255.0 alpha:1];;
        
        UIFont *textFont1 = [UIFont systemFontOfSize:sizeHeightFirst weight: UIFontWeightBold];
        NSMutableAttributedString *attributedString1 =
        [[NSMutableAttributedString alloc] initWithString:text1 attributes:@{
        NSFontAttributeName : textFont1, NSForegroundColorAttributeName : textColor}];
        NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle1 setAlignment:NSTextAlignmentCenter];
        [paragraphStyle1 setLineSpacing:9];
        [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [attributedString1 length])];
        
        if ([text2 rangeOfString:@"7"].location == 2) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"fireAdsWhite.pdf"];
            CGFloat imageOffsetY;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                imageOffsetY = 0.0;
            } else {
               imageOffsetY = -2.0;
                
            }
            attachment.bounds = CGRectMake(0, imageOffsetY, attachment.image.size.width, attachment.image.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            [attributedString1 appendAttributedString:attachmentString];
            
        }
  
        UIFont *textFont2 = [UIFont systemFontOfSize:sizeHeightSecond weight: UIFontWeightRegular];
        NSMutableAttributedString *attributedString2 =
        [[NSMutableAttributedString alloc] initWithString:text2 attributes:@{
        NSFontAttributeName : textFont2, NSForegroundColorAttributeName : textColor}];
        NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle2 setAlignment:NSTextAlignmentCenter];
        [paragraphStyle2 setLineSpacing:11.0];
        [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [attributedString2 length])];
        
        [attributedString1 appendAttributedString:attributedString2];
        
        UIFont *textFont3 = [UIFont systemFontOfSize:sizeHeightThird weight: UIFontWeightBold];
        NSMutableAttributedString *attributedString3 =
        [[NSMutableAttributedString alloc] initWithString:text3 attributes:@{
        NSFontAttributeName : textFont3, NSForegroundColorAttributeName : textColor}];
        NSMutableParagraphStyle *paragraphStyle3 = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle3 setAlignment:NSTextAlignmentCenter];
        [paragraphStyle3 setLineSpacing:1];
        [attributedString3 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle3 range:NSMakeRange(0, [attributedString3 length])];
        
        [attributedString1 appendAttributedString:attributedString3];
        
        
        UIFont *textFont4 = [UIFont systemFontOfSize:sizeHeightThird weight: UIFontWeightBold];
               NSMutableAttributedString *attributedString4 =
               [[NSMutableAttributedString alloc] initWithString:text4 attributes:@{
               NSFontAttributeName : textFont4, NSForegroundColorAttributeName : textColor}];
               NSMutableParagraphStyle *paragraphStyle4 = [[NSMutableParagraphStyle alloc] init];
               [paragraphStyle4 setAlignment:NSTextAlignmentCenter];
               [paragraphStyle4 setLineSpacing:4];
               [attributedString4 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle4 range:NSMakeRange(0, [attributedString4 length])];
        
        [attributedString1 appendAttributedString:attributedString4];
        
        [label setAttributedText:attributedString1];
  //  }
    
    
    
    //change font name and size according to your need.
//    UIFont *text1Font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:10];
//
//    NSMutableAttributedString *attributedString1 =
//    [[NSMutableAttributedString alloc] initWithString:text1 attributes:@{
//    NSFontAttributeName : text1Font}];
//    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle1 setAlignment:NSTextAlignmentCenter];
//    [paragraphStyle1 setLineSpacing:4];
//    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [attributedString1 length])];
    
//    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//       attachment.image = [UIImage imageNamed:@"MyIcon.pdf"];
//
//       NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
//    [attributedString1 appendAttributedString:attachmentString];
    

//    UIFont *text2Font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:8];
//    NSMutableAttributedString *attributedString2 =
//    [[NSMutableAttributedString alloc] initWithString:text2 attributes:@{NSFontAttributeName : text2Font }];
//    NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle2 setLineSpacing:4];
//    [paragraphStyle2 setAlignment:NSTextAlignmentCenter];
//    [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [attributedString2 length])];

//    UIFont *text3Font = [UIFont fontWithName:@"HelveticaNeue" size:14];
//    NSMutableAttributedString *attributedString3 =
//    [[NSMutableAttributedString alloc] initWithString:text3 attributes:@{NSFontAttributeName : text3Font }];
//    NSMutableParagraphStyle *paragraphStyle3 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle3 setAlignment:NSTextAlignmentCenter];
//    [attributedString3 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle3 range:NSMakeRange(0, [attributedString3 length])];
//
//    UIFont *text4Font = [UIFont fontWithName:@"HelveticaNeue" size:14];
//    NSMutableAttributedString *attributedString4 =
//    [[NSMutableAttributedString alloc] initWithString:text4 attributes:@{NSFontAttributeName : text4Font }];
//    NSMutableParagraphStyle *paragraphStyle4 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle4 setAlignment:NSTextAlignmentCenter];
//    [attributedString4 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle4 range:NSMakeRange(0, [attributedString4 length])];

  //  [NSAttributedString appendAttributedString:attributedString2];
//    [attributedString1 appendAttributedString:attributedString3];
//    [attributedString1 appendAttributedString:attributedString4];

  //  [label setAttributedText:weekAttributedString1];
 //   [textFrame sizeToFit];
    //change frame size as per your need.
   // [textFrame setFrame:CGRectMake(10, 0, 136, 97)];
    
    
    //label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
   // label.textColor = self.segmentedControl.itemColor;
   // label.font = self.segmentedControl.selectedTextFont;
    [label sizeToFit]; // Size to the selected font
  //  label.font = self.segmentedControl.textFont;
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (UIImageView *)makeImageViewForImage:(UIImage *)image
{
    // Object is an image. Create an image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = self.segmentedControl.itemColor;
    return imageView;
}

- (void)refreshItemView
{
    // Convenience check for whether the view is a label or image
    UIImageView *imageView = self.imageView;
    UILabel *label = self.label;

    // If we didn't change the type, just update the current
    // view with the new type
    if (imageView && self.image) {
        [(UIImageView *)self.itemView setImage:self.image];
    }
    
    // If it's already a label, refresh the text
    if (label && self.title) {
        [(UILabel *)self.itemView setText:self.title];
    }
    
    // If it's an image view, but the title text is set, swap them out
    if (!label && self.title) {
        [imageView removeFromSuperview];
        imageView = nil;
        
        self.itemView = [self makeLabelForTitle:self.title];
        [self.segmentedControl.trackView addSubview:self.itemView];
        
        label = (UILabel *)self.itemView;
    }
    
    // If it's a label view, but the image is set, swap them out
    if (!imageView && self.image) {
        [label removeFromSuperview];
        label = nil;
        
        self.itemView = [self makeImageViewForImage:self.image];
        [self.segmentedControl.trackView addSubview:self.itemView];
        
        imageView = (UIImageView *)self.itemView;
    }
    
    // Update the label view
   // label.textColor = self.segmentedControl.itemColor;
    // Set the frame off the selected text as it is larger
  //  label.font = self.segmentedControl.selectedTextFont;
    [label sizeToFit];

    // Set back to default font
  //  label.font = self.segmentedControl.textFont;
    
    // Update the image view
    imageView.tintColor = self.segmentedControl.itemColor;
}

- (void)toggleDirection
{
    self.isReversed = !self.isReversed;
}

#pragma mark - Public Accessors -

- (void)setTitle:(NSString *)title
{
    // Copy text, and regenerate the view if need be
    _title = [title copy];
    _image = nil;
    [self refreshItemView];
}

- (void)setImage:(UIImage *)image
{
    if (_image == image) { return; }
    _image = image;
    _title = nil;
    [self refreshItemView];
}

- (void)setIsReversible:(BOOL)isReversible
{
    if (_isReversible == isReversible) { return; }
    _isReversible = isReversible;
    [self refreshReversibleView];
}

- (UILabel *)label
{
    if ([self.itemView isKindOfClass:UILabel.class]) {
        return (UILabel *)self.itemView;
    }
    
    return nil;
}

- (UIImageView *)imageView
{
    if ([self.itemView isKindOfClass:UIImageView.class]) {
        return (UIImageView *)self.itemView;
    }
    
    return nil;
}

- (void)setArrowImageReversed:(BOOL)reversed
{
    if (reversed) {
        self.arrowImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
        return;
    }

    self.arrowImageView.transform = CGAffineTransformIdentity;
}

@end
