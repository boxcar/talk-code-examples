//
//  BXCBackgroundDownloadViewViewController.m
//  Background3
//
//  Created by Mickaël Rémond on 14/11/13.
//  Copyright (c) 2013 Mickaël Rémond. All rights reserved.
//

#import "BXCBackgroundDownloadViewViewController.h"
#import "BXCAppDelegate.h"

@interface BXCBackgroundDownloadViewViewController ()

@end

@implementation BXCBackgroundDownloadViewViewController

@synthesize resultLabel;
NSData *resumeDownload;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBackgroundTransfer:) name:@"BackgroundTransferNotification" object:nil];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// NSURLSessionDownloadDelegate:
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSData *data = [NSData dataWithContentsOfURL:location];
    NSString *result = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Received: %@", result);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultLabel.text = [NSString stringWithFormat:@"Downloaded: %@", session];
    });
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"Resumed at offset: %f / %f", (double)fileOffset, (double)expectedTotalBytes);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"%f / %f", (double)totalBytesWritten, (double)totalBytesExpectedToWrite);
}

- (IBAction)startDownload:(id)sender {
    NSLog(@"Download in background.");

    BXCAppDelegate *appDelegate = (BXCAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *videoUrl = @"http://download.wavetlan.com/SVV/Media/HTTP/H264/Other_Media/H264_test5_voice_mp4_480x360.mp4";
    if (!appDelegate.urlSession) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@" myBackgroundSessionIdentifier"];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = 10.0;
        sessionConfig.HTTPMaximumConnectionsPerHost = 1;
        appDelegate.urlSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    NSURLSessionDownloadTask *getVideo;
    if (resumeDownload) {
        getVideo = [appDelegate.urlSession downloadTaskWithResumeData:resumeDownload];
    } else {
        getVideo = [appDelegate.urlSession downloadTaskWithURL:[NSURL URLWithString:videoUrl]];
    }
    [getVideo resume];
    
    self.resultLabel.text = @"Downloading";
}

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    NSLog(@"ERROR: didBecomeInvalidWithError %@", error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"ERROR: didCompleteWithError %@", error);
    NSData *data = error.userInfo[@"NSURLSessionDownloadTaskResumeData"];
    if (data) {
        resumeDownload = data;
    }
}

// Use to keep downloading in background:
- (void)handleBackgroundTransfer:(NSNotification*)notification {
    NSLog(@"handleBackgroundTransfer");
    NSString* sessionIdentifier = notification.userInfo[@"sessionIdentifier"];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.resultLabel.text = [NSString stringWithFormat:@"Downloaded: %@", sessionIdentifier];
        void(^completionHandler)(void) = notification.userInfo[@"completionHandler"];
        if (completionHandler) {
            completionHandler();
        }
    });
}
@end
