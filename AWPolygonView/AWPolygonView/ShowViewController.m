//
//  ShowViewController.m
//  AWPolygonView
//
//  Created by alanwang on 17/5/22.
//  Copyright © 2017年 AlanWang. All rights reserved.
//

#import "ShowViewController.h"
#import "AWPolygonView.h"

#define rgb(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface ShowViewController ()
@property (nonatomic, strong) AWPolygonView *polygonView;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _polygonView = [[AWPolygonView alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    _polygonView.lineColor = rgb(229,229,229);
    _polygonView.valueLineColor = rgb(98,155,248);
    _polygonView.animationDuration = 0;
    _polygonView.valueRankNum = 4;
    _polygonView.lineWidth = 1/3;
    _polygonView.radius = 60;
    _polygonView.values = @[@(0.5),@(0.6),@(0.7),@(0.8),@(0.9)];
    [self.view addSubview:_polygonView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
