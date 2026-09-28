#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const KMAshErrorDomain;

typedef NS_ERROR_ENUM(KMAshErrorDomain, KMAshErrorCode) {
    KMAshErrorInvalidConfiguration = 1,
    KMAshErrorRemoteEndpointDenied = 2,
    KMAshErrorEncoding = 3,
    KMAshErrorTransport = 4,
    KMAshErrorHTTP = 5,
    KMAshErrorInvalidResponse = 6,
    KMAshErrorKoLmafia = 7,
    KMAshErrorTypeMismatch = 8,
};

/// Converts an ASH-style name such as `available_amount` to KoLmafia's
/// Browser JSON API function spelling (`availableAmount`). Names without an
/// underscore are returned unchanged.
FOUNDATION_EXPORT NSString *KMAshCamelCaseFunctionName(NSString *ashName);

/// Creates a KoLmafia enumerated-value placeholder using identifierString.
FOUNDATION_EXPORT NSDictionary<NSString *, id> *KMAshEnum(NSString *objectType,
                                                           NSString *identifierString);

/// Creates a KoLmafia enumerated-value placeholder using identifierNumber.
FOUNDATION_EXPORT NSDictionary<NSString *, id> *KMAshEnumID(NSString *objectType,
                                                             NSInteger identifierNumber);

#define KMASH_DECLARE_ENUM_HELPERS(Name) \
    FOUNDATION_EXPORT NSDictionary<NSString *, id> *KMAsh##Name(NSString *identifier); \
    FOUNDATION_EXPORT NSDictionary<NSString *, id> *KMAsh##Name##ID(NSInteger identifier)

KMASH_DECLARE_ENUM_HELPERS(Item);
KMASH_DECLARE_ENUM_HELPERS(Skill);
KMASH_DECLARE_ENUM_HELPERS(Effect);
KMASH_DECLARE_ENUM_HELPERS(Familiar);
KMASH_DECLARE_ENUM_HELPERS(Location);
KMASH_DECLARE_ENUM_HELPERS(]onster);
KMASH_DECLARE_ENUM_HELPERS(Path);
KMASH_DECLARE_ENUM_HELPERS(Class);
KMASH_DECLARE_ENUM_HELPERS(Stat);
KMASH_DECLARE_ENUM_HELPERS(Slot);
KMASH_DECLARE_ENUM_HELPERS(Coinmaster);

#undef KMASH_DECLARE_ENUM_HELPERS

@interface KMAshBatch : NSObject

- (void)addProperty:(NSString *)propertyName;
- (void)addCall:(NSString *)ashFunction arguments:(nullable NSArray *)arguments;
- (NSDictionary<NSString *, id> *)requestObject;

@end

@interface KMAshClient : NSObject

@property (nonatomic, readonly, copy) NSURL *baseURL;
@property (nonatomic, readonly, copy) NSString *passwordHash;
@property (nonatomic, readonly) BOOL allowsRemoteEndpoint;

/// Uses http://127.0.0.1:60080 and denies non-loopback endpoints.
- (instancetype)initWithPasswordHash:(NSString *)passwordHash;

/// Designated initializer. Remote hosts are denied unless explicitly enabled.
- (nullable instancetype)initWithBaseURL:(NSURL *)baseURL
                            passwordHash:(NSString *)passwordHash
                    allowsRemoteEndpoint:(BOOL)allowsRemoteEndpoint
                                   error:(NSError **)error NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Executes the raw Browser JSON API request object.
- (nullable NSDictionary<NSString *, id> *)executeRequest:(NSDictionary<NSString *, id> *)request
                                                     error:(NSError **)error;

/// Executes a prepared batch in one HTTP round trip.
- (nullable NSDictionary<NSString *, id> *)executeBatch:(KMAshBatch *)batch
                                                   error:(NSError **)error;

/// Calls a KoLmafia runtime function. Pass ASH-style snake_case or the
/// Browser JSON API camelCase name. Returns NSNull for void/null results.
- (nullable id)call:(NSString *)ashFunction
          arguments:(nullable NSArray *)arguments
              error:(NSError **)error;

/// Reads one KoLmafia property through the Browser JSON API.
- (nullable id)property:(NSString *)propertyName error:(NSError **)error;

/// Expands an enum placeholder to its full KoLmafia enum object.
- (nullable NSDictionary<NSString *, id> *)identity:(NSDictionary<NSString *, id> *)placeholder
                                               error:(NSError **)error;

#pragma mark - Common typed reads

- (nullable NSString *)myName:(NSError **)error;
- (nullable NSNumber *)myLevel:(NSError **)error;
- (nullable NSNumber *)myAdventures:(NSError **)error;
- (nullable NSNumber *)myMeat:(NSError **)error;
- (nullable NSNumber *)availableAmountOf:(NSDictionary<NSString *, id> *)item error:(NSError **)error;
- (nullable NSString *)getProperty:(NSString *)propertyName error:(NSError **)error;

#pragma mark - Explicitly mutating / effectful surfaces

/// Writes a KoLmafia preference via set_property().
- (BOOL)setProperty:(NSString *)propertyName value:(NSString *)value error:(NSError **)error;

/// Executes a gCLI command through cli_execute(). This can mutate game state.
- (BOOL)cliExecute:(NSString *)command error:(NSError **)error;

/// Calls visit_url(). This may mutate game state depending on the URL.
- (nullable NSString *)visitURL:(NSString *)url error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
