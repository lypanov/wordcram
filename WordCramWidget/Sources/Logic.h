#import <Cocoa/Cocoa.h>

@interface Logic : NSObject {
	NSManagedObject *m_currentItem;
	NSEnumerator *m_currentList;
	NSArray *m_actualArray;

	BOOL m_seedAtOne;

	NSEnumerator *m_testSetSizeEnum;
	NSMutableArray *m_testSetSizes;
	int m_remainingTests;
	NSManagedObjectModel *m_model;
	NSPersistentStoreCoordinator *m_coordinator;
	NSManagedObjectContext *m_context;
	id m_persistentStore;
}

- (void) cleanUp;
- (Logic*) init;
- (void) initTestLengths;
- (void) addTestLength: (int)length;
- (int) remainingTests;
- (void) clearState;
- (void) load:(NSString*)fileName;
- (void) save;
- (NSString *) pathForDataFile;
- (void) alphaSort;
- (void) randomSort;
- (void) scoreSort;
- (void) startTests;
- (void) applyDifference: (int)diff;
- (void) applyDifferenceAndProceed: (int)diff;
- (void) onlyFirst: (int)numberOf;
- (NSManagedObject*) digestScoreForFromString: (NSString*)fromString;
- (NSManagedObject*) digestScoreForDigest: (NSData*)digestData;
- (void) iterateAll;
- (void) iterateFirst: (int)numberOf;
- (void) KillAllChefsReturningError: (NSError**)error;
- (BOOL) InitializeCoreDataStack: (NSError**)error;
- (BOOL) DisplayChefs: (NSArray*)chefs error:(NSError**)error;
- (BOOL) InsertChefAndSave: (NSError**)error file:(NSString*)fileName digestScores:(NSMutableArray*)digestScores;
- (NSManagedObject*) FindDefinitionWithDigest: (NSError**)error digest:(NSData*)digest;
- (NSManagedObject*) nextItem;
- (NSManagedObject*) currentItem;
- (void) display;

@end
