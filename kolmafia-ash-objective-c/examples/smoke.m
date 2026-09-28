#import <Foundation/Foundation.h>
#import "KMAsh.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSString *pwd = NSProcessInfo.processInfo.environment[@"KOLMAFIA_PWD"];
        if (pwd.length == 0) {
            fprintf(stderr, "Set KOLMAFIA_PWD to the active KoLmafia pwd hash.\n");
            return 2;
        }

        KMAshClient *mafia = [[KMAshClient alloc] initWithPasswordHash:pwd];
        NSError *error = nil;

        NSString *name = [mafia myName:&error];
        NSNumber *level = [mafia myLevel:&error];
        NSNumber *adventures = [mafia myAdventures:&error];
        if (!name || !level || !adventures) {
            fprintf(stderr, "KoLmafia call failed: %s\n", error.localizedDescription.UTF8String);
            return 1;
        }

        NSLog(@"%@ — level %@ — %@ adventures", name, level, adventures);

        NSDictionary *club = KMAshItem(@"seal-clubbing club");
        NSNumber *amount = [mafia availableAmountOf:club error:&error];
        if (!amount) {
            fprintf(stderr, "available_amount failed: %s\n", error.localizedDescription.UTF8String);
            return 1;
        }
        NSLog(@"seal-clubbing clubs available: %@", amount);

        KMAshBatch *batch = [[KMAshBatch alloc] init];
        [batch addProperty:@"kingLiberated"];
        [batch addCall:@"my_meat" arguments:nil];
        [batch addCall:@"get_property" arguments:@[@"lastAdventure"]];

        NSDictionary *result = [mafia executeBatch:batch error:&error];
        if (!result) {
            fprintf(stderr, "batch failed: %s\n", error.localizedDescription.UTF8String);
            return 1;
        }
        NSLog(@"batch = %@", result);
    }
    return 0;
}
