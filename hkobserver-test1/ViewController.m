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
    [self startHealthKitAuth];
    HKQuantityType *sampleType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:sampleType predicate:nil updateHandler:^(HKObserverQuery *query, HKObserverQueryCompletionHandler completionHandler, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateLabel];
            
        });
    }];
    [self.myStore executeQuery:query];
}

- (void)startHealthKitAuth {
    HKQuantityType *stepCountTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    HKQuantityType *bodyFatTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage];
    HKQuantityType *bodyMassTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *bloodPressureSystolicTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *bloodPressureDiastolicTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *heartRateTy = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKCategoryType *sleepTy = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKAuthorizationStatus stepAuthStatus = [self.myStore authorizationStatusForType:stepCountTy];
    HKAuthorizationStatus fatAuthStatus = [self.myStore authorizationStatusForType:bodyFatTy];
    HKAuthorizationStatus massAuthStatus = [self.myStore authorizationStatusForType:bodyMassTy];
    HKAuthorizationStatus systolicAuthStatus = [self.myStore authorizationStatusForType:bloodPressureSystolicTy];
    HKAuthorizationStatus diastolicAuthStatus = [self.myStore authorizationStatusForType:bloodPressureDiastolicTy];
    HKAuthorizationStatus heartAuthStatus = [self.myStore authorizationStatusForType:heartRateTy];
    HKAuthorizationStatus sleepAuthStatus = [self.myStore authorizationStatusForType:sleepTy];
    //初めて聞く場合 - first request
    if ((stepAuthStatus == HKAuthorizationStatusNotDetermined)||
        (fatAuthStatus == HKAuthorizationStatusNotDetermined)||
        (massAuthStatus == HKAuthorizationStatusNotDetermined)||
        (systolicAuthStatus == HKAuthorizationStatusNotDetermined)||
        (diastolicAuthStatus == HKAuthorizationStatusNotDetermined)||
        (heartAuthStatus == HKAuthorizationStatusNotDetermined)||
        (sleepAuthStatus == HKAuthorizationStatusNotDetermined)) {
        NSSet *allDataTypes = [NSSet setWithObjects:stepCountTy,bodyFatTy,bodyMassTy,bloodPressureSystolicTy,bloodPressureDiastolicTy,heartRateTy,sleepTy,nil];
        [self.myStore requestAuthorizationToShareTypes:nil readTypes:allDataTypes completion:^(BOOL success, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateLabel {
    // probably... need to grab the last data....
    HKQuantityType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSDate *today = [NSDate date];
    NSDate *startOfDay = [[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian] startOfDayForDate:today];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startOfDay endDate:today options:HKQueryOptionStrictStartDate];
    NSDateComponents *interval = [[NSDateComponents alloc] init];
    interval.day = 1;
    HKStatisticsCollectionQuery *query = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:type quantitySamplePredicate:predicate options:HKStatisticsOptionCumulativeSum anchorDate:startOfDay intervalComponents:interval];
    query.initialResultsHandler = ^(HKStatisticsCollectionQuery * _Nonnull query, HKStatisticsCollection * _Nullable result, NSError * _Nullable error) {
        if (error != nil) {
            // TODO
        } else {
            [result enumerateStatisticsFromDate:startOfDay toDate:today withBlock:^(HKStatistics * _Nonnull result, BOOL * _Nonnull stop) {
                HKQuantity *quantity = [result sumQuantity];
                double steps = [quantity doubleValueForUnit:[HKUnit countUnit]];
                self.stepCountLabel.text = [NSString stringWithFormat:@"%.20lf", steps];
            }];
        }
    };
    [self.myStore executeQuery:query];
}


@end
