#import "Tests.h"
#import "Logic.h"

@implementation Tests

- (NSString *) fromStringForDigestScore: (NSManagedObject*)digestScore logic:(Logic*)logic {
	NSError *error;
	NSManagedObject *definition = [logic FindDefinitionWithDigest: &error digest: [digestScore valueForKey:@"digest"]];
	if (definition == nil) {
		NSLog(@"Failed to find definition with digest: %@", [digestScore valueForKey:@"digest"]);
	}
	return [definition valueForKey:@"fromString"];
}

- (void) testInit
{	
	Logic *logic = [[Logic alloc] init];
	[logic release];
}

- (void) testLoadAndAlphaSort
{	
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	[logic onlyFirst: 5];
	NSString *fromString;
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"oranje", @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"pars",   @"Didn't work, dude", fromString); [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic release];
}

- (void) testShuffle
{	
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	[logic onlyFirst: 5];
	[logic randomSort];
	NSString *fromString;
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"pars",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"oranje", @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString); [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic release];
}

- (void) testDigestForFromString
{	
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	NSManagedObject *digestScore = [logic digestScoreForFromString: @"blauw"];
	STAssertEqualObjects([[logic currentItem] objectID], [digestScore objectID], @"Didn't work, dude: %@ != %@", [logic currentItem], digestScore);
	[logic release];
}

- (void) testSortByScore {
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	[logic onlyFirst:5];
	NSManagedObject *blauw  = [logic digestScoreForFromString: @"blauw"];
	[blauw setValue:[NSNumber numberWithInt:5] forKey:@"score"];
	NSManagedObject *geel   = [logic digestScoreForFromString: @"geel"];
	[geel setValue:[NSNumber numberWithInt:2] forKey:@"score"];
	NSManagedObject *groen = [logic digestScoreForFromString: @"groen"];
	[groen setValue:[NSNumber numberWithInt:3] forKey:@"score"];
	NSManagedObject *oranje = [logic digestScoreForFromString: @"oranje"];
	[oranje setValue:[NSNumber numberWithInt:1] forKey:@"score"];
	[logic scoreSort];
	NSString *fromString;
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"pars",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"oranje",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel", @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString); [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic release];
}

- (void) testIterateFirst {
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	[logic iterateFirst:3];
	NSString *fromString;
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString); [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic release];
}

- (void) testIterateAll {
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic alphaSort];
	[logic onlyFirst:5];
	[logic iterateFirst:3];
	[logic nextItem]; [logic nextItem]; [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic iterateAll];
	NSString *fromString;
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"oranje", @"Didn't work, dude", fromString); [logic nextItem];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"pars",   @"Didn't work, dude", fromString); [logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	[logic release];
}

#define INITIAL_SET_SIZE 12

- (void) testWidgetUsecase {
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic scoreSort];
	[logic onlyFirst:3];
	[logic iterateFirst:2];
	NSString *fromString;
	
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString);
	[[logic currentItem] setValue:[NSNumber numberWithInt:5] forKey:@"score"];
	[logic save];
	[logic nextItem];
	
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString);
	[[logic currentItem] setValue:[NSNumber numberWithInt:4] forKey:@"score"];
	[logic save];
	[logic nextItem];
	
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	
	[logic scoreSort];
	[logic iterateFirst:1];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString);
	[logic nextItem];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);

	[logic release];
}

- (void) testWidgetAbstraction {
	Logic *logic = [[Logic alloc] init];
	[logic clearState];
	[logic load];
	[logic addTestLength:3];
	[logic addTestLength:2];
	[logic addTestLength:1];
	[logic startTests];
	
	NSString *fromString;	
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"blauw",  @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:1];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:-1];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",  @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:0];
	//
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",  @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:1];
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"groen",   @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:0];
	//
	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:0];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	
	[logic cleanUp];
	[logic release];
	
	logic = [[Logic alloc] init];	
	[logic load]; // load without clearing state!
	[logic addTestLength:1];
	[logic startTests];

	fromString = [self fromStringForDigestScore:[logic currentItem] logic:logic]; STAssertEqualObjects(fromString, @"geel",   @"Didn't work, dude", fromString);
	[logic applyDifferenceAndProceed:0];
	STAssertEqualObjects([logic currentItem], nil, @"Didn't work, dude", [logic currentItem]);
	
	[logic release];
}

@end
