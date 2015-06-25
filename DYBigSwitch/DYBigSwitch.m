//
//  DYBigSwitch.m
//  DYBigSwitch
//
//  Created by Danny on 4/5/13.
//  Copyright (c) 2013 Danny. All rights reserved.
//

#import "DYBigSwitch.h"
#import <QuartzCore/QuartzCore.h>

#define WIDTH       79.0
#define HEIGHT      30.0
#define BACK_WIDTH  128.0
#define BUTTON_DIAM 30.0
#define HORZ_PADDING 0.0    //padding between the button and the edge of the switch.
#define TAP_SENSITIVITY 25.0 //margin of error to detect if the switch was tapped or swiped.
#


@implementation DYBigSwitch
{
    UIImageView *backgroundImageView;
    UIImageView *buttonImageView;
    BOOL isOn;
    CGPoint firstTouchPoint;
    float touchDistanceFromButton;
    id returnTarget;
    SEL returnAction;

    CGFloat SWITCH_WIDTH;
    CGFloat SWITCH_HEIGHT;
    CGFloat SWITCH_BACKGROUND_WIDTH;
    CGFloat SWITCH_THUMB_DIAM;
    CGFloat SWITCH_HORZ_PADDING;
    CGFloat SWITCH_TAP_SENSITIVITY;
    CGFloat SWITCH_SIZE_RATIO;
    UIFont *SWITCH_ON_TEXT_FONT;
    UIFont *SWITCH_OFF_TEXT_FONT;

}

-(void)initPhone
{
    SWITCH_SIZE_RATIO=1;
    SWITCH_WIDTH=WIDTH*SWITCH_SIZE_RATIO;
    SWITCH_HEIGHT=HEIGHT*SWITCH_SIZE_RATIO;
    SWITCH_BACKGROUND_WIDTH=BACK_WIDTH*SWITCH_SIZE_RATIO;
    SWITCH_THUMB_DIAM=BUTTON_DIAM*SWITCH_SIZE_RATIO;
    SWITCH_HORZ_PADDING=HORZ_PADDING;
    SWITCH_TAP_SENSITIVITY=TAP_SENSITIVITY;
    SWITCH_ON_TEXT_FONT=[UIFont boldSystemFontOfSize:17.0];
    SWITCH_OFF_TEXT_FONT=[UIFont boldSystemFontOfSize:17.0];

}

-(void)initPad
{
    SWITCH_SIZE_RATIO=2;
    SWITCH_WIDTH=WIDTH*SWITCH_SIZE_RATIO;
    SWITCH_HEIGHT=HEIGHT*SWITCH_SIZE_RATIO;
    SWITCH_BACKGROUND_WIDTH=BACK_WIDTH*SWITCH_SIZE_RATIO;
    SWITCH_THUMB_DIAM=BUTTON_DIAM*SWITCH_SIZE_RATIO;
    SWITCH_HORZ_PADDING=HORZ_PADDING;
    SWITCH_TAP_SENSITIVITY=TAP_SENSITIVITY;
    SWITCH_ON_TEXT_FONT=[UIFont boldSystemFontOfSize:35.0];
    SWITCH_OFF_TEXT_FONT=[UIFont boldSystemFontOfSize:35.0];
}


- (id)initWithFrame:(CGRect)frame{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [self initPad];
    }else{
        [self initPhone];

    }


    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, SWITCH_WIDTH, SWITCH_HEIGHT)];
    if (self) {
        self.layer.masksToBounds = YES;
        NSString* resourcesBundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"DYBigSwitchBundle.bundle"];
        NSBundle* resourcesBundle = [NSBundle bundleWithPath:resourcesBundlePath];

        UIView *maskedView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SWITCH_WIDTH, SWITCH_HEIGHT)];
        [self addSubview:maskedView];

        backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-(SWITCH_WIDTH - SWITCH_THUMB_DIAM), 0, SWITCH_BACKGROUND_WIDTH, SWITCH_HEIGHT)];
        [backgroundImageView setImage:[UIImage imageNamed:@"background.png"]];
        [maskedView addSubview:backgroundImageView];

        //先置入一個範圍的底圖，再利用maskToBounds的設定，將後來放的backgroundImageView加至maskedView，
        //如果backgroundImageView畫面有超過maskedView放的圖片就cut成maskedView中的圖像形狀
        CALayer *mask = [CALayer layer];
        //mask.contents = (id)[[UIImage imageNamed:@"mask.png"] CGImage];
        mask.contents = (id)[[UIImage imageNamed:@"maskoverlay.png"] CGImage];
        mask.frame = CGRectMake(0, 0, SWITCH_WIDTH, SWITCH_HEIGHT);
        maskedView.layer.mask = mask;
        maskedView.layer.masksToBounds = YES;


        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerDidChange:)];
        [backgroundImageView addGestureRecognizer:panGestureRecognizer];

        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerDidChange:)];
        [backgroundImageView addGestureRecognizer:tapGestureRecognizer];





        UIImageView *borderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SWITCH_WIDTH, SWITCH_HEIGHT)];
        buttonImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM)];
        [borderImageView setImage:[UIImage imageNamed:@"border.png"]];
        [buttonImageView setImage:[UIImage imageNamed:@"button.png"]];
        [self addSubview:borderImageView];
        [self addSubview:buttonImageView];

        //
        NSLog(@"%f %f",backgroundImageView.frame.size.width,borderImageView.frame.size.width);
        UILabel *switchOnLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SWITCH_BACKGROUND_WIDTH/2, SWITCH_HEIGHT)];
        [switchOnLabel setText:NSLocalizedStringFromTableInBundle(@"SWITCH_TO_ON",@"LocalizableDYBigSwitch",resourcesBundle,  @"DELETE")];
        [switchOnLabel setFont:SWITCH_ON_TEXT_FONT];
        [switchOnLabel setTextColor:[UIColor whiteColor]];
        [switchOnLabel setTextAlignment:NSTextAlignmentCenter];
        [switchOnLabel setBackgroundColor:[UIColor clearColor]];
        //
        UILabel *switchOffLabel=[[UILabel alloc] initWithFrame:CGRectMake(0 + switchOnLabel.frame.size.width, 0, SWITCH_BACKGROUND_WIDTH/2, SWITCH_HEIGHT)];
        [switchOffLabel setText:NSLocalizedStringFromTableInBundle(@"SWITCH_TO_OFF",@"LocalizableDYBigSwitch",resourcesBundle,  @"DELETE")];
        [switchOffLabel setFont:SWITCH_ON_TEXT_FONT];
        [switchOffLabel setTextColor:[UIColor grayColor]];
        [switchOffLabel setTextAlignment:NSTextAlignmentCenter];
        [switchOffLabel setBackgroundColor:[UIColor clearColor]];
        [backgroundImageView addSubview:switchOnLabel];
        [backgroundImageView addSubview:switchOffLabel];

    }
    return self;
}

-(void)setOn:(BOOL)on animated:(BOOL)animated{
    isOn = on;
    CGRect newBackFrame;
    CGRect newButtonFrame;
    if (on) {
        newBackFrame = CGRectMake(0, 0, SWITCH_BACKGROUND_WIDTH, SWITCH_HEIGHT);
        newButtonFrame = CGRectMake(SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM);
    }
    else {
        newBackFrame = CGRectMake(-(SWITCH_WIDTH-SWITCH_THUMB_DIAM), 0, SWITCH_BACKGROUND_WIDTH, SWITCH_HEIGHT);
        newButtonFrame = CGRectMake(SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM);
    }

    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelay:0];
        [UIView setAnimationDuration:0.23];
        [backgroundImageView setFrame:newBackFrame];
        [buttonImageView setFrame:newButtonFrame];
        [UIView commitAnimations];
    }
    else {
        [backgroundImageView setFrame:newBackFrame];
        [buttonImageView setFrame:newButtonFrame];
    }

}

-(BOOL)on{
    return isOn;
}

-(void)toggleAnimated:(BOOL)animated{
    if (isOn){
        [self setOn:NO animated:animated];
    }
    else {
        [self setOn:YES animated:animated];
    }
}

-(void)returnStatus{
    //The following line may cause a warning - "performSelector may cause a leak because its selector is unknown".
    //This is because ARC's behaviour is tied in with objective-c naming conventions of methods (convenience constructors that return autoreleased objects
    //vs. init methods that return retained objects). ARC doesn't know what _action is, so it doesn't know how to deal with it.  This is a known issue.
    //              http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [returnTarget performSelector:returnAction withObject:self];
    #pragma clang diagnostic pop
}
#pragma mark Gesture recognizers

- (void)panGestureRecognizerDidChange:(UIPanGestureRecognizer *)recognizer
{
}

- (void)tapGestureRecognizerDidChange:(UITapGestureRecognizer *)recognizer
{
}


#pragma mark - Touch event methods.
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    firstTouchPoint = [touch locationInView:self];
    touchDistanceFromButton = firstTouchPoint.x - buttonImageView.frame.origin.x;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint lastTouchPoint = [touch locationInView:self];
    //NSLog(@"%f %f",firstTouchPoint.x, lastTouchPoint.x);

    if (firstTouchPoint.x < lastTouchPoint.x) {
        //Move the button right
        [buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM)];
    }
    else{
        //Move the button left
        [buttonImageView setFrame:CGRectMake(lastTouchPoint.x - touchDistanceFromButton, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM)];
    }

    //Swipe fast enough and the button will be drawn outside the bounds.
    //If so, relocate it to the left/right of the switch.
    //避免將button移過頭
    if (buttonImageView.frame.origin.x > (SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING)) {
        [buttonImageView setFrame:CGRectMake(SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM)];
    }
    else if(buttonImageView.frame.origin.x < SWITCH_HORZ_PADDING){
        [buttonImageView setFrame:CGRectMake(SWITCH_HORZ_PADDING,0, SWITCH_THUMB_DIAM,SWITCH_THUMB_DIAM)];
    }

    [backgroundImageView setFrame:CGRectMake(buttonImageView.frame.origin.x - SWITCH_WIDTH + SWITCH_THUMB_DIAM, 0, SWITCH_BACKGROUND_WIDTH, SWITCH_HEIGHT)];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    //CGPoint endTouchPoint = [touch locationInView:self];
    //NSLog(@"tapcount %ld",touch.tapCount);
    //只是點擊一次就Toggle狀態
    if (touch.tapCount==1)
    {
        [self toggleAnimated:YES];
    }
        //SWIPED
        CGRect newButtonFrame;
        float distanceToEnd = 0;
        BOOL needsMove = NO;

        //If the button is languishing somewhere in the middle of the switch
        //move it to either on or off.

        //First, edge cases

        if (buttonImageView.frame.origin.x == SWITCH_HORZ_PADDING) {
            distanceToEnd = 0;
            isOn = NO;
        }
        else if(buttonImageView.frame.origin.x == (SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING)){
            distanceToEnd = 0;
            isOn = YES;
        }
        //Then, right or left
        if(buttonImageView.frame.origin.x < ((SWITCH_WIDTH / 2) - (SWITCH_THUMB_DIAM / 2))){
            //move left
            newButtonFrame = CGRectMake(SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM);
            distanceToEnd = buttonImageView.frame.origin.x;
            isOn = NO;
            needsMove = YES;
        }
        else if(buttonImageView.frame.origin.x < (SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING)){
            //move right
            newButtonFrame = CGRectMake(SWITCH_WIDTH - SWITCH_THUMB_DIAM - SWITCH_HORZ_PADDING, 0, SWITCH_THUMB_DIAM, SWITCH_THUMB_DIAM);
            distanceToEnd = WIDTH - buttonImageView.frame.origin.x - SWITCH_THUMB_DIAM;
            isOn = YES;
            needsMove = YES;
        }
        //make animation to move
        if (needsMove){
            //animate more quickly if the button is towards the end of the switch.
            float animTime = distanceToEnd / 140;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelay:0];
            [UIView setAnimationDuration:animTime];
            [buttonImageView setFrame:newButtonFrame];
            [backgroundImageView setFrame:CGRectMake(buttonImageView.frame.origin.x - SWITCH_WIDTH + SWITCH_THUMB_DIAM, 0, SWITCH_BACKGROUND_WIDTH, SWITCH_HEIGHT)];
            [UIView commitAnimations];
        }
        [self returnStatus];
}

#pragma mark - Event handling.

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)events {
    if (events & UIControlEventValueChanged) {
        returnTarget = target;
        returnAction = action;
    }
}

@end
