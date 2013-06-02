//
//  Application.h
//  BroadCast Sample
//
//  Created by Caio Lima on 02/11/12.
//  Copyright (c) 2012 Five Startup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Application : NSObject

@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,copy) NSString *path;
@property (nonatomic,copy) NSString *icon;

+(Application*) createFromJSON: (NSDictionary *)dic ipServer:(NSString*) ip;
@end
