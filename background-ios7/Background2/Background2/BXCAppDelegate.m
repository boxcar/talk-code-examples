//
//  BXCAppDelegate.m
//  Background2
//
//  Created by Mickaël Rémond on 14/11/13.
//  Copyright (c) 2013 Mickaël Rémond. All rights reserved.
//

#import "BXCAppDelegate.h"

@implementation BXCAppDelegate

void (^backgroundCompletionHandler)(UIBackgroundFetchResult);

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// For background fetch:
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"Refresh data from server: Background fetch");
    
    NSString *parisWeatherUrl = @"http://api.openweathermap.org/data/2.5/weather?q=Paris,fr";
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@" myBackgroundSessionIdentifier"];
    sessionConfig.allowsCellularAccess = YES;
    sessionConfig.timeoutIntervalForRequest = 10.0;
    sessionConfig.timeoutIntervalForResource = 30.0;
    sessionConfig.HTTPMaximumConnectionsPerHost = 1;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    NSURLSessionDownloadTask *getWeatherTask = [session downloadTaskWithURL:[NSURL URLWithString:parisWeatherUrl]];
    [getWeatherTask resume];
    
    backgroundCompletionHandler = completionHandler;
}

// NSURLSessionDownloadDelegate:
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received: %@", result);
    backgroundCompletionHandler(UIBackgroundFetchResultNewData);
    [UIApplication sharedApplication].applicationIconBadgeNumber++;
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"Resumed at offset: %f / %f", (double)fileOffset, (double)expectedTotalBytes);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%f / %f", (double)totalBytesWritten, (double)totalBytesExpectedToWrite);
}

@end
