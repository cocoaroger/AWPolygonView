//
//  AWPolygonView.h
//  AWPolygonView
//
//  Created by AlanWang on 17/3/21.
//  Copyright © 2017年 AlanWang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AWPolygonView : UIView

@property (nonatomic, strong) NSArray               *values; // 数据值
@property (nonatomic, strong) UIColor               *lineColor; // 线的颜色
@property (nonatomic, strong) UIColor               *valueLineColor; // 数据值的线的颜色，填充为该颜色0.1透明
@property (nonatomic, assign) CGFloat               radius; // 半径
@property (assign, nonatomic) CGFloat               lineWidth; // 线宽,默认1
@property (nonatomic, assign) NSInteger             valueRankNum; // 分隔块
@property (nonatomic, assign) NSTimeInterval        animationDuration; // 动画时间

- (void)show;


@end
