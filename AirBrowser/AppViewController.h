//
//  AppViewController.h
//  BroadCast Sample
//
//  Created by Caio Lima on 02/11/12.
//  Copyright (c) 2012 Five Startup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Application.h"

@interface AppViewController : UIViewController<UIWebViewDelegate,UIScrollViewDelegate>

@property (nonatomic) Application *application;

@end
