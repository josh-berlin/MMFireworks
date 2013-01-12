//
//  MMFireworksView.h
//  Fireworks
//
//  Created by Josh Berlin on 1/11/13.
//
//

#import <UIKit/UIKit.h>

@interface MMFireworksView : UIView

- (void)beginShootingFireworks;
- (void)stopShootingFireworks;
- (void)launchThisManyFireworks:(NSInteger)numberOfFireworks;

@end
