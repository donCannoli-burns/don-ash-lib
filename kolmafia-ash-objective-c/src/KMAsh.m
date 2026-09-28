#import "KMAsh.h"

NSErrorDomain const KMAshErrorDomain = @"KMAshErrorDomain";

static NSError *KMAshMakeError(KMAshErrorCode code, NSString *description) {
    return [NSError errorWithDomain:KMAshErrorDomain
                               code:code
                           userInfo:@{NSLocalizedDescriptionKey: description ?: @"KoLmafia ASH binding error"}];
}

NSString *KMAshCamelCaseFunctionName(NSString *ashName) {
    if (ashName.length == 0 || [ashName rangeOfString:@"_"].location == NSNotFound) {
        return ashName;
    }

    NSArray<NSString *> *parts = [ashName componentsSeparatedByString:@"_"];
    NSMutableString *result = [NSMutableString stringWithString:parts.firstObject ?: @""];
    for (NSUInteger i = 1; i < parts.count; i++) {
        NSString *part = parts[i];
        if (part.length == 0) {
            continue;
        }
        NSString *first = [[part substringToIndex:1] uppercaseString];
        [result appendString:first];
        if (part.length > 1) {
            [result appendString:[part substringFromIndex:1]];
        }
    }
    return result;
}

NSDictionary<NSString *, id> *KMAshEnum(NSString *objectType, NSString *identifierString) {
    return @{ @"objectType": objectType, @"identifierString": identifierString };
}

NSDictionary<NSString *, id> *KMAshEnumID(NSString *objectType, NSInteger identifierNumber) {
    return @{ @"objectType": objectType, @"identifierNumber": @(identifierNumber) };
}

#define KMASH_DEFINE_ENUM_HELPERS(Name, TypeString) \
    NSDictionary<NSString *, id> *KMAsh##Name(NSString *identifier) { \
        return KMAshEnum(@TypeString, identifier); \
    } \
    NSDictionary<NSString *, id> *KMAsh##Name##ID(NSInteger identifier) { \
        return KMAshEnumID(@TypeString, identifier); \
    }

KMASH_DEFINE_ENUM_HELPERS(Item, "Item")
KMASH_DEFINE_ENUM_HELPERS(Skill, "Skill")
KMASH_DEFINE_ENUM_HELPERS(Effect, "Effect")
KMASH_DEFINE_ENUM_HELPERS(Familiar, "Familiar")
KMASH_DEFINE_ENUM_HELPERS(Location, "Location")
KMASH_DEFINE_ENUM_HELPERS(Monster, "Monster")
KMASH_DEFINE_ENUM_HELPERS(Path, "Path")
KMASH_DEFINE_ENUM_HELPERS(Class, "Class")
KMASH_DEFINE_ENUM_HELPERS(Stat, "Stat")
KMASH_DEFINE_ENUM_HELPERS(Slot, "Slot")
KMASH_DEFINE_ENUM_HELPERS(Coinmaster, "Coinmaster")

#undef KMASH_DEFINE_ENUM_HELPERS

@interface KMAshBatch ()
@property (nonatomic, strong) NSMutableArray<NSString *> *properties;
@property (nonatomic, strong) NSMutableArray<NSDictionary<NSString *, id> *> *functions;
@end

@implementation KMAshBatch

- (instancetype)init {
    self = [super init];
    if (self) {
        _properties = [NSMutableArray array];
        _functions = [NSMutableArray array];
    }
    return self;
}

- (void)addProperty:(NSString *)propertyName {
    [self.properties addObject:propertyName];
}

- (void)addCall:(NSString *)ashFunction arguments:(NSArray *)arguments {
    [self.functions addObject:@{
        @"name": KMAshCamelCaseFunctionName(ashFunction),
        @"args": arguments ?: @[]
    }];
}

- (NSDictionary<NSString *, id> *)requestObject {
    NSMutableDictionary<NSString *, id> *request = [NSMutableDictionary dictionary];
    if (self.properties.count > 0) {
        request[@"properties"] = [self.properties copy];
    }
    if (self.functions.count > 0) {
        request[@"functions"] = [self.functions copy];
    }
    return request;
}

@end

@interface KMAshClient ()
@property (nonatomic, readwrite, copy) NSURL *baseURL;
@property (nonatomic, readwrite, copy) NSString *passwordHash;
@property (nonatomic, readwrite) BOOL allowsRemoteEndpoint;
@end

@implementation KMAshClient

- (instancetype)initWithPasswordHash:(NSString *)passwordHash {
    NSError *error = nil;
    KMAshClient *client = [self initWithBaseURL:[NSURL URLWithString:@"http://127.0.0.1:60080"]
                                  passwordHash:passwordHash
                          allowsRemoteEndpoint:NO
                                         error:&error];
    if (!client) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:error.localizedDescription
                                     userInfo:nil];
    }
    return client;
}

+ (BOOL)isLoopbackHost:(NSString *)host {
    if (host.length == 0) {
        return NO;
    }
    NSString *lower = host.lowercaseString;
    return [lower isEqualToString:@"127.0.0.1"] ||
           [lower isEqualToString:@"localhost"] ||
           [lower isEqualToString:@"::1"];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL
                    passwordHash:(NSString *)passwordHash
            allowsRemoteEndpoint:(BOOL)allowsRemoteEndpoint
                           error:(NSError **)error {
    if (baseURL == nil || passwordHash.length == 0) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorInvalidConfiguration,
                                    @"baseURL and passwordHash are required");
        }
        return nil;
    }

    if (!allowsRemoteEndpoint && ![[self class] isLoopbackHost:baseURL.host]) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorRemoteEndpointDenied,
                                    [NSString stringWithFormat:@"Refusing non-loopback KoLmafia endpoint: %@",
                                     baseURL.host ?: @"<missing host>"]);
        }
        return nil;
    }

    self = [super init];
    if (self) {
        _baseURL = [baseURL copy];
        _passwordHash = [passwordHash copy];
        _allowsRemoteEndpoint = allowsRemoteEndpoint;
    }
    return self;
}

- (NSURL *)jsonAPIURL {
    return [NSURL URLWithString:@"/KoLmafia/jsonApi" relativeToURL:self.baseURL].absoluteURL;
}

- (nullable NSData *)formBodyForRequest:(NSDictionary<NSString *, id> *)request error:(NSError **)error {
    if (![NSJSONSerialization isValidJSONObject:request]) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorEncoding, @"Request is not valid JSON");
        }
        return nil;
    }

    NSError *jsonError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:request options:0 error:&jsonError];
    if (!jsonData) {
        if (error) {
            *error = jsonError ?: KMAshMakeError(KMAshErrorEncoding, @"Could not encode request JSON");
        }
        return nil;
    }

    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"body" value:jsonString],
        [NSURLQueryItem queryItemWithName:@"pwd" value:self.passwordHash]
    ];
    NSString *form = components.percentEncodedQuery;
    if (!form) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorEncoding, @"Could not form-url-encode request");
        }
        return nil;
    }
    return [form dataUsingEncoding:NSUTF8StringEncoding];
}

- (nullable NSDictionary<NSString *, id> *)executeRequest:(NSDictionary<NSString *, id> *)request
                                                     error:(NSError **)error {
    NSData *formBody = [self formBodyForRequest:request error:error];
    if (!formBody) {
        return nil;
    }

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[self jsonAPIURL]];
    urlRequest.HTTPMethod = @"POST";
    urlRequest.HTTPBody = formBody;
    [urlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    urlRequest.timeoutInterval = 30.0;

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *responseData = nil;
    __block NSURLResponse *response = nil;
    __block NSError *transportError = nil;

    NSURLSessionDataTask *task = [[NSURLSession sharedSession]
        dataTaskWithRequest:urlRequest
          completionHandler:^(NSData *data, NSURLResponse *urlResponse, NSError *sessionError) {
              responseData = data;
              response = urlResponse;
              transportError = sessionError;
              dispatch_semaphore_signal(semaphore);
          }];
    [task resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (transportError) {
        if (error) {
            *error = [NSError errorWithDomain:KMAshErrorDomain
                                         code:KMAshErrorTransport
                                     userInfo:@{
                                         NSLocalizedDescriptionKey: transportError.localizedDescription ?: @"Transport error",
                                         NSUnderlyingErrorKey: transportError
                                     }];
        }
        return nil;
    }

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger status = ((NSHTTPURLResponse *)response).statusCode;
        if (status < 200 || status >= 300) {
            NSString *text = responseData ? [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] : @"";
            if (error) {
                *error = KMAshMakeError(KMAshErrorHTTP,
                                        [NSString stringWithFormat:@"KoLmafia HTTP %ld%@",
                                         (long)status,
                                         text.length ? [NSString stringWithFormat:@": %@", text] : @""]);
            }
            return nil;
        }
    }

    if (!responseData) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorInvalidResponse, @"KoLmafia returned no response body");
        }
        return nil;
    }

    NSError *jsonError = nil;
    id decoded = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonError];
    if (![decoded isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = jsonError ?: KMAshMakeError(KMAshErrorInvalidResponse,
                                                 @"KoLmafia response was not a JSON object");
        }
        return nil;
    }

    NSDictionary<NSString *, id> *dictionary = decoded;
    NSString *mafiaError = [dictionary[@"error"] isKindOfClass:[NSString class]] ? dictionary[@"error"] : nil;
    if (mafiaError.length > 0) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorKoLmafia, mafiaError);
        }
        return nil;
    }
    return dictionary;
}

- (nullable NSDictionary<NSString *, id> *)executeBatch:(KMAshBatch *)batch
                                                   error:(NSError **)error {
    return [self executeRequest:[batch requestObject] error:error];
}

- (nullable id)call:(NSString *)ashFunction arguments:(NSArray *)arguments error:(NSError **)error {
    NSDictionary *request = @{
        @"functions": @[@{
            @"name": KMAshCamelCaseFunctionName(ashFunction),
            @"args": arguments ?: @[]
        }]
    };
    NSDictionary *response = [self executeRequest:request error:error];
    if (!response) {
        return nil;
    }
    NSArray *values = [response[@"functions"] isKindOfClass:[NSArray class]] ? response[@"functions"] : nil;
    if (values.count < 1) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorInvalidResponse,
                                    @"KoLmafia response did not contain the requested function result");
        }
        return nil;
    }
    return values[0];
}

- (nullable id)property:(NSString *)propertyName error:(NSError **)error {
    NSDictionary *response = [self executeRequest:@{ @"properties": @[propertyName] } error:error];
    if (!response) {
        return nil;
    }
    NSArray *values = [response[@"properties"] isKindOfClass:[NSArray class]] ? response[@"properties"] : nil;
    if (values.count < 1) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorInvalidResponse,
                                    @"KoLmafia response did not contain the requested property result");
        }
        return nil;
    }
    return values[0];
}

- (nullable NSDictionary<NSString *, id> *)identity:(NSDictionary<NSString *, id> *)placeholder
                                               error:(NSError **)error {
    id value = [self call:@"identity" arguments:@[placeholder] error:error];
    if (!value) {
        return nil;
    }
    if (![value isKindOfClass:[NSDictionary class]]) {
        if (error) {
            *error = KMAshMakeError(KMAshErrorTypeMismatch, @"identity() did not return an object");
        }
        return nil;
    }
    return value;
}

- (nullable NSString *)stringCall:(NSString *)name arguments:(NSArray *)arguments error:(NSError **)error {
    id value = [self call:name arguments:arguments error:error];
    if (!value) return nil;
    if (value == [NSNull null]) return @"";
    if (![value isKindOfClass:[NSString class]]) {
        if (error) *error = KMAshMakeError(KMAshErrorTypeMismatch,
                                           [NSString stringWithFormat:@"%@() did not return a string", name]);
        return nil;
    }
    return value;
}

- (nullable NSNumber *)numberCall:(NSString *)name arguments:(NSArray *)arguments error:(NSError **)error {
    id value = [self call:name arguments:arguments error:error];
    if (!value) return nil;
    if (![value isKindOfClass:[NSNumber class]]) {
        if (error) *error = KMAshMakeError(KMAshErrorTypeMismatch,
                                           [NSString stringWithFormat:@"%@() did not return a number", name]);
        return nil;
    }
    return value;
}

- (nullable NSString *)myName:(NSError **)error {
    return [self stringCall:@"my_name" arguments:nil error:error];
}

- (nullable NSNumber *)myLevel:(NSError **)error {
    return [self numberCall:@"my_level" arguments:nil error:error];
}

- (nullable NSNumber *)myAdventures:(NSError **)error {
    return [self numberCall:@"my_adventures" arguments:nil error:error];
}

- (nullable NSNumber *)myMeat:(NSError **)error {
    return [self numberCall:@"my_meat" arguments:nil error:error];
}

- (nullable NSNumber *)availableAmountOf:(NSDictionary<NSString *, id> *)item error:(NSError **)error {
    return [self numberCall:@"available_amount" arguments:@[item] error:error];
}

- (nullable NSString *)getProperty:(NSString *)propertyName error:(NSError **)error {
    return [self stringCall:@"get_property" arguments:@[propertyName] error:error];
}

- (BOOL)setProperty:(NSString *)propertyName value:(NSString *)value error:(NSError **)error {
    id result = [self call:@"set_property" arguments:@[propertyName, value] error:error];
    return result != nil;
}

- (BOOL)cliExecute:(NSString *)command error:(NSError **)error {
    id result = [self call:@"cli_execute" arguments:@[command] error:error];
    if (!result) return NO;
    if ([result isKindOfClass:[NSNumber class]]) return [result boolValue];
    return result == [NSNull null] ? YES : YES;
}

- (nullable NSString *)visitURL:(NSString *)url error:(NSError **)error {
    return [self stringCall:@"visit_url" arguments:@[url] error:error];
}

@end
