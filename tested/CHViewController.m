//
//  CHViewController.m
//  tested
//
//  Created by Cecilia Humlelu on 04/06/14.
//  Copyright (c) 2014 Cecilia Humlelu. All rights reserved.
//

#import "CHViewController.h"
#import "ETProgressHud.h"

@interface CHViewController ()

@property ETProgressHud *etalioPath;

@end

@implementation CHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
  //  self.etalioPath = [[ETProgressHud alloc] initWithFrame:self.view.frame];
    
  //  [self.view addSubview:self.etalioPath];
    
    [ETProgressHud showWithStatus:@"Loading"];
    
    
    double delayInSeconds = 5.0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [ETProgressHud setStatus:@"this time it should change text"];
    });
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
