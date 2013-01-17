//
//  MMViewController.m
//  MMFireworks
//
//  Created by Josh Berlin on 1/10/13.
//  Copyright (c) 2013 Josh Berlin. All rights reserved.
//

#import "MMViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>

#import "MMFireworksView.h"

@interface MMViewController ()
@property(nonatomic, strong) UIView *fireworksContainerView;
@property(nonatomic, strong) MMFireworksView *fireworksView;
@property(nonatomic, strong) CAEmitterLayer *mortor;
@end

@implementation MMViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.fireworksView = [[MMFireworksView alloc] initWithFrame:self.view.bounds];
  [self.view addSubview:self.fireworksView];
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootFirework:)];
  [self.view addGestureRecognizer:tapRecognizer];
}

- (void)shootFirework:(UIGestureRecognizer *)recognizer {
  [self.fireworksView launchThisManyFireworks:10];
}

@end
