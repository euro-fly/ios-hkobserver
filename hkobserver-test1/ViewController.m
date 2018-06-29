//
//  ViewController.m
//  hkobserver-test1
//
//  Created by Jacob on 2018/06/29.
//  Copyright © 2018 Jacob. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *stepCountLabel;
@property (nonatomic) HKHealthStore *myStore;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.myStore = [[HKHealthStore alloc] init];
    HKQuantityType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:sampleType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLabel];
        });
    }];
    [self.myStore executeQuery:query];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabel {
    
}


@end
