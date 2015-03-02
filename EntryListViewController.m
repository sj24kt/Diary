//
//  EntryListViewController.m
//  Diary
//
//  Created by Sherrie Jones on 2/28/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "EntryListViewController.h"
#import "CoreDataStack.h"
#import "DiaryEntry.h"
#import "EntryViewController.h"
#import "EntryCell.h"

@interface EntryListViewController () <NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@end

@implementation EntryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // executes the performFetch method
    [self.fetchedResultsController performFetch:nil];
}

// called whenever the edit segue is performed. Grab cell that was tapped & indexPath of cell, then configure the entryViewController with that entry
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"edit"]) {

        UITableViewCell *cell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

        UINavigationController *navigationController = segue.destinationViewController;
        EntryViewController *entryViewController = (EntryViewController *)navigationController.topViewController;
        entryViewController.entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";
    EntryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    DiaryEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureCellForEntry:entry];

    return cell;
}

// calculates the prototype cell height based on content
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiaryEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];

    return [EntryCell heightForEntry:entry];
}

// to delete a row using CoreDate, must use these two methods
// UITableViewDelegate - delete row (shows red cirlce with minus sign and swipes)
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// UITableViewDataSource -
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    // 3 steps to delete - get object we want to delete
    DiaryEntry *entry = [self.fetchedResultsController objectAtIndexPath:indexPath];

    // then get the coreDataStack
    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];

    // to delete an object, call the delete object method on the coreDataStack managedObjectContext
    [[coreDataStack managedObjectContext] deleteObject:entry];

    // finally save the context - changes are immediately reflected in the persistent store
    [coreDataStack saveContext];
}

// returns each section header's name to the fetchedResultsController
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

    return [sectionInfo name];
}

#pragma mark - Helper methods

// for each diary entry, sort by date in descending order
- (NSFetchRequest *)entryListFetchRequest {

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DiaryEntry"];

    // create an array and sort by date in descending order
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];

    return fetchRequest;
}

// using lazy loader creates new fetchedResultsController if one hasn't already been created
- (NSFetchedResultsController *)fetchedResultsController {

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    CoreDataStack *coreDataStack = [CoreDataStack defaultStack];
    NSFetchRequest *fetchRequest = [self entryListFetchRequest];

    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:coreDataStack.managedObjectContext sectionNameKeyPath:@"sectionName" cacheName:nil];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

// 4 steps to update tableView with animation - beginUpdates
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

// called whenever a row is inserted/deleted/changed/moved
- (void) controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            break;

//        default:
//            break;
    }
}

// called whenever a section is inserted/deleted/changed/moved
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        default:
            break;
    }
}

// updates the tableView whenever the content changes
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end





























