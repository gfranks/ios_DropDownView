//
//  DropDownViewViewController.h
//  DropDownView
//
//  Created by Garrett Franks on 1/6/13.
//  Copyright (c) 2013 Garrett Franks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownView.h"

@interface DropDownViewViewController : UIViewController <DropDownViewDelegate>

@property (strong, nonatomic) DropDownView *dropDownView;

@end
