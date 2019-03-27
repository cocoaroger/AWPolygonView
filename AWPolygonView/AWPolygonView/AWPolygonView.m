//
//  AWPolygonView.m
//  AWPolygonView
//
//  Created by AlanWang on 17/3/21.
//  Copyright © 2017年 AlanWang. All rights reserved.
//

#import "AWPolygonView.h"


#define ANGLE_COS(Angle) cos(M_PI / 180 * (Angle))
#define ANGLE_SIN(Angle) sin(M_PI / 180 * (Angle))


@interface AWPolygonView ()
{
    CGFloat _centerX;
    CGFloat _centerY;
    BOOL    _toDraw;
}
@property (nonatomic, assign) NSInteger                                     sideNum; // 边数
@property (nonatomic, strong) NSArray<NSArray<NSValue *> *>                 *cornerPointArrs;
@property (nonatomic, strong) NSArray<NSValue *>                            *valuePoints;

@property (nonatomic, strong) CAShapeLayer                                  *outEdgeLineLayer; // 外圈边
@property (nonatomic, strong) CAShapeLayer                                  *lineLayer;
@property (nonatomic, strong) CAShapeLayer                                  *valueLayer;

@property (nonatomic, strong) UIBezierPath                                  *outEdgeLinePath;
@property (nonatomic, strong) UIBezierPath                                  *linePath;
@property (nonatomic, strong) UIBezierPath                                  *valuePath;


@end

@implementation AWPolygonView


- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

#pragma mark - Overwrite
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self.layer addSublayer:self.outEdgeLineLayer];
    [self.layer addSublayer:self.lineLayer];
    [self.layer addSublayer:self.valueLayer];
    
    [self drawLineFromCenter];
    [self drawValueSide];
    [self drawSide];
    
    self.linePath.lineWidth = self.lineWidth;
    self.outEdgeLinePath.lineWidth = self.lineWidth;
    
    self.outEdgeLineLayer.fillColor = [UIColor whiteColor].CGColor;
    self.outEdgeLineLayer.strokeColor = self.lineColor.CGColor;
    self.outEdgeLineLayer.path = self.outEdgeLinePath.CGPath;
    
    self.lineLayer.fillColor = [UIColor whiteColor].CGColor;
    self.lineLayer.strokeColor = [self.lineColor colorWithAlphaComponent:0.6].CGColor;
    self.lineLayer.path = self.linePath.CGPath;
    
    self.valueLayer.path = self.valuePath.CGPath;
    self.valueLayer.fillColor = [self.valueLineColor colorWithAlphaComponent:0.1].CGColor;
    self.valueLayer.strokeColor = self.valueLineColor.CGColor;
    
//    [self addStrokeEndAnimationToLayer:self.lineLayer]; // 添加动画
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.outEdgeLineLayer.frame = self.bounds;
    self.lineLayer.frame = self.bounds;
    self.valueLayer.frame = self.bounds;
}

#pragma mark - data
- (void)prepaeData {
    self.sideNum = self.values.count;
    _centerX = self.bounds.size.width/2;
    _centerY = self.bounds.size.height/2;
    
    if (self.radius == 0) {
        self.radius = self.bounds.size.width/2;
    }
    if (self.lineWidth == 0) {
        self.lineWidth = 1;
    }
    if (!self.lineColor) {
        self.lineColor = [UIColor yellowColor];
    }
    
    if (!self.valueLineColor) {
        self.valueLineColor = [UIColor colorWithRed:255.0/23.0 green:10.0 blue:10.0 alpha:0.6];
    }
    
    if (!self.valueRankNum) {
        self.valueRankNum = 3;
    }
    if (!self.animationDuration) {
        self.animationDuration = 1.35;
    }
}

- (void)makePoints {
    NSMutableArray *tempValuePoints = [NSMutableArray new];
    NSMutableArray *tempCornerPointArrs = [NSMutableArray new];
    
    //Values
    for (int i = 0; i < self.sideNum; i++) {
        if (self.values.count > i) {
            CGFloat valueRadius = [self.values[i] floatValue] * self.radius;
            CGPoint valuePoint =  CGPointMake(_centerX - ANGLE_COS(90.0 - 360.0 /self.sideNum * i) * valueRadius,
                                              _centerY - ANGLE_SIN(90.0 - 360.0 /self.sideNum * i) * valueRadius);
            [tempValuePoints addObject:[NSValue valueWithCGPoint:valuePoint]];
        }
    }
    
    // Side corners
    CGFloat rankValue = self.radius/self.valueRankNum;
    for (int j = 0; j < self.valueRankNum; j++) {
        NSMutableArray *tempCornerPoints = [NSMutableArray new];
        for (int i = 0; i < self.sideNum; i++) {
            NSInteger rank = j+1;
            CGPoint cornerPoint = CGPointMake(_centerX - ANGLE_COS(90.0 - 360.0 /self.sideNum * i) * rankValue * rank,
                                              _centerY - ANGLE_SIN(90.0 - 360.0 /self.sideNum * i) * rankValue * rank);
            [tempCornerPoints addObject:[NSValue valueWithCGPoint:cornerPoint]];
        }
        [tempCornerPointArrs addObject:[tempCornerPoints copy]];
    }

    self.cornerPointArrs = [tempCornerPointArrs copy];
    self.valuePoints = [tempValuePoints copy];
}

- (void)setValues:(NSArray *)values {
    _values = values;
    [self prepaeData];
    [self makePoints];
}

#pragma mark - draw
// 中心向最外边划线
- (void)drawLineFromCenter {
    NSArray *poins = [self.cornerPointArrs lastObject];
    for (int i = 0; i < poins.count; i++) {
        [self.linePath moveToPoint:CGPointMake(_centerX, _centerY)];
        CGPoint point = [poins[i] CGPointValue];
        [self.linePath addLineToPoint:point];
    }
}

// 值的划线
- (void)drawValueSide {
    if (self.valuePoints.count == 0) {
        return;
    }
    CGPoint firstPoint = [[self.valuePoints firstObject] CGPointValue];
    [self.valuePath moveToPoint:firstPoint];
    for (int i = 1; i < self.valuePoints.count; i++) {
        CGPoint point = [self.valuePoints[i] CGPointValue];
        [self.valuePath addLineToPoint:point];
    }
    [self.valuePath addLineToPoint:firstPoint];
}

// 每一层的边
- (void)drawSide {
    for (NSArray *points in self.cornerPointArrs) {
        if (points == self.cornerPointArrs.lastObject) {
            [self drawLineWithPoints:points path:self.outEdgeLinePath];
        } else {
            [self drawLineWithPoints:points path:self.linePath];
        }
    }
}

- (void)drawLineWithPoints:(NSArray<NSValue *> *)points path:(UIBezierPath *)path {
    if (points.count == 0) {
        return;
    }
    CGPoint firstPoint = [points.firstObject CGPointValue];
    [path moveToPoint:firstPoint];
    for (int i = 1; i < points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        [path addLineToPoint:point];
    }
    [path addLineToPoint:firstPoint];
}

#pragma mark - Action 
- (void)show {
    _toDraw = YES;
    [self setNeedsDisplay];
}

#pragma makr - Getter MEthod 
- (CAShapeLayer *)lineLayer {
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
    }
    return _lineLayer;
}

- (CAShapeLayer *)outEdgeLineLayer {
    if (!_outEdgeLineLayer) {
        _outEdgeLineLayer = [CAShapeLayer layer];
    }
    return _outEdgeLineLayer;
}

- (CAShapeLayer *)valueLayer {
    if (!_valueLayer) {
        _valueLayer = [CAShapeLayer layer];
    }
    return _valueLayer;
}

- (UIBezierPath *)outEdgeLinePath {
    if (!_outEdgeLinePath) {
        _outEdgeLinePath = [UIBezierPath bezierPath];
    }
    return _outEdgeLinePath;
}

- (UIBezierPath *)linePath {
    if (!_linePath) {
        _linePath = [UIBezierPath bezierPath];
    }
    return _linePath;
}

- (UIBezierPath *)valuePath {
    if (!_valuePath) {
        _valuePath = [UIBezierPath bezierPath];
    }
    return _valuePath;
}

#pragma mark - Animation
- (void)addStrokeEndAnimationToLayer:(CAShapeLayer *)layer {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = self.animationDuration;
    [layer addAnimation:animation forKey:@"stokeEndAnimation"];
}

@end
