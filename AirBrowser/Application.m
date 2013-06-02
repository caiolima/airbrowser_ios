//
//  Application.m
//  BroadCast Sample
//
//  Created by Caio Lima on 02/11/12.
//  Copyright (c) 2012 Five Startup. All rights reserved.
//

#import "Application.h"

@implementation Application

+(Application*) createFromJSON: (NSDictionary *)dic ipServer:(NSString*) ip{
    
    Application *app=[[Application alloc] init];
    
    [app setName:[dic objectForKey:@"name"]];
    
    NSMutableString *path=[[NSMutableString alloc] initWithString:@"http://"];
    [path appendString:ip];
    [path appendString:@"/"];
    [path appendString:[dic objectForKey:@"url"]];
    [app setPath:path];
    
    NSMutableString *icon=[[NSMutableString alloc]initWithString:path];
    [icon appendString:@"icon.png"];
    
    [app setIcon:icon];
    [app setDescription:[dic objectForKey:@"description"]];
    
    
    return app;
}

@end
