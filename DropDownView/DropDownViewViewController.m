//
//  DropDownViewViewController.m
//  DropDownView
//
//  Created by Garrett Franks on 1/6/13.
//  Copyright (c) 2013 Garrett Franks. All rights reserved.
//

#import "DropDownViewViewController.h"

@interface DropDownViewViewController ()

@end

@implementation DropDownViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self showDropDownView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showDropDownView {
    self.dropDownView = [[DropDownView alloc] initWithTitle:@"Sample"
                                          withDropDownStyle:DropDownViewStylePlainTextInput //supply style here, you can change this after initilization
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:@"OK", nil];
    
    // you may set message label or textfield placeholders here
    [[self.dropDownView messageLabel] setText:@"Sample message displayed here"];
    
    [self.dropDownView setDelegate:self];
    
    // also be sure to set a button background or one will not be used
    [self.dropDownView setButtonBackground:[UIImage imageNamed:@"map_searchhere_reset_btn"]];
    
    // set a gesture recognizer to dismiss view if DropDownView is tapped
    [self.dropDownView setGestureRecognizerForDismissal];
    
    // this is to display the DropDownView, you should pass the superview which will contain the DropDownView, here
    // you also may choose to set a timer, if timer is set to YES but a duration of ZERO is given, duration of 5 sec will be used
    // if no button titles are given and timer is not used, a timer will automatically be set with a duration of 5 sec
    [self.dropDownView showDropDownViewFromSuperview:self.view withTimer:NO forDurationOrZero:0];
    
    // or you may use
    //    [self.dropDownView show:self.view];
}

// IMPLEMENT BELOW DELEGATE METHODS

// method returns the index of which button was clicked (i.e. textfields may be nil depending on style set)
- (void)dropDownView:(DropDownView*)dropDownView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked button at index: %i", buttonIndex);
    UITextField *textField1 = [dropDownView textFieldAtIndex:0];
    UITextField *textField2 = [dropDownView textFieldAtIndex:1];
    
    if (textField1) {
        NSLog(@"Value from textfield1: %@", [textField1 text]);
    }
    
    if (textField1) {
        NSLog(@"Value from textfield2: %@", [textField2 text]);
    }
    
    [dropDownView dismiss];
}

//optional
- (void)didShowDropDownView:(DropDownView*)dropDownView {
    NSLog(@"Finished showing DropDownView");
}

//optional
// (i.e. textfields may be nil depending on style set)
- (void)didDismissDropDownView:(DropDownView*)dropDownView {
    NSLog(@"Finished hiding DropDownView");
    UITextField *textField1 = [dropDownView textFieldAtIndex:0];
    UITextField *textField2 = [dropDownView textFieldAtIndex:1];
    
    if (textField1) {
        NSLog(@"Value from textfield1: %@", [textField1 text]);
    }
    
    if (textField1) {
        NSLog(@"Value from textfield2: %@", [textField2 text]);
    }
    
    // be sure to nil out the DropDownView property declared
}

@end
