//
//  DropDownView.m
//
//  Created by Garrett Franks on 1/3/13.
//  Copyright (c) 2013 Garrett Franks. All rights reserved.
//
//

#import "DropDownView.h"

#define kButtonWidth                   84
#define kButtonHeight                  32

#define kStartYButton                  5
#define kStartXOneButton               118
#define kStartXTwoButton               65
#define kStartXThreeButton             20

#define kButtonOffsetOneButton         0
#define kButtonOffestTwoButton         22
#define kButtonOffsetThreeButton       14

#define kButtonContainerViewHeight     45

#define kTextFieldContainerOriginY     39

#define kWithMessageOriginYOffset      55

#define kSubViewFrameOriginX           0
#define kMainViewFrameSizeWidth        320
#define kMainViewFrameSizeHeight       140
#define kBackgroundViewFrameOriginY    2
#define kBackgroundViewFrameSizeHeight 135

#define kBottomDividerImageViewOriginY     138
#define kBottomDividerImageViewFrameHeight 1

#define kHeightDisplacementForNoButtons    35
#define kHeightDisplacementForStyleLoginAndPasswordInput 27

@interface DropDownView () {
    CGFloat mainViewFrameOriginY;
    DropDownViewStyle style;
}

// if one is not set, default will be used
@property (strong, nonatomic) UIImage *buttonBackgroundImage;
@property (assign, nonatomic) BOOL hasButtons;

@end

@implementation DropDownView

@synthesize titleLabel;
@synthesize messageLabel;
@synthesize defaultTextfield, loginTextfield, passwordTextfield;
@synthesize defaultTextfieldContainerView, loginAndPasswordTextfieldContainerView;
@synthesize backgroundImageView;
@synthesize bottomDividerImageView;
@synthesize buttonContainerView;
@synthesize buttonTitles;
@synthesize buttonBackgroundImage;
@synthesize delegate;
@synthesize dropDownViewTimer;
@synthesize dropDownViewTimerDuration;
@synthesize dropDownViewestureRecognizer;
@synthesize tag;
@synthesize hasButtons;

-( id)init {
    return [self initWithNibName:kDropDownViewNibName bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString*)title withDropDownStyle:(DropDownViewStyle)dropDownStyle cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ... {
    self = [self init];
    if (self) {
        if (dropDownStyle) {
            style = dropDownStyle;
        } else {
            style = DropDownViewStyleDefault;
        }
        
        [self.view addSubview:self.titleLabel];
        [self.titleLabel setText:title];
    }
    
    self.buttonTitles = [[NSMutableArray alloc] init];
    
    if (cancelButtonTitle != nil) {
        [self.buttonTitles addObject:cancelButtonTitle];
    }
    
    id buttonTitle;
    va_list argumentList;
    va_start(argumentList, otherButtonTitles);
    buttonTitle = otherButtonTitles;
    
    while(buttonTitle) {
        [self.buttonTitles addObject:buttonTitle];
        buttonTitle = va_arg(argumentList, id);
    }
    va_end(argumentList);
    
    self.hasButtons = [self.buttonTitles count] > 0;
    
    [self conformToStyle];
    [self addButtonsToView];
    
    return self;
}

- (id)initWithTitle:(NSString*)title withMessage:(NSString*)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString*)otherButtonTitles, ... {
    self = [self init];
    if (self) {
        style = DropDownViewStyleDefault;
        
        [self.view addSubview:self.titleLabel];
        [self.titleLabel setText:title];
    }
    
    self.buttonTitles = [[NSMutableArray alloc] init];
    
    if (cancelButtonTitle != nil) {
        [self.buttonTitles addObject:cancelButtonTitle];
    }
    
    id buttonTitle;
    va_list argumentList;
    va_start(argumentList, otherButtonTitles);
    buttonTitle = otherButtonTitles;
    
    while(buttonTitle) {
        [self.buttonTitles addObject:buttonTitle];
        buttonTitle = va_arg(argumentList, id);
    }
    va_end(argumentList);
    
    self.hasButtons = [self.buttonTitles count] > 0;
    
    [self conformToStyle];
    [self addButtonsToView];
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Memory management methods

- (void)viewDidUnload {
    self.titleLabel        = nil;
    self.messageLabel      = nil;
    self.defaultTextfield  = nil;
    self.loginTextfield    = nil;
    self.passwordTextfield = nil;
    self.defaultTextfieldContainerView          = nil;
    self.loginAndPasswordTextfieldContainerView = nil;
    self.backgroundImageView    = nil;
    self.bottomDividerImageView = nil;
    self.buttonContainerView    = nil;
    self.buttonTitles = nil;
    self.delegate     = nil;
    self.dropDownViewTimer = nil;
    
    if (self.dropDownViewestureRecognizer) {
        [self.view removeGestureRecognizer:self.dropDownViewestureRecognizer];
        self.dropDownViewestureRecognizer = nil;
    }
    
    [super viewDidUnload];
}

#pragma mark - Class methods

- (void)setDropDownViewStyle:(DropDownViewStyle)dropDownViewStyle {
    style = dropDownViewStyle;
    [self.backgroundImageView removeFromSuperview];
    [self.buttonContainerView removeFromSuperview];
    self.backgroundImageView = nil;
    self.buttonContainerView = nil;
    
    [self conformToStyle];
    [self addButtonsToView];
}

- (void)setButtonBackground:(UIImage *)backgroundImage {
    self.buttonBackgroundImage = backgroundImage;
    [self.buttonContainerView removeFromSuperview];
    self.buttonContainerView = nil;
    [self addButtonsToView];
}

- (void)setMessageForTextInput:(NSString*)message {
    [self.messageLabel setText:message];
    [self.messageLabel setHidden:NO];
    [self.view addSubview:self.messageLabel];
    
    if (style == DropDownViewStylePlainTextInput || style == DropDownViewStyleSecureTextInput || style == DropDownViewStyleLoginAndPasswordInput) {
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       self.view.frame.origin.y,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height+kWithMessageOriginYOffset)];
        [self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x,
                                                      self.backgroundImageView.frame.origin.y,
                                                      self.backgroundImageView.frame.size.width,
                                                      self.backgroundImageView.frame.size.height+kWithMessageOriginYOffset)];
        [self.bottomDividerImageView setFrame:CGRectMake(self.bottomDividerImageView.frame.origin.x,
                                                         self.bottomDividerImageView.frame.origin.y+kWithMessageOriginYOffset,
                                                         self.bottomDividerImageView.frame.size.width,
                                                         self.bottomDividerImageView.frame.size.height)];
        [self.buttonContainerView setFrame:CGRectMake(self.buttonContainerView.frame.origin.x,
                                                      self.buttonContainerView.frame.origin.y+kWithMessageOriginYOffset,
                                                      self.buttonContainerView.frame.size.width,
                                                      self.buttonContainerView.frame.size.height)];
        
        if (style == DropDownViewStylePlainTextInput || style == DropDownViewStyleSecureTextInput) {
            [self.defaultTextfieldContainerView setFrame:CGRectMake(self.defaultTextfieldContainerView.frame.origin.x,
                                                                    kTextFieldContainerOriginY+kWithMessageOriginYOffset,
                                                                    self.defaultTextfieldContainerView.frame.size.width,
                                                                    self.defaultTextfieldContainerView.frame.size.height)];
        } else if (style == DropDownViewStyleLoginAndPasswordInput) {
            [self.loginAndPasswordTextfieldContainerView setFrame:CGRectMake(self.loginAndPasswordTextfieldContainerView.frame.origin.x,
                                                                             kTextFieldContainerOriginY+kWithMessageOriginYOffset,
                                                                             self.loginAndPasswordTextfieldContainerView.frame.size.width,
                                                                             self.loginAndPasswordTextfieldContainerView.frame.size.height)];
        }
    }
}

- (void)setGestureRecognizerForDismissal {
    self.dropDownViewestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDropDownViewOnTap:)];
    [self.dropDownViewestureRecognizer setNumberOfTapsRequired:1];
    [self.dropDownViewestureRecognizer setDelegate:self];

    [self.view addGestureRecognizer:self.dropDownViewestureRecognizer];
}

- (void)show:(UIView*)superview {
    [self showDropDownViewFromSuperview:superview withTimer:NO forDurationOrZero:0];
}

- (void)showDropDownViewFromSuperview:(UIView*)superview withTimer:(BOOL)withTimer forDurationOrZero:(NSInteger)duration {
    self.superView = superview;
    [self.superView addSubview:self.view];
    [self shouldEnableInteractionForSubviews:NO];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       0,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [self shouldEnableInteractionForSubviews:YES];
        if ([self.delegate respondsToSelector:@selector(didShowDropDownView:)]) {
            [self.delegate didShowDropDownView:self];
        }
        
        BOOL useTimer = withTimer;
        NSInteger countdown = (duration > 0 ? duration : 5);
        if (!self.hasButtons) {
            useTimer = YES;
        }
        
        if (useTimer && countdown > 0) {
            self.dropDownViewTimerDuration = countdown;
            self.dropDownViewTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                      target:self
                                                                    selector:@selector(updateDropDownTimer)
                                                                    userInfo:nil
                                                                     repeats:YES];
        
        }
    }];
}

- (void)dismiss {
    [self shouldEnableInteractionForSubviews:NO];
    [UIView animateWithDuration:1.0 animations:^{
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       mainViewFrameOriginY,
                                       self.view.frame.size.width,
                                       self.view.frame.size.height)];
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(didDismissDropDownView:)]) {
            [self.delegate didDismissDropDownView:self];
        }
        self.superView = nil;
    }];
}

- (UITextField*)textFieldAtIndex:(NSInteger)index {
    UITextField *textfield = nil;
    switch (style) {
        case DropDownViewStylePlainTextInput:
        case DropDownViewStyleSecureTextInput:
            if (index == 0) {
                textfield = defaultTextfield;
            }
            break;
        case DropDownViewStyleLoginAndPasswordInput:
            if (index == 0) {
                textfield = loginTextfield;
            } else if (index == 1) {
                textfield = passwordTextfield;
            }
            break;
        default:
            break;
    }
    
    return textfield;
}

- (BOOL)isValidEmail {
    NSString *text;
    if (style == DropDownViewStylePlainTextInput) {
        text = [defaultTextfield text];
    } else if (style == DropDownViewStyleLoginAndPasswordInput) {
        text = [loginTextfield text];
    }
    
    NSString *expression = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:text options:0 range:NSMakeRange(0, [text length])];
    
    if (match){
        return YES;
    }
    
    return NO;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Style setup private methods 

- (void)conformToStyle {
    /* DO NOT CHANGE THE ORDERING OF VIEWS ADDED TO SUPERVIEW */
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [self.backgroundImageView setAlpha:0.90];
    [self.view addSubview:self.backgroundImageView];
    [self.view bringSubviewToFront:self.titleLabel];
    
    switch (style) {
        case DropDownViewStyleDefault:
        case DropDownViewStyleSecureTextInput:
        case DropDownViewStylePlainTextInput:
        {
            mainViewFrameOriginY = 0 - kMainViewFrameSizeHeight;
            [self.loginAndPasswordTextfieldContainerView setHidden:YES];
            [self setMainViewFrameWithDisplacement:NO];
            [self setBackgroundViewFrameWithDisplacement:NO];
            
            if (style == DropDownViewStyleDefault) {
                [self.defaultTextfieldContainerView setHidden:YES];
                [self.messageLabel setHidden:NO];
                [self.view bringSubviewToFront:self.messageLabel];
                [self.view addSubview:self.messageLabel];
            } else {
                [self.defaultTextfieldContainerView setHidden:NO];
                [self.messageLabel setHidden:YES];
                [self.defaultTextfield setSecureTextEntry:(style == DropDownViewStyleSecureTextInput ? YES : NO)];
                [self.view bringSubviewToFront:self.defaultTextfieldContainerView];
                [self.view addSubview:self.defaultTextfieldContainerView];
            }
            break;
        }
        case DropDownViewStyleLoginAndPasswordInput:
        {
            mainViewFrameOriginY = 0 - (kMainViewFrameSizeHeight + kHeightDisplacementForStyleLoginAndPasswordInput);
            [self.messageLabel setHidden:YES];
            [self.defaultTextfieldContainerView setHidden:YES];
            [self setMainViewFrameWithDisplacement:YES];
            [self setBackgroundViewFrameWithDisplacement:YES];
            [self updateBottomDividerImageViewFrameWithDisplacement:YES];
            
            [self.loginAndPasswordTextfieldContainerView setHidden:NO];
            [self.view bringSubviewToFront:self.loginAndPasswordTextfieldContainerView];
            [self.view addSubview:self.loginAndPasswordTextfieldContainerView];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Button setup private methods

- (void)addButtonsToView {
    CGFloat startY       = kStartYButton;
    CGFloat startX       = 0;
    CGFloat buttonOffset = 0;
    
    self.buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(kSubViewFrameOriginX,
                                                                         self.view.frame.size.height - kButtonContainerViewHeight,
                                                                         kMainViewFrameSizeWidth,
                                                                         kButtonContainerViewHeight)];
    [self.buttonContainerView setBackgroundColor:[UIColor clearColor]];
    
    switch ([self.buttonTitles count]) {
        case 1:
            startX       = kStartXOneButton;
            buttonOffset = kButtonOffsetOneButton;
            break;
        case 2:
            startX       = kStartXTwoButton;
            buttonOffset = kButtonOffestTwoButton;
            break;
        case 3:
            startX       = kStartXThreeButton;
            buttonOffset = kButtonOffsetThreeButton;
            break;
    }
    
    // 0 -> cancel, 1 -> other, 2 -> other
    if (self.hasButtons) {
        for (int i=0; i<[self.buttonTitles count]; i++) {
            switch (i) {
            case 0:
                [self.buttonContainerView addSubview:[self setupButtonForDisplayWithFrame: CGRectMake(startX, startY, kButtonWidth, kButtonHeight)
                                                                                 andTitle:[self.buttonTitles objectAtIndex:i]
                                                                                   forTag:i]];
                break;
            case 1:
                [self.buttonContainerView addSubview:[self setupButtonForDisplayWithFrame:CGRectMake(startX+kButtonWidth+buttonOffset, startY, kButtonWidth, kButtonHeight)
                                                                                 andTitle:[self.buttonTitles objectAtIndex:i]
                                                                                   forTag:i]];
                break;
            case 2:
                [self.buttonContainerView addSubview:[self setupButtonForDisplayWithFrame:CGRectMake(startX+(2*kButtonWidth)+(2*buttonOffset), startY, kButtonWidth, kButtonHeight)
                                                                                 andTitle:[self.buttonTitles objectAtIndex:i]
                                                                                   forTag:i]];
                break;
            }
        }
        
        [self.view addSubview:self.buttonContainerView];
    } else {
        CGFloat mainViewHeight;
        CGFloat backgroundViewHeight;
        CGFloat bottomDividerImageViewY;
        if (style == DropDownViewStyleLoginAndPasswordInput) {
            mainViewHeight = kMainViewFrameSizeHeight + kHeightDisplacementForStyleLoginAndPasswordInput - kHeightDisplacementForNoButtons;
            backgroundViewHeight = kBackgroundViewFrameSizeHeight + kHeightDisplacementForStyleLoginAndPasswordInput - kHeightDisplacementForNoButtons;
            bottomDividerImageViewY = kBottomDividerImageViewOriginY + kHeightDisplacementForStyleLoginAndPasswordInput - kHeightDisplacementForNoButtons;
        } else {
            mainViewHeight = kMainViewFrameSizeHeight - kHeightDisplacementForNoButtons;
            backgroundViewHeight = kBackgroundViewFrameSizeHeight - kHeightDisplacementForNoButtons;
            bottomDividerImageViewY = kBottomDividerImageViewOriginY - kHeightDisplacementForNoButtons;
        }
        
        [self.view setFrame:CGRectMake(self.view.frame.origin.x,
                                       0 - mainViewHeight,
                                       self.view.frame.size.width,
                                       mainViewHeight)];
        [self.backgroundImageView setFrame:CGRectMake(self.backgroundImageView.frame.origin.x,
                                                      self.backgroundImageView.frame.origin.y,
                                                      self.backgroundImageView.frame.size.width,
                                                      backgroundViewHeight)];
        [self.bottomDividerImageView setFrame:CGRectMake(self.bottomDividerImageView.frame.origin.x,
                                                         bottomDividerImageViewY,
                                                         self.bottomDividerImageView.frame.size.width,
                                                         self.bottomDividerImageView.frame.size.height)];
    }
}

- (UIButton*)setupButtonForDisplayWithFrame:(CGRect)buttonFrame andTitle:(NSString*)title forTag:(NSInteger)buttonTag{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setFrame:buttonFrame];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:16.0]];
    
    [button setTag:buttonTag];
    [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    if (self.buttonBackgroundImage) {
        [button setBackgroundImage:buttonBackgroundImage forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor darkTextColor] forState:UIControlStateNormal];
        [[button titleLabel] setShadowOffset:CGSizeMake(1, 1)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return button;
}


#pragma mark - Update view frames private methods

- (void)setMainViewFrameWithDisplacement:(BOOL)withDisplacement {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    [self.view setFrame:CGRectMake((screenWidth / 2) - (self.view.frame.size.width / 2),
                                   mainViewFrameOriginY,
                                   kMainViewFrameSizeWidth,
                                   kMainViewFrameSizeHeight + (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0))];
}

- (void)setBackgroundViewFrameWithDisplacement:(BOOL)withDisplacement {
    [self.backgroundImageView setFrame:CGRectMake(kSubViewFrameOriginX,
                                                  kBackgroundViewFrameOriginY,
                                                  kMainViewFrameSizeWidth,
                                                  kBackgroundViewFrameSizeHeight + (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0))];
}

- (void)updateBottomDividerImageViewFrameWithDisplacement:(BOOL)withDisplacement {
    [self.bottomDividerImageView setFrame:CGRectMake(kSubViewFrameOriginX,
                                                     kBottomDividerImageViewOriginY + (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0),
                                                     kMainViewFrameSizeWidth,
                                                     kBottomDividerImageViewFrameHeight)];
}

#pragma mark - Timer update private method

- (void)updateDropDownTimer {
    self.dropDownViewTimerDuration -= 1;
    if (self.dropDownViewTimerDuration <= 0) {
        [self.dropDownViewTimer invalidate];
        [self dismiss];
    }
}

#pragma mark - View interaction private methods

- (void)shouldEnableInteractionForSubviews:(BOOL)enableInteraction {
    [self.view setUserInteractionEnabled:enableInteraction];
    switch (style) {
        case DropDownViewStyleDefault:
            break;
        case DropDownViewStyleSecureTextInput:
            [self.defaultTextfield setUserInteractionEnabled:enableInteraction];
            break;
        case DropDownViewStylePlainTextInput:
            [self.defaultTextfield setUserInteractionEnabled:enableInteraction];
            break;
        case DropDownViewStyleLoginAndPasswordInput:
            [self.loginTextfield setUserInteractionEnabled:enableInteraction];
            [self.loginTextfield setUserInteractionEnabled:enableInteraction];
            break;
        default:
            break;
    }
    
    for (UIButton* button in [self.buttonContainerView subviews]) {
        [button setUserInteractionEnabled:enableInteraction];
    }
}

#pragma mark - Selector methods

- (void)didSelectButton:(id)sender {
    if (self.dropDownViewTimer) {
        [self.dropDownViewTimer invalidate];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownView:clickedButtonAtIndex:)]) {
        [self.delegate dropDownView:self clickedButtonAtIndex:[(UIButton*)sender tag]];
    }
}

- (void)dismissDropDownViewOnTap:(UITapGestureRecognizer*)gestureRecognizer {
    if (self.dropDownViewTimer) {
        [self.dropDownViewTimer invalidate];
    }
    
    [self dismiss];
}

@end

@implementation DropDownViewIndentedTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 10, 10);
}

@end