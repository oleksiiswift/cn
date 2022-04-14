//
//  MarkSlider.h
//  ECleaner
//
//  Created by alexey sorochan on 14.04.2022.
//

#import <UIKit/UIKit.h>

@interface MarkSlider : UISlider

// スライダーline幅
@property (nonatomic) CGFloat lineWitdh;

// マーク背景色
@property (nonatomic) UIColor *markColor;

// マーク幅
@property (nonatomic) CGFloat markWidth;

// マークしたい場所の配列
// @[@0,@0.5,@1.0]
@property (nonatomic) NSArray *markPoints;

@end
