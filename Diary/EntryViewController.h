//
//  NewEntryViewController.h
//  Diary
//
//  Created by Sherrie Jones on 2/26/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

// forward class declaration to have access to the DiaryEntry type w/o importing it's class file, then add DiaryEntry property
@class DiaryEntry;

@interface EntryViewController : UIViewController

@property (strong, nonatomic) DiaryEntry *entry;

@end





























