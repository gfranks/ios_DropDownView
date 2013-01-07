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

#define kTitleLabelFrameOriginY        8
#define kTitleLabelFrameSizeHeight     21
#define kMessageLabelFrameOriginY      29
#define kMessageLabelFrameSizeHeight   60

#define kTextFieldFrameOriginY         39
#define kTextFieldFrameSizeHeight      36
#define kTextFieldShadowHeight         13

#define kViewFrameSizeWidth            280

#define kStartYButton                  5
#define kStartXOneButton               118
#define kStartXTwoButton               65
#define kStartXThreeButton             20

#define kButtonOffsetOneButton         0
#define kButtonOffestTwoButtoniPhone   22
#define kButtonOffestTwoButtoniPad     32
#define kButtonOffsetThreeButtoniPhone 14
#define kButtonOffsetThreeButtoniPad   35

#define kButtonContainerViewHeight     45

#define kSubViewFrameOriginX           0
#define kMainViewFrameSizeWidthiPhone  320
#define kMainViewFrameSizeWidthiPad    450
#define kMainViewFrameSizeHeight       138
#define kBackgroundViewFrameOriginY    2
#define kBackgroundViewFrameSizeHeight 134

#define kBottomDividerImageViewOriginY 135
#define kDividerImageViewFrameHeight   1

#define kHeightDisplacementForNoButtons    35
#define kHeightDisplacementForStyleLoginAndPasswordInput 27

@interface DropDownView () {
    BOOL hasTitle;
    CGFloat mainViewFrameOriginY;
    CGFloat mainViewFrameSizeWidth;
    DropDownViewStyle style;
    UIImage *textFieldDropShadow;
}

// if one is not set, default will be used
@property (strong, nonatomic) UIImage *buttonBackgroundImage;
@property (assign, nonatomic) BOOL hasButtons;

@end

@implementation DropDownView

@synthesize view;
@synthesize titleLabel;
@synthesize messageLabel;
@synthesize textField1, textField2;
@synthesize textFieldShadow;
@synthesize textFieldSeperator;
@synthesize backgroundImageView;
@synthesize topDividerImageView;
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
    self = [super init];
    if (self) {
        if ([self isIPad]) {
            mainViewFrameSizeWidth = kMainViewFrameSizeWidthiPad;
        } else {
            mainViewFrameSizeWidth = kMainViewFrameSizeWidthiPhone;
        }
        
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             mainViewFrameSizeWidth,
                                                             kMainViewFrameSizeHeight)];
        [self.view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80]];
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
        
        [self addTitleLabel:title];
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
        [self addTitleLabel:title];
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

#pragma mark - Class methods

- (void)setDropDownViewStyle:(DropDownViewStyle)dropDownViewStyle {
    style = dropDownViewStyle;
    [self checkSubviewsForRemoval];
    
    [self conformToStyle];
    [self addButtonsToView];
}

- (void)setButtonBackground:(UIImage *)backgroundImage {
    self.buttonBackgroundImage = backgroundImage;
    [self.buttonContainerView removeFromSuperview];
    self.buttonContainerView = nil;
    [self addButtonsToView];
}

- (void)setTextFieldDropShadow:(UIImage *)dropShadowImage {
    if (self.textFieldShadow) {
        [self.textFieldShadow setImage:dropShadowImage];
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
        case DropDownViewStyleLoginAndPasswordInput:
            if (index == 0) {
                textfield = self.textField1;
            } else if (index == 1) {
                textfield = self.textField2;
            }
            break;
        default:
            break;
    }
    
    return textfield;
}

- (BOOL)isValidEmail {
    NSString *text;
    if (style == DropDownViewStylePlainTextInput || style == DropDownViewStyleLoginAndPasswordInput) {
        text = [self.textField1 text];
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

- (void)setupSubviews {
    switch (style) {
        case DropDownViewStyleDefault:
        {
            [self addMessageLabel:@""];
            break;
        }
        case DropDownViewStyleSecureTextInput:
        {
            [self addTextFieldWithSecureInput:YES];
            break;
        }
        case DropDownViewStylePlainTextInput:
        {
            [self addTextFieldWithSecureInput:NO];
            break;
        }
        case DropDownViewStyleLoginAndPasswordInput:
        {
            [self addLoginAndPasswordInput];
            break;
        }
        default:
            break;
    }
}

- (void)addTitleLabel:(NSString*)title {
    if (title) {
        hasTitle = YES;
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                    kTitleLabelFrameOriginY,
                                                                    kViewFrameSizeWidth,
                                                                    kTitleLabelFrameSizeHeight)];
        [self.titleLabel setText:title];
        [self.titleLabel setTextColor:[UIColor whiteColor]];
        [self.titleLabel setShadowColor:[UIColor darkTextColor]];
        [self.titleLabel setShadowOffset:CGSizeMake(1, 1)];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.view addSubview:self.titleLabel];
    } else {
        hasTitle = NO;
    }
}

- (void)addMessageLabel:(NSString*)message {
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                  kMessageLabelFrameOriginY - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                  kViewFrameSizeWidth,
                                                                  kMessageLabelFrameSizeHeight)];
    [self.messageLabel setText:message];
    [self.messageLabel setTextColor:[UIColor whiteColor]];
    [self.messageLabel setShadowColor:[UIColor darkTextColor]];
    [self.messageLabel setShadowOffset:CGSizeMake(1, 1)];
    [self.messageLabel setBackgroundColor:[UIColor clearColor]];
    [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:self.messageLabel];
}

- (void)addTextFieldWithSecureInput:(BOOL)hasSecureInput {
    self.textField1 = [[DropDownViewIndentedTextField alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                                      kTextFieldFrameOriginY - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                                      kViewFrameSizeWidth,
                                                                                      kTextFieldFrameSizeHeight)];
    [self.textField1 setBorderStyle:UITextBorderStyleNone];
    [self.textField1 setBackgroundColor:[UIColor whiteColor]];
    [self.textField1 setFont:[UIFont systemFontOfSize:16.0]];
    [self.textField1 setDelegate:self];
    
    self.textFieldShadow = [[UIImageView alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                         kTextFieldFrameOriginY + kTextFieldFrameSizeHeight - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                         kViewFrameSizeWidth,
                                                                         kTextFieldShadowHeight)];
    [self.textFieldShadow setImage:textFieldDropShadow];
    
    [self.view addSubview:self.textField1];
    [self.view bringSubviewToFront:self.textField1];
}

- (void)addLoginAndPasswordInput {
    self.textField1 = [[DropDownViewIndentedTextField alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                                      kTextFieldFrameOriginY - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                                      kViewFrameSizeWidth,
                                                                                      kTextFieldFrameSizeHeight)];
    [self.textField1 setBorderStyle:UITextBorderStyleNone];
    [self.textField1 setBackgroundColor:[UIColor whiteColor]];
    [self.textField1 setFont:[UIFont systemFontOfSize:16.0]];
    [self.textField1 setPlaceholder:@"Enter email address"];
    [self.textField1 setDelegate:self];
    
    self.textField2 = [[DropDownViewIndentedTextField alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                                      kTextFieldFrameOriginY + kTextFieldFrameSizeHeight - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                                      kViewFrameSizeWidth,
                                                                                      kTextFieldFrameSizeHeight)];
    [self.textField2 setBorderStyle:UITextBorderStyleNone];
    [self.textField2 setBackgroundColor:[UIColor whiteColor]];
    [self.textField2 setFont:[UIFont systemFontOfSize:16.0]];
    [self.textField2 setPlaceholder:@"Password"];
    [self.textField2 setDelegate:self];
    
    self.textFieldSeperator = [[UIImageView alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                            kTextFieldFrameOriginY + kTextFieldFrameSizeHeight - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                            kViewFrameSizeWidth,
                                                                            1)];
    [self.textFieldSeperator setBackgroundColor:[UIColor lightGrayColor]];
    [self.textFieldSeperator setAlpha:0.50];
    
    self.textFieldShadow = [[UIImageView alloc] initWithFrame:CGRectMake([self getCenteredXPosition],
                                                                         kTextFieldFrameOriginY + (kTextFieldFrameSizeHeight*2) - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                         kViewFrameSizeWidth,
                                                                         kTextFieldShadowHeight)];
    [self.textFieldShadow setImage:textFieldDropShadow];
    
    [self.view addSubview:self.textField1];
    [self.view addSubview:self.textField2];
    [self.view addSubview:self.textFieldShadow];
    [self.view addSubview:self.textFieldSeperator];
}

- (CGFloat)getCenteredXPosition {
    return (self.view.frame.size.width/2) - (kViewFrameSizeWidth/2);
}

- (void)conformToStyle {
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundImageView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
    [self.backgroundImageView setAlpha:0.90];
    
    [self.view addSubview:self.backgroundImageView];
    [self.view bringSubviewToFront:self.titleLabel];

    self.topDividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSubViewFrameOriginX + 1,
                                                                             kSubViewFrameOriginX,
                                                                             mainViewFrameSizeWidth,
                                                                             kDividerImageViewFrameHeight)];
    [self.topDividerImageView setBackgroundColor:[UIColor darkGrayColor]];
    self.bottomDividerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kSubViewFrameOriginX,
                                                                                kBottomDividerImageViewOriginY - (hasTitle ? 0 : kTitleLabelFrameSizeHeight),
                                                                                mainViewFrameSizeWidth,
                                                                                kDividerImageViewFrameHeight)];
    [self.bottomDividerImageView setBackgroundColor:[UIColor darkGrayColor]];
    
//    [self.view addSubview:self.topDividerImageView];
    [self.view addSubview:self.bottomDividerImageView];
    [self.view bringSubviewToFront:self.bottomDividerImageView];
    
    BOOL shouldChangeMainViewOrigin;
    switch (style) {
        case DropDownViewStyleDefault:
        case DropDownViewStyleSecureTextInput:
        case DropDownViewStylePlainTextInput:
            mainViewFrameOriginY = 0 - kMainViewFrameSizeHeight;
            shouldChangeMainViewOrigin = NO;
            break;
        case DropDownViewStyleLoginAndPasswordInput:
            mainViewFrameOriginY = 0 - (kMainViewFrameSizeHeight + kHeightDisplacementForStyleLoginAndPasswordInput);
            shouldChangeMainViewOrigin = YES;
            break;
        default:
            shouldChangeMainViewOrigin = NO;
            break;
    }
    
    [self setMainViewFrameWithDisplacement:shouldChangeMainViewOrigin];
    [self setBackgroundViewFrameWithDisplacement:shouldChangeMainViewOrigin];
    [self updateBottomDividerImageViewFrameWithDisplacement:shouldChangeMainViewOrigin];

    [self setupSubviews];
}

#pragma mark - Button setup private methods

- (void)addButtonsToView {
    CGFloat startY       = kStartYButton;
    CGFloat startX       = 0;
    CGFloat buttonOffset = 0;
    
    self.buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(kSubViewFrameOriginX,
                                                                         self.view.frame.size.height - kButtonContainerViewHeight,
                                                                         mainViewFrameSizeWidth,
                                                                         kButtonContainerViewHeight)];
    [self.buttonContainerView setBackgroundColor:[UIColor clearColor]];
    
    switch ([self.buttonTitles count]) {
        case 0:
            break;
        case 1:
            startX       = (self.view.frame.size.width/2) - (kButtonWidth/2);
            buttonOffset = kButtonOffsetOneButton;
            break;
        case 2:
            if ([self isIPad]) {
                buttonOffset = kButtonOffestTwoButtoniPad;
            } else {
                buttonOffset = kButtonOffestTwoButtoniPhone;
            }
            startX       = (self.view.frame.size.width/2) - (buttonOffset/2) - kButtonWidth;
            break;
        case 3:
        default:
            if ([self isIPad]) {
                buttonOffset = kButtonOffsetThreeButtoniPad;
            } else {
                buttonOffset = kButtonOffsetThreeButtoniPhone;
            }
            
            startX       = (self.view.frame.size.width/2) - (kButtonWidth/2) - buttonOffset - kButtonWidth;
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
        
        if (!hasTitle) {
            mainViewHeight -= kTitleLabelFrameSizeHeight;
            backgroundViewHeight -= kTitleLabelFrameSizeHeight;
            bottomDividerImageViewY -= kTitleLabelFrameSizeHeight;
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
    CGFloat frameHeight = (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0) - (hasTitle ? 0 : kTitleLabelFrameSizeHeight);
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    [self.view setFrame:CGRectMake((screenWidth / 2) - (self.view.frame.size.width / 2),
                                   mainViewFrameOriginY,
                                   mainViewFrameSizeWidth,
                                   kMainViewFrameSizeHeight + frameHeight)];
}

- (void)setBackgroundViewFrameWithDisplacement:(BOOL)withDisplacement {
    CGFloat frameHeight = (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0) - (hasTitle ? 0 : kTitleLabelFrameSizeHeight);
    [self.backgroundImageView setFrame:CGRectMake(kSubViewFrameOriginX,
                                                  kBackgroundViewFrameOriginY,
                                                  mainViewFrameSizeWidth,
                                                  kBackgroundViewFrameSizeHeight + frameHeight)];
}

- (void)updateBottomDividerImageViewFrameWithDisplacement:(BOOL)withDisplacement {
    CGFloat frameOriginY = (withDisplacement ? kHeightDisplacementForStyleLoginAndPasswordInput : 0) - (hasTitle ? 0 : kTitleLabelFrameSizeHeight);
    [self.bottomDividerImageView setFrame:CGRectMake(kSubViewFrameOriginX,
                                                     kBottomDividerImageViewOriginY + frameOriginY,
                                                     mainViewFrameSizeWidth,
                                                     kDividerImageViewFrameHeight)];
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
        case DropDownViewStylePlainTextInput:
            [self.textField1 setUserInteractionEnabled:enableInteraction];
            break;
        case DropDownViewStyleLoginAndPasswordInput:
            [self.textField1 setUserInteractionEnabled:enableInteraction];
            [self.textField2 setUserInteractionEnabled:enableInteraction];
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

#pragma mark - Private methods

- (BOOL)isIPad {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)]){
        //We can test if it's an iPad. Running iOS3.2+
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            return YES; //is an iPad
        }
        else{
            return NO; //is an iPhone
        }
    }
    else{
        return NO; //does not respond to selector, therefore must be < iOS3.2, therefore is an iPhone
    }
}

- (void)checkSubviewsForRemoval {
    if (self.textField1) {
        [self.textField1 removeFromSuperview];
        self.textField1 = nil;
    }
    
    if (self.textField2) {
        [self.textField2 removeFromSuperview];
        self.textField2 = nil;
    }
    
    if (self.messageLabel) {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
    
    if (self.textFieldShadow) {
        [self.textFieldShadow removeFromSuperview];
        self.textFieldShadow = nil;
    }
    
    if (self.textFieldSeperator) {
        [self.textFieldSeperator removeFromSuperview];
        self.textFieldSeperator = nil;
    }
    
    if (self.topDividerImageView) {
        [self.topDividerImageView removeFromSuperview];
        self.topDividerImageView = nil;
    }
    
    if (self.bottomDividerImageView) {
        [self.bottomDividerImageView removeFromSuperview];
        self.bottomDividerImageView = nil;
    }
    
    if (self.backgroundImageView) {
        [self.backgroundImageView removeFromSuperview];
        self.backgroundImageView = nil;
    }
    
    if (self.buttonContainerView) {
        [self.buttonContainerView removeFromSuperview];
        self.buttonContainerView = nil;
    }
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