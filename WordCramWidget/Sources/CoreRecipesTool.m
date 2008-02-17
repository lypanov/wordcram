#import "Logic.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int result = EXIT_SUCCESS;
	Logic *logic = [[Logic alloc] init];
	@try {
		[logic doStuff];
	} 
	@catch (NSException * e) {
		NSLog(@"Threw one! - %@", e);
		result = EXIT_FAILURE;
	}
	
	[logic cleanUp];
	[pool release];    

    return result;
}

