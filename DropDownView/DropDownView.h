//
//  DropDownView.h
//
//  Created by Garrett Franks on 1/3/13.
//  Copyright (c) 2013 Garrett Franks. All rights reserved.
//
//

/*
 *************************** WHEN IMPLEMENTING, FOLOW THIS EXAMPLE *********************************
 
 // SUPPLE METHOD TO CREATE DropDownView, BE SURE TO IMPORT THIS CLASS AND SET AS DELEGATE IN HEADER FILE
 
 //declare DropDownView in header class as a property and synthesize (must be allocated for as long as view is shown to prevent EXC_BAD_ACCESS!)
 @property (strong, nonatomic) DropDownView *dropDownView;
 
 - (void)showDropDownView {
     self.dropDownView = [[DropDownView alloc] initWithTitle:@"Sample"
                                           withDropDownStyle:DropDownViewStyleDefault //supply style here, you can change this after initilization
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
     [self.dropDownView showDropDownViewFromSuperview:self.view withTimer:YES forDurationOrZero:10];
 
     // or you may use
//    [self.dropDownView show:self.view];
 }
 
 // IMPLEMENT BELOW DELEGATE METHODS
 
 // method returns the index of which button was clicked (i.e. textfields may be nil depending on style set)
 - (void)dropDownView:(DropDownView*)dropDownView clickedButtonAtIndex:(NSInteger)buttonIndex {
     NSLog(@"Clicked button at index: %i", buttonIndex);
     UITextField *textField1 = [dropDownView textFieldAtIndex:0];
     UITextField *textField2 = [dropDownView textFieldAtIndex:1];
 
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
 
     // be sure to nil out the DropDownView property declared
     self.dropDownView = nil;
 }
 
 */

#import <UIKit/UIKit.h>

#define kDropDownViewNibName @"DropDownView"

typedef NS_ENUM(NSInteger, DropDownViewStyle) {
    DropDownViewStyleDefault = 0,
    DropDownViewStyleSecureTextInput,
    DropDownViewStylePlainTextInput,
    DropDownViewStyleLoginAndPasswordInput
};

@protocol DropDownViewDelegate;

@interface DropDownViewIndentedTextField : UITextField

- (CGRect)textRectForBounds:(CGRect)bounds;
- (CGRect)editingRectForBounds:(CGRect)bounds;

@end


@interface DropDownView : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) id<DropDownViewDelegate> delegate;

@property (strong, nonatomic) UIView                 *superView;
@property (strong, nonatomic) NSTimer                *dropDownViewTimer;
@property (nonatomic)         NSInteger               dropDownViewTimerDuration;
@property (strong, nonatomic) UITapGestureRecognizer *dropDownViewestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet DropDownViewIndentedTextField *defaultTextfield;
@property (weak, nonatomic) IBOutlet DropDownViewIndentedTextField *loginTextfield;
@property (weak, nonatomic) IBOutlet DropDownViewIndentedTextField *passwordTextfield;

@property (weak, nonatomic) IBOutlet UIView  *defaultTextfieldContainerView;
@property (weak, nonatomic) IBOutlet UIView  *loginAndPasswordTextfieldContainerView;
@property (strong, nonatomic)        UIView  *buttonContainerView;
@property (strong, nonatomic) NSMutableArray *buttonTitles;

@property (strong, nonatomic)        UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomDividerImageView;

@property (nonatomic) NSInteger tag;

/* Init with style. Custom view may only have up to a total of 3 buttons, if more are needed, source code will have to be modified */
- (id)initWithTitle:(NSString*)title withDropDownStyle:(DropDownViewStyle)dropDownStyle cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ...;

/* Init with style set to DropDownViewStyleDefault which will not include a textfield, only a message label */
/* Custom view may only have up to a total of 3 buttons, if more are needed, source code will have to be modified */
- (id)initWithTitle:(NSString*)title withMessage:(NSString*)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ...;

/* Set a new style for the DropDownView */
- (void)setDropDownViewStyle:(DropDownViewStyle)dropDownViewStyle;

/* Set a new button background image for the DropDownView */
- (void)setButtonBackground:(UIImage *)backgroundImage;

/* Set a UIGestureRecognizer to DropDownView to dismiss view if clicked */
- (void)setGestureRecognizerForDismissal;

/* Add and animate in the DropDownView from the passed superview, will setup default timer for 5 seconds if no buttons passed */
- (void)show:(UIView*)superview;

/* Add and animate in the DropDownView from the passed superview, will setup default timer for 5 seconds if no buttons passed */
/* Or if set withTimer and a duration of ZERO is given, 5 seconds will be used */
- (void)showDropDownViewFromSuperview:(UIView*)superview withTimer:(BOOL)withTimer forDurationOrZero:(NSInteger)duration;

/* Animate out and remove the DropDownView from the superview */
- (void)dismiss;

/* Retrieves text from textfield displayed in DropDownView */
- (UITextField*)textFieldAtIndex:(NSInteger)index;

/* Check textfield input to determine if text is a valid email address */
- (BOOL)isValidEmail;

@end

@protocol DropDownViewDelegate <NSObject>

@required
- (void)dropDownView:(DropDownView*)dropDownView clickedButtonAtIndex:(NSInteger)buttonIndex;

@optional
- (void)didShowDropDownView:(DropDownView*)dropDownView;
- (void)didDismissDropDownView:(DropDownView*)dropDownView;

@end