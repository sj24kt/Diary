//
//  EntryCell.m
//  Diary
//
//  Created by Sherrie Jones on 3/1/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "EntryCell.h"
#import "DiaryEntry.h"
#import <QuartzCore/QuartzCore.h>

@interface EntryCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mainImageView;
@property (weak, nonatomic) IBOutlet UIImageView *moodImageView;


@end

@implementation EntryCell

+ (CGFloat)heightForEntry:(DiaryEntry *)entry {
    const CGFloat topMargin = 37.0f;
    const CGFloat bottomMargin = 80.0f;
    const CGFloat minHeight = 100.0f;

    UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];

    // calculate the bounding box of the body text size
    CGRect boundingBox = [entry.body boundingRectWithSize:CGSizeMake(300, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil];

    return MAX(minHeight, CGRectGetHeight(boundingBox) + topMargin + bottomMargin);
}

- (void)configureCellForEntry:(DiaryEntry *)entry {
    self.bodyLabel.text = entry.body;
    self.locationLabel.text = entry.location;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM d, yyyy"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:entry.date];

    self.dateLabel.text = [dateFormatter stringFromDate:date];

    if (entry.imageData) {
        self.mainImageView.image = [UIImage imageWithData:entry.imageData];
    } else {
        self.mainImageView.image = [UIImage imageNamed:@"icn_noimage"];
    }

    if (entry.mood == DiaryEntryMoodGood) {
        self.moodImageView.image = [UIImage imageNamed:@"icn_happy"];
    } else if (entry.mood == DiaryEntryMoodAverage) {
        self.moodImageView.image = [UIImage imageNamed:@"icn_average"];
    } else if (entry.mood == DiaryEntryMoodBad) {
        self.moodImageView.image = [UIImage imageNamed:@"icn_bad"];
    }

    // round corners of images
    self.mainImageView.layer.cornerRadius = CGRectGetWidth(self.mainImageView.frame) / 2.0f;

    // check if geocoder location placename exists
    if (entry.location.length > 0) {
        self.locationLabel.text = entry.location;
    } else {
        self.locationLabel.text = @"No location";
    }
}

@end


























