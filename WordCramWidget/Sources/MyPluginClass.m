#import "MyPluginClass.h"
#import "Logic.h"

@implementation MyPluginClass

-(id)initWithWebView:(WebView*)w {
	NSLog(@"WordCram plugin loaded!\n");
	self = [super init];
	logic = [[Logic alloc] init];
	return self;
}

-(void)dealloc {
	[fileName release];
	[logic cleanUp];
	[logic release];
	[super dealloc];
}

-(NSString*) testsDirectory {
	NSString *bundlePath = [[NSBundle bundleForClass:[self class]] bundlePath];
	return [[bundlePath stringByDeletingLastPathComponent] stringByAppendingString:@"/"];
}

-(NSString*) userTestsDirectory {
	NSString *path = [[@"~/Library/Application Support/WordCram/" stringByExpandingTildeInPath] stringByAppendingString:@"/"];
	return path;
} 

-(void)windowScriptObjectAvailable:(WebScriptObject*)wso {
	[wso setValue:self forKey:@"FortunePlugin"];
}

+(NSString*)webScriptNameForSelector:(SEL)aSel {
	NSString *retval = nil;
	if (aSel == @selector(getAnswerAndScoreIt:)) {
		retval = @"getAnswerAndScoreIt";
	} else if (aSel == @selector(getNewQuestion)) {
		retval = @"getNewQuestion";
	} else if (aSel == @selector(restartTests)) {
		retval = @"restartTests";		
	} else if (aSel == @selector(setFileName:)) {
		retval = @"setFileName";
	} else if (aSel == @selector(setOtherDirection:)) {
		retval = @"setOtherDirection";
	} else if (aSel == @selector(availableTests)) {
		retval = @"availableTests";
	} else if (aSel == @selector(remainingCount)) {
		retval = @"remainingCount";		
	} else {
		NSLog(@"\tunknown selector");
	}
	
	return retval;
}

+(BOOL)isSelectorExcludedFromWebScript:(SEL)aSel {	
	if (aSel == @selector(setOtherDirection:)
	 || aSel == @selector(getAnswerAndScoreIt:)
	 || aSel == @selector(getNewQuestion)
	 || aSel == @selector(restartTests)
	 || aSel == @selector(setFileName:)
	 || aSel == @selector(availableTests) 
	 || aSel == @selector(remainingCount)) {
		return NO;
	}
	return YES;
}

-(NSArray *) availableTests {
	NSMutableArray *chefs = [[NSMutableArray alloc] init];	
	NSString *pname;
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:[self testsDirectory]];
	while (pname = [direnum nextObject]) {
		if ([pname rangeOfString:@".txt"].location == NSNotFound)
			continue;
		[chefs addObject:[[self testsDirectory] stringByAppendingString:pname]];
	}
	NSDirectoryEnumerator *userdirenum = [[NSFileManager defaultManager] enumeratorAtPath:[self userTestsDirectory]];
	while (pname = [userdirenum nextObject]) {
		if ([pname rangeOfString:@".txt"].location == NSNotFound)
			continue;
		[chefs addObject:[[self userTestsDirectory] stringByAppendingString:pname]];
	}
	return chefs;
}

+(BOOL)isKeyExcludedFromWebScript:(const char*)k {
	return YES;
}

- (NSString *) fromStringForDigestScore: (NSManagedObject*)digestScore {
	NSError *error;
	NSManagedObject *definition = [logic FindDefinitionWithDigest: &error digest: [digestScore valueForKey:@"digest"]];
	if (definition == nil) {
		NSLog(@"Failed to find definition with digest: %@", [digestScore valueForKey:@"digest"]);
	}
	return m_otherDirection ? [definition valueForKey:@"toString"] : [definition valueForKey:@"fromString"];
}

- (NSString *) toStringForDigestScore: (NSManagedObject*)digestScore {
	NSError *error;
	NSManagedObject *definition = [logic FindDefinitionWithDigest: &error digest: [digestScore valueForKey:@"digest"]];
	if (definition == nil) {
		NSLog(@"Failed to find definition with digest: %@", [digestScore valueForKey:@"digest"]);
	}
	return m_otherDirection ? [definition valueForKey:@"fromString"] : [definition valueForKey:@"toString"];
}

- (NSString *) getAnswerAndScoreIt:(NSNumber*)score {
	NSString *answer;
	answer = [self toStringForDigestScore:[logic currentItem]];
	[logic applyDifferenceAndProceed:[score intValue]];
	return answer;
}

- (void) restartTests {
	[logic load:fileName];
	[logic initTestLengths];
	[logic addTestLength:8];
 	[logic addTestLength:3];
 	[logic addTestLength:2];
 	[logic addTestLength:1];
	[logic startTests];
}

- (int) remainingCount {
	return [logic remainingTests];
}

- (BOOL) otherDirection {
	return m_otherDirection;
}

- (void) setOtherDirection:(BOOL) otherDirection {
	m_otherDirection = otherDirection;
}

- (NSString *) getNewQuestion {
	NSManagedObject *questionDigestScore = [logic currentItem];
	if (questionDigestScore == nil) {
		return nil;
	}
	NSString *question = [self fromStringForDigestScore:questionDigestScore];
	return question;
}

- (void)setFileName:(NSString*)_fileName {
	[fileName release];
	fileName = _fileName;
	[fileName retain];
}

@end
