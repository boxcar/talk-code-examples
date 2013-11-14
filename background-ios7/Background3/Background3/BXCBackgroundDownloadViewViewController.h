//
//  BXCBackgroundDownloadViewViewController.h
//  Background3
//
//  Created by Mickaël Rémond on 14/11/13.
//  Copyright (c) 2013 Mickaël Rémond. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BXCBackgroundDownloadViewViewController : UIViewController <NSURLSessionDelegate, NSURLSessionDownloadDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)startDownload:(id)sender;

- (void)handleBackgroundTransfer:(NSNotification*)notification;
@end
