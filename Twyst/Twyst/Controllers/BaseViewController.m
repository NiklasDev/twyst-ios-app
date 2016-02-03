//
//  BaseViewController.m
//  Twyst
//
//  Created by Niklas Ahola on 3/21/14.
//  Copyright (c) 2014 Odd Couple Collabrations Inc. All rights reserved.
//

#import "BaseViewController.h"
#import "UIImage+Device.h"
#import "WrongMessageView.h"

@interface BaseViewController ()    {
    NSString *_bundleBgImage;
    BOOL _isOneImage;
}
@end

@implementation BaseViewController

- (void) viewWillAppear:(BOOL)animated  {
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated   {
    [super viewDidAppear:animated];
    [self.view endEditing:YES];
}

- (void) viewWillDisappear:(BOOL)animated   {
    [super viewWillDisappear:animated];

}

- (void) viewDidDisappear:(BOOL)animated    {
    [super viewDidDisappear:animated];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event   {
    [super touchesBegan:touches withEvent:event];
    if ([WrongMessageView checkIfShowed])   {
        [WrongMessageView hide];
    }
}

- (BOOL)prefersStatusBarHidden  {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
