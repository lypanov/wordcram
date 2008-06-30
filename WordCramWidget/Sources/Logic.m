#include "md5.h"
#import "Logic.h"
#import <CoreData/CoreData.h>

int chefScoreSort(NSManagedObject *chef1, NSManagedObject *chef2, void *context);
int chefFromStringSort(NSManagedObject *chef1, NSManagedObject *chef2, void *context);

@implementation Logic

- (Logic*) init {
	m_currentItem = nil;
	m_currentList = nil;
	m_model = nil;
	m_coordinator = nil;
	m_context = nil;
	m_seedAtOne = NO; // need to override this in the tests!
	m_persistentStore = nil;
	m_testSetSizes = nil;
    srandomdev();
    NSError *errorInitializingStack = nil;
    if (![self InitializeCoreDataStack:&errorInitializingStack]) {
		NSString *reason = [NSString stringWithFormat:@"An error occured while initializing a Core Data persistence stack: %@", [errorInitializingStack localizedDescription]];
		[[NSException exceptionWithName:@"Name" reason:reason userInfo:NULL] raise];
	}
	return self;
}

- (void) applyDifference: (int)diff {
	int newVal = [[[self currentItem] valueForKey:@"score"] intValue] + diff;
	[[self currentItem] setValue:[NSNumber numberWithInt:newVal] forKey:@"score"];
	[self save];
}

- (void) save {
	NSError *error;
	if ([m_context save:&error] == NO)
		NSLog(@"Failed to Save due to error: %@", error);
}

- (void) startTests {
	[m_testSetSizeEnum release];
	m_testSetSizeEnum = [m_testSetSizes objectEnumerator];
	[m_testSetSizeEnum retain];
	NSNumber *length = [m_testSetSizeEnum nextObject];
	[self scoreSort];
	[self onlyFirst:[length intValue]];
}
	
- (void) applyDifferenceAndProceed: (int)diff {
	[self applyDifference:diff];
	if ([self nextItem] == nil) {
		NSNumber *length = [m_testSetSizeEnum nextObject];
		if (length == nil)
			return; // FIXME - devise a way to test this sufficiently
		[self scoreSort];
		[self iterateFirst:[length intValue]];
	}
}

- (void) initTestLengths {
	if (m_testSetSizes)
		[m_testSetSizes release];
	m_testSetSizes = [[NSMutableArray alloc] init];
}

- (void) addTestLength: (int)length {
	// rather than modifying all mutators to handle requests > [m_actualArray count] we perform the truncation here already
	[m_testSetSizes addObject:[NSNumber numberWithInt:MIN(length, [m_actualArray count])]];
}

- (NSManagedObject*) nextItem {
	[m_currentItem release];
	m_currentItem = [m_currentList nextObject];
	[m_currentItem retain];
	return m_currentItem;
}

- (void) alphaSort {
	NSArray *sortedChefs = [m_actualArray sortedArrayUsingFunction:chefFromStringSort context:self];
	[m_actualArray release];
	m_actualArray = sortedChefs;
	[m_actualArray retain];
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) randomSort {
	NSMutableArray *shuffleArray = [m_actualArray mutableCopy];
	if (m_seedAtOne)
		srandom(3);
	int idx = 0;
	for (; idx < [shuffleArray count]; idx++)
		[shuffleArray exchangeObjectAtIndex:idx withObjectAtIndex:random() % [shuffleArray count]];
	NSError *errorShufflingChefs = nil;
	if (![self DisplayChefs:shuffleArray error: &errorShufflingChefs]) {
		NSString *reason = [NSString stringWithFormat:@"An error occurred while shuffling all Chefs: %@", [errorShufflingChefs localizedDescription]];
		[[NSException exceptionWithName:@"Name" reason:reason userInfo:NULL] raise];
	}
	[m_actualArray release];
	m_actualArray = shuffleArray;
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];	
	[self nextItem];
}

- (void) scoreSort {
	NSArray *sortedChefs = [m_actualArray sortedArrayUsingFunction:chefScoreSort context:self];
	[m_actualArray release];
	m_actualArray = sortedChefs;
	[m_actualArray retain];
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) iterateFirst: (int)numberOf {
	NSMutableArray *tmp = [m_actualArray mutableCopy];
	[tmp removeObjectsInRange:NSMakeRange(numberOf, [tmp count] - numberOf)];
	[m_currentList release];
	m_currentList = [tmp objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) iterateAll {
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) onlyFirst: (int)numberOf {
	NSMutableArray *tmp = [m_actualArray mutableCopy];
	if (numberOf < [tmp count])
		[tmp removeObjectsInRange:NSMakeRange(numberOf, [tmp count] - numberOf)];
	[m_actualArray release];
	m_actualArray = tmp;
	[m_actualArray retain];
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) load:(NSString*)fileName {
	NSError *error = nil;
	NSMutableArray *chefs = [[NSMutableArray alloc] init];
	if (![self InsertChefAndSave:&error file:fileName digestScores:chefs]) {
		NSString *reason = [NSString stringWithFormat:@"An error occurred while inserting and saving initial dataset: %@", [error localizedDescription]];
		[[NSException exceptionWithName:@"Name" reason:reason userInfo:NULL] raise];
	}
	[m_actualArray release];
	m_actualArray = chefs;
	[m_currentList release];
	m_currentList = [m_actualArray objectEnumerator];
	[m_currentList retain];
	[self nextItem];
}

- (void) clearState {
	NSError *errorKillingChefs = nil;
	[self KillAllChefsReturningError:&errorKillingChefs];
}

- (void) cleanUp {
    [m_model release];
    [m_coordinator release];
    [m_context release];
	[m_testSetSizes release];
	[m_testSetSizeEnum release];
	[m_actualArray release];
}

- (NSManagedObject*) currentItem {
	return m_currentItem;
}

- (void) KillAllChefsReturningError: (NSError**)error {	
	NSArray *chefs = nil;
    
    NSEntityDescription *chefEntity = [NSEntityDescription entityForName:@"DigestScore" inManagedObjectContext:m_context];
	
    NSFetchRequest *allChefsRequest = [[NSFetchRequest alloc] init];
    [allChefsRequest setEntity:chefEntity];
	
    chefs = [m_context executeFetchRequest:allChefsRequest error:error];
	
	NSEnumerator *chefsEnumerator = [chefs objectEnumerator];
    NSManagedObject *chef;    
    while ((chef = [chefsEnumerator nextObject]) != nil)
		[m_context deleteObject:chef];
    
    [allChefsRequest release];
}

- (NSString *) pathForDataFile {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [@"~/Library/Application Support/WordCram/" stringByExpandingTildeInPath];
	if ([fileManager fileExistsAtPath:path] == NO)
		[fileManager createDirectoryAtPath:path attributes:nil];
	return [path stringByAppendingPathComponent:@"Scores.xml"];
}

- (BOOL) InitializeCoreDataStack: (NSError**)error {
    NSArray *bundlesToSearch = [NSArray arrayWithObject:[NSBundle bundleForClass:[self class]]];
    m_model = [NSManagedObjectModel mergedModelFromBundles:bundlesToSearch];
    [m_model retain];
    
    m_coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:m_model];

    m_context = [[NSManagedObjectContext alloc] init];
    [m_context setPersistentStoreCoordinator:m_coordinator];
    
	NSString *path = [self pathForDataFile];
    NSURL *storeURL = [NSURL fileURLWithPath:path];
    m_persistentStore = [m_coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:storeURL options:nil error:error];
    return (m_persistentStore != nil);
}

- (NSManagedObject*) FindDefinitionWithDigest: (NSError**)error digest:(NSData*)digest {
	NSFetchRequest *request = [m_model fetchRequestFromTemplateWithName:@"definitionForDigest" 
									 substitutionVariables:[NSDictionary dictionaryWithObject:digest forKey:@"DIGEST"]];
	NSArray *digestScores = [m_context executeFetchRequest:request error:error];
	if (digestScores == nil) {
		NSLog(@"Request %@ resulted in:\nError == %@", request, error);
		return nil;
	}
	return [[digestScores objectEnumerator] nextObject];
}

- (NSManagedObject*) digestScoreForFromString: (NSString*)fromString {
	NSFetchRequest *request = [m_model fetchRequestFromTemplateWithName:@"definitionForFromString" 
									 substitutionVariables:[NSDictionary dictionaryWithObject:fromString forKey:@"FROM_STRING"]];
	NSError *error;
	NSArray *digestScores = [m_context executeFetchRequest:request error:&error];
	if (digestScores == nil) {
		NSLog(@"Request %@ resulted in:\nError == %@", request, error);
		return nil;
	}
	NSManagedObject *definition = [[digestScores objectEnumerator] nextObject];
	return [self digestScoreForDigest:[definition valueForKey:@"digest"]];
}

- (NSManagedObject*) digestScoreForDigest: (NSData*)digestData {
	NSFetchRequest *request = [m_model fetchRequestFromTemplateWithName:@"digestScoreForDigest" 
									 substitutionVariables:[NSDictionary dictionaryWithObject:digestData forKey:@"DIGEST"]];
	NSError *error;
	NSArray *digestScores = [m_context executeFetchRequest:request error:&error];
	if (digestScores == nil) {
		NSLog(@"Request %@ resulted in:\nError == %@", request, error);
		return nil;
	}
	return [[digestScores objectEnumerator] nextObject];
}

NSData* md5Digest(NSData *inputString) {
	    static const char *const test[7*2] = {
	"", "d41d8cd98f00b204e9800998ecf8427e",
	"a", "0cc175b9c0f1b6a831c399e269772661",
	"abc", "900150983cd24fb0d6963f7d28e17f72",
	"message digest", "f96b697d7cb7938d525a2f31aaf161d0",
	"abcdefghijklmnopqrstuvwxyz", "c3fcd3d76192e4007dfb496cca67e13b",
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
				"d174ab98d277d9f5a5611c2c9f419d9f",
	"12345678901234567890123456789012345678901234567890123456789012345678901234567890", "57edf4a22be3c955ac49da2e2107b67a"
    };
    int i;
    int status = 0;

    for (i = 0; i < 7*2; i += 2) {
	md5_state_t state;
	md5_byte_t digest[16];
	char hex_output[16*2 + 1];
	int di;

	md5_init(&state);
	md5_append(&state, (const md5_byte_t *)test[i], strlen(test[i]));
	md5_finish(&state, digest);
	for (di = 0; di < 16; ++di)
	    sprintf(hex_output + di * 2, "%02x", digest[di]);
	if (strcmp(hex_output, test[i + 1])) {
	    printf("MD5 (\"%s\") = ", test[i]);
	    puts(hex_output);
	    printf("**** ERROR, should be: %s\n", test[i + 1]);
	    status = 1;
	}
    }
    if (status == 0)
	puts("md5 self-test completed successfully.");
	return inputString;
}

- (BOOL) InsertChefAndSave: (NSError**)error file:(NSString*)fileName digestScores:(NSMutableArray*)digestScores {
	NSData *data = [NSData dataWithContentsOfFile:fileName];

	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSScanner *scanner = [NSScanner scannerWithString:string];
	NSString *fromString, *toString;
	
	while (![scanner isAtEnd]) {
		[scanner scanUpToString:@"|" intoString:&fromString];
		[scanner scanString:@"|" intoString:nil];
		[scanner scanUpToString:@"\n" intoString:&toString];
		[scanner scanString:@"\n" intoString:nil];

		NSData *plaintext, *digest;
		plaintext = [[fromString stringByAppendingString:toString] dataUsingEncoding:NSUTF8StringEncoding];
		digest    = md5Digest(plaintext);
		
		NSManagedObject *existingDigestScore = [self digestScoreForDigest:digest];
		if (existingDigestScore != nil) {
			[digestScores addObject:existingDigestScore];
			continue;
		}

		NSManagedObject *digestScore;
		digestScore = [NSEntityDescription insertNewObjectForEntityForName:@"DigestScore" inManagedObjectContext:m_context];
		[digestScore setValue:[NSNumber numberWithShort:0] forKey:@"score"];
		[digestScore setValue:digest forKey:@"digest"];
		[digestScores addObject:digestScore];

		NSManagedObject *definition;
		definition = [NSEntityDescription insertNewObjectForEntityForName:@"Definition" inManagedObjectContext:m_context];
		[definition setValue:fromString forKey:@"fromString"];
		[definition setValue:toString forKey:@"toString"];
		[definition setValue:digest forKey:@"digest"];
	
		if ([m_context save:error] == NO) {
			[m_context deleteObject:digestScore];
			[m_context deleteObject:definition];
			return NO;
		}
    }
	
    return YES;
}

- (BOOL) DisplayChefs: (NSArray*)chefs error:(NSError**)error {
    NSLog(@"Chefs found: %u", [chefs count]);
    
    NSEnumerator *chefsEnumerator = [chefs objectEnumerator];
    NSManagedObject *chef;
    
    while ((chef = [chefsEnumerator nextObject]) != nil) {
        NSLog(@"Found DigestScore: %@ (%@)", [chef valueForKey:@"digest"], [chef valueForKey:@"score"]);
		NSManagedObject *definition = [self FindDefinitionWithDigest: error digest:[chef valueForKey:@"digest"]];
		if (definition == nil)
			return NO;
		NSLog(@"Found Definition for digest: %@ (%@)", [definition valueForKey:@"fromString"], [definition valueForKey:@"toString"]);
    }
	
	return YES;
}

- (void) display {
	NSError *error;
	[self DisplayChefs:m_actualArray error:&error];
}

@end

int chefScoreSort(NSManagedObject *chef1, NSManagedObject *chef2, void *context)
{
	int result = [[chef1 valueForKey:@"score"] compare:[chef2 valueForKey:@"score"]];
	if (result == NSOrderedSame)
		result = chefFromStringSort(chef1, chef2, context);
    return result;
}

int chefFromStringSort(NSManagedObject *chef1, NSManagedObject *chef2, void *context)
{
	NSError *error = nil;
	id blah = (id) context;
	NSManagedObject *definition1 = [blah FindDefinitionWithDigest:&error digest:[chef1 valueForKey:@"digest"]];
	if (definition1 == nil) {
		NSLog(@"Failed to find definition with digest: %@", [chef1 valueForKey:@"digest"]);
	}
	NSManagedObject *definition2 = [blah FindDefinitionWithDigest: &error digest: [chef2 valueForKey:@"digest"]];
	if (definition2 == nil) {
		NSLog(@"Failed to find definition with digest: %@", [chef2 valueForKey:@"digest"]);
	}
	return [[definition1 valueForKey:@"fromString"] compare:[definition2 valueForKey:@"fromString"]];
}
