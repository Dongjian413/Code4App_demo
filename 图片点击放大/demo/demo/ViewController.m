//
//  ViewController.m
//  demo
//
//  Created by 东健FO_OF on 2017/6/24.
//  Copyright © 2017年 夏东健. All rights reserved.
//

#import "ViewController.h"

#import "UIImageView+toBig.h"
#import "UIView+Metrics.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.jpg"]];
    imageView.center = self.view.center;
    [imageView canToBigImageViewWithWindow];
    
    [self.view addSubview:imageView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
