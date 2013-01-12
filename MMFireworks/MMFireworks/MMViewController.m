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
#import "MMMortorLayer.h"

@interface MMViewController ()
@property(nonatomic, strong) UIView *fireworksContainerView;
@property(nonatomic, strong) MMMortorLayer *mortorLayer;
@property(nonatomic, strong) MMFireworksView *fireworksView;
@property(nonatomic, strong) CAEmitterLayer *mortor;
@end

@implementation MMViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.fireworksView = [[MMFireworksView alloc] initWithFrame:self.view.bounds];
  self.fireworksView.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.fireworksView];
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootFirework:)];
  [self.view addGestureRecognizer:tapRecognizer];
  
  /*
  
  self.fireworksContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
  self.fireworksContainerView.backgroundColor = [UIColor greenColor];
  [self.view addSubview:self.fireworksContainerView];
  
  UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shootFirework:)];
  [self.view addGestureRecognizer:tapRecognizer];
  
  // Create the root layer
	CALayer *rootLayer = [CALayer layer];
  rootLayer.bounds = CGRectMake(0, 0, 1024, 768);
  rootLayer.backgroundColor = [UIColor blackColor].CGColor;
  
  self.mortor = [CAEmitterLayer layer];
  self.mortor.bounds = self.view.bounds;
  self.mortor.backgroundColor = [UIColor blackColor].CGColor;
  self.mortor.anchorPoint = CGPointMake(0, 0);
    
	// Set the view's layer to the base layer
//  [rootLayer addSublayer:self.mortor];
  [self.fireworksContainerView.layer addSublayer:self.mortor];
   */
}

- (void)shootFirework:(UIGestureRecognizer *)recognizer {
  [self.fireworksView launchThisManyFireworks:10];
  
//  [self shootFireworkToPoint:[recognizer locationInView:self.fireworksContainerView]];
}

- (void)shootFireworkToPoint:(CGPoint)point {
  CGPoint originalPoint = CGPointMake(CGRectGetMidX(self.fireworksContainerView.bounds),
                                      CGRectGetMaxY(self.fireworksContainerView.bounds));
    
//  CGPoint newOriginPoint = CGPointMake(originalPoint.x - originalPoint.x/2, originalPoint.y - originalPoint.y/2);
  
//  CGPoint position = CGPointMake(originalPoint.x + point.x, originalPoint.y + point.y);
  CGPoint position = CGPointMake(originalPoint.x, originalPoint.y);
  
  UIImage *image = [UIImage imageNamed:@"tspark.png"];

  self.mortor.emitterPosition = position;
//	self.mortor.renderMode = kCAEmitterLayerBackToFront;
	self.mortor.renderMode = kCAEmitterLayerAdditive;
	
	//Invisible particle representing the rocket before the explosion
	CAEmitterCell *rocket = [CAEmitterCell emitterCell];
	rocket.emissionLongitude = (3 * M_PI) / 2;
	rocket.emissionLatitude = 0;
	rocket.lifetime = 1.6;
	rocket.birthRate = 10;
	rocket.velocity = 200;
	rocket.velocityRange = 100;
	rocket.yAcceleration = -250;
	rocket.emissionRange = M_PI / 4;
	rocket.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
	rocket.redRange = 0.5;
	rocket.greenRange = 0.5;
	rocket.blueRange = 0.5;
	
	//Name the cell so that it can be animated later using keypath
	[rocket setName:@"rocket"];
	
	//Flare particles emitted from the rocket as it flys
	CAEmitterCell *flare = [CAEmitterCell emitterCell];
	flare.contents = (id)image.CGImage;
	flare.emissionLongitude = (4 * M_PI) / 2;
	flare.scale = 0.4;
	flare.velocity = 100;
	flare.birthRate = 45;
	flare.lifetime = 1.5;
	flare.yAcceleration = -350;
	flare.emissionRange = M_PI / 7;
	flare.alphaSpeed = -0.7;
	flare.scaleSpeed = -0.1;
	flare.scaleRange = 0.1;
	flare.beginTime = 0.01;
	flare.duration = 0.7;
	
	//The particles that make up the explosion
	CAEmitterCell *firework = [CAEmitterCell emitterCell];
	firework.contents = (id)image.CGImage;
	firework.birthRate = 9999;
	firework.scale = 0.6;
	firework.velocity = 130;
	firework.lifetime = 2;
	firework.alphaSpeed = -0.2;
	firework.yAcceleration = -80;
	firework.beginTime = 1.5;
	firework.duration = 0.1;
	firework.emissionRange = 2 * M_PI;
	firework.scaleSpeed = -0.1;
	firework.spin = 2;
	
	//Name the cell so that it can be animated later using keypath
	[firework setName:@"firework"];
	
	//preSpark is an invisible particle used to later emit the spark
	CAEmitterCell *preSpark = [CAEmitterCell emitterCell];
	preSpark.birthRate = 80;
	preSpark.velocity = firework.velocity * 0.70;
	preSpark.lifetime = 1.7;
	preSpark.yAcceleration = firework.yAcceleration * 0.85;
	preSpark.beginTime = firework.beginTime - 0.2;
	preSpark.emissionRange = firework.emissionRange;
	preSpark.greenSpeed = 100;
	preSpark.blueSpeed = 100;
	preSpark.redSpeed = 100;
	
	//Name the cell so that it can be animated later using keypath
	[preSpark setName:@"preSpark"];
	
	//The 'sparkle' at the end of a firework
	CAEmitterCell *spark = [CAEmitterCell emitterCell];
	spark.contents = (id)image.CGImage;
	spark.lifetime = 0.05;
	spark.yAcceleration = -250;
	spark.beginTime = 0.8;
	spark.scale = 0.4;
	spark.birthRate = 10;

	preSpark.emitterCells = [NSArray arrayWithObjects:spark, nil];
	rocket.emitterCells = [NSArray arrayWithObjects:flare, firework, preSpark, nil];
	self.mortor.emitterCells = [NSArray arrayWithObjects:rocket, nil];
  
  [self.fireworksContainerView setNeedsDisplay];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
