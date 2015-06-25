//
//  DYBigSwitch.h
//  DYBigSwitch
//
//  Created by Danny on 4/5/13.
//  Copyright (c) 2013 Danny. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYBigSwitch : UIControl


-(id)initWithFrame:(CGRect)frame;
-(void)setOn:(BOOL)on animated:(BOOL)animated;
-(BOOL)on;

@end
