//
//  ViewController.m
//  DYBigSwitchDemo
//
//  Created by danny on 2015/6/24.
//  Copyright (c) 2015年 danny. All rights reserved.
//

#import "ViewController.h"
#import "DYBigSwitch.h"

@interface ViewController ()

@end

@implementation ViewController
{
    DYBigSwitch *customSwitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    customSwitch = [[DYBigSwitch alloc] initWithFrame:CGRectMake(100, 100, 0, 0)]; //width and height are ignored by the init method.
    [customSwitch addTarget:self action:@selector(switchFlipped:) forControlEvents:UIControlEventValueChanged];
    [customSwitch setTag:1];
    [self.view addSubview:customSwitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchFlipped:(id)sender{
    DYBigSwitch *revievedSwitch = (DYBigSwitch*)sender;
    if (revievedSwitch == customSwitch) {
        if(customSwitch.on)NSLog(@"Custom switch is ON");
        else NSLog(@"Custom switch is OFF");
    }
}

@end
