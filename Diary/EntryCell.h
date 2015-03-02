//
//  EntryCell.h
//  Diary
//
//  Created by Sherrie Jones on 3/1/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

// forward class entry
@class DiaryEntry;

@interface EntryCell : UITableViewCell

+ (CGFloat)heightForEntry:(DiaryEntry *)entry;

- (void)configureCellForEntry:(DiaryEntry *)entry;

@end




























