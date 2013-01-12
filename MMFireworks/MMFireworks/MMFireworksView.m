//
//  MMFireworksView.m
//  Fireworks
//
//  Created by Josh Berlin on 1/11/13.
//
//

#import "MMFireworksView.h"

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CoreAnimation.h>

// Changing this value will alter the variation of the angle when launching the firework.
// Higher values will have a wider range of launch angle variation.
// Reccomended values: 0-8
#define kRocketEmissionRangeVariation 8.0f

// Changing this value will alter the speed of the rocket launch.
// Higher values will have a faster speed. The rocket will also travel further.
// Recommended values 0-500
#define kRocketLaunchVelocity 200.0f

// This value defines the amount of potential variation of the velocity of each rocket.
// Higher values will increase the amount of variation each rocket travels.
// Recommended values 0-500
#define kRocketLaunchVelocityRange 100.0f

// Changing this value will alter the size of the explosion.
// Higher values will have a larger explosion.
// Reccomended values 0-500
#define kFireworkExplosionVelocity 150.0f

// This value defines the amount of potential variation of the size of each explosion.
// Higher values will increase the amount of variation of each explosion.
// Recommended 0-500
#define kFireworkExplosionVelocityRange 0.0f

#define kDurationOfRocketLaunch 1.6f

@interface MMFireworksView ()
@property(nonatomic, strong) CAEmitterLayer *mortor;
@property(nonatomic, strong) CAEmitterCell *rocket;
@end

@implementation MMFireworksView

//+ (Class)layerClass {
//  return [MMMortorLayer class];
//}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.mortor = [CAEmitterLayer layer];
    [self.layer addSublayer:self.mortor];
    
    [self setUpFireworks];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.mortor.bounds = self.bounds;
}

- (void)beginShootingFireworks {
  self.mortor.birthRate = 1;
  [self setNeedsDisplay];
}

- (void)stopShootingFireworks {
  self.mortor.birthRate = 0;
}

- (void)launchThisManyFireworks:(NSInteger)numberOfFireworks {
  self.mortor.birthRate = 1;
  self.rocket.birthRate = numberOfFireworks;
  int64_t delayInSeconds = kDurationOfRocketLaunch;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    self.mortor.birthRate = 0;
  });
}

- (void)setUpFireworks {
  self.mortor.birthRate = 0;
  
  self.mortor.backgroundColor = [UIColor blackColor].CGColor;
  self.mortor.anchorPoint = CGPointMake(0, 0);
  
  UIImage *image = [UIImage imageNamed:@"tspark.png"];
  
  self.mortor.emitterPosition = CGPointMake(CGRectGetMidX(self.bounds),
                                            CGRectGetMaxY(self.bounds));
//self.mortor.renderMode = kCAEmitterLayerBackToFront;
	self.mortor.renderMode = kCAEmitterLayerAdditive;
	
	//Invisible particle representing the rocket before the explosion
	self.rocket = [CAEmitterCell emitterCell];
	self.rocket.emissionLongitude = (3 * M_PI) / 2;
	self.rocket.emissionLatitude = 0;
	self.rocket.lifetime = kDurationOfRocketLaunch;
	self.rocket.birthRate = 1;
	self.rocket.velocity = kRocketLaunchVelocity;
	self.rocket.velocityRange = kRocketLaunchVelocityRange;
	self.rocket.yAcceleration = -250;
	self.rocket.emissionRange = kRocketEmissionRangeVariation * M_PI / 4;
	self.rocket.color = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5].CGColor;
	self.rocket.redRange = 0.5;
	self.rocket.greenRange = 0.5;
	self.rocket.blueRange = 0.5;
	
	//Name the cell so that it can be animated later using keypath
	[self.rocket setName:@"rocket"];
	
	//Flare particles emitted from the rocket as it flys
	CAEmitterCell *flare = [CAEmitterCell emitterCell];
	flare.contents = (id)image.CGImage;
	flare.emissionLongitude = (4 * M_PI) / 2;
	flare.scale = 0.4;
	flare.velocity = 100;
	flare.birthRate = 45;
	flare.lifetime = kDurationOfRocketLaunch - 0.1f;
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
	firework.velocity = kFireworkExplosionVelocity;
  firework.velocityRange = kFireworkExplosionVelocityRange;
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
	self.rocket.emitterCells = [NSArray arrayWithObjects:flare, firework, preSpark, nil];
	self.mortor.emitterCells = [NSArray arrayWithObjects:self.rocket, nil];
  
  [self setNeedsDisplay];
}

@end
