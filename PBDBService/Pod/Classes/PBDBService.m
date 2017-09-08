//
//  PBDBService.m
//  PBDBService
//
//  Created by nanhujiaju on 2016/9/8.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import "PBDBService.h"
#import <FMDB/FMTokenizers.h>
#import <sqlite3.h>

static BOOL mUSE_DEFAULT_DB;
static BOOL mENCYPT_DEBUG_MODE;

#ifndef PB_DB_ENCRYPT
#ifdef DEBUG
#define PB_DB_ENCRYPT  0
#else
#define PB_DB_ENCRYPT  1
#endif
#endif

@interface PBDBService ()

/**
 the global db queue
 */
@property (nonatomic, strong, readwrite) FMDatabaseQueue *dbQueue;

@end

static PBDBService * instance = nil;
static dispatch_once_t onceToken;
//cipher hard code was not safe, it should be managment by the 'cipher sdk'
static NSString * const PB_DB_CIPHER               =   @"com.nanhu.app-ios.db.cipher";
static NSString * const PB_DB_DEFAULT_NAME         =   @"com.nanhu.app.db";

@implementation PBDBService

+ (void)enableDebugEncryptMode:(BOOL)enable {
    mENCYPT_DEBUG_MODE = enable;
}

+ (PBDBService *)shared {
    mUSE_DEFAULT_DB = true;
    //static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PBDBService alloc] init];
        NSString *path = [instance dbFilePath:PB_DB_DEFAULT_NAME];
        //[[NSFileManager defaultManager] setAttributes:[NSDictionary dictionaryWithObject:NSFileProtectionNone forKey:NSFileProtectionKey] ofItemAtPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents"] error:NULL];
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
        instance.dbQueue = queue;
        [instance setupDBEnDecryptKey];
    });
    
    return instance;
}

+ (void)released {
    instance = nil; onceToken = 0;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (NSString *)homeDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    return paths.firstObject;
}

+ (BOOL)setupDB4Path:(NSString *)path {
    NSAssert(path.length > 0, @"db path is nil!");
    NSLog(@"app database path:%@",path);
    mUSE_DEFAULT_DB = false;
    __block BOOL ret = false;
    //static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PBDBService alloc] init];
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:path];
        ret = queue != nil;instance.dbQueue = queue;
        [instance setupDBEnDecryptKey];
    });
    return ret;
}

- (BOOL)setupDBEnDecryptKey {
    __block BOOL ret = false;
    
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        [db beginTransaction];
        NSString *t_db_version = @"CREATE TABLE IF NOT EXISTS t_db_version (id INTEGER NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE, max TEXT DEFAULT NULL, mid TEXT DEFAULT NULL, min TEXT DEFAULT NULL)";
        ret &= [db executeUpdate:t_db_version];
        [db commit];
    }];
    
    return ret;
}

#pragma mark -- path
- (NSString *)dbFilePath:(NSString *)file {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *filePath = [[paths firstObject] stringByAppendingPathComponent:file];
    return filePath;
}

#pragma mark -- create tables

- (BOOL)isTableExist:(NSString *)table {
    __block BOOL ret = false;
    if (table.length == 0) {
        return ret;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        ret = [db tableExists:table];
        NSLog(@"is table %@ exist:%zd", table,ret);
    }];
    return ret;
}

- (BOOL)createTables:(NSArray<NSString *> *)sqls {
    __block BOOL ret = false;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        //[db setShouldCacheStatements:true];
        NSEnumerator *enumrator = [sqls objectEnumerator];
        NSString *sql = nil;
        while (sql = [enumrator nextObject]) {
            ret |= [db executeUpdate:sql];
            NSLog(@"create table %@ result:%zd", sql,ret);
        }
    }];
    
    return ret;
}

//declaration
void initializedSimpleTokenizerForDB(FMDatabase *db) {
    static FMSimpleTokenizer *tokenizer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tokenizer = [[FMSimpleTokenizer alloc] initWithLocale:NULL];
    });
    
    [FMDatabase registerTokenizer:tokenizer withKey:@"simple"];
    BOOL mRet = [db installTokenizerModule];
    NSLog(@"init tokenizer result:%d", mRet);
}

- (BOOL)createTables:(NSArray<NSString *> *)sqls wetherFTS:(BOOL)fts {
    if (!fts) {
        return [self createTables:sqls];
    }
    
    __block BOOL ret = false;
    //__weak typeof(PBDBService) *weakSelf = self;
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        //[db setKey:PB_DB_CIPHER];
        //[db setShouldCacheStatements:true];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        initializedSimpleTokenizerForDB(db);
        
        NSEnumerator *enumrator = [sqls objectEnumerator];
        NSString *sql = nil;
        while (sql = [enumrator nextObject]) {
            ret |= [db executeUpdate:sql];
            NSLog(@"create fts table %@ result:%zd", sql,ret);
        }
    }];
    
    return ret;
}

- (BOOL)dropTable:(NSString *)table {
    __block BOOL ret = false;
    if (table.length == 0) {
        return ret;
    }
    NSString *mSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",table];
    NSString *mSequence = [NSString stringWithFormat:@"UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = '%@'", table];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        ret = [db executeUpdate:mSql, mSequence];
        if (!ret) {
            *rollback = true;
        }
    }];
    return ret;
}

- (BOOL)cleanTable:(NSString *)table {
    __block BOOL ret = false;
    if (table.length == 0) {
        return ret;
    }
    NSString *mSql = [NSString stringWithFormat:@"DELETE FROM %@",table];
    NSString *mSequence = [NSString stringWithFormat:@"UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = '%@'", table];
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        ret = [db executeUpdate:mSql, mSequence];
        if (!ret) {
            *rollback = true;
        }
    }];
    return ret;
}

- (BOOL)whetherColumn:(NSString *)col existInTable:(NSString *)table {
    __block BOOL ret = false;
    if (table.length == 0 || col.length == 0) {
        return ret;
    }
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        ret = [db columnExists:col inTableWithName:table];
        NSLog(@"is table %@ exist:%zd", table,ret);
    }];
    return ret;
}

- (void)begainTransaction:(void (^)(FMDatabase * _Nonnull, BOOL * _Nonnull))block {
    [self.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        //[db setKey:PB_DB_CIPHER];
        if (PB_DB_ENCRYPT) {
            [db setKey:PB_DB_CIPHER];
        } else {
            if (mENCYPT_DEBUG_MODE) {
                [db setKey:PB_DB_CIPHER];
            }
        }
        block(db, rollback);
    }];
}

#pragma mark -- Util Methods

- (NSDateFormatter *)defaultDateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    });
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return formatter;
}

- (NSDateFormatter *)dateFormatter4Style:(NSString *)style {
    if (style.length == 0) {
        return self.defaultDateFormatter;
    }
    self.defaultDateFormatter.dateFormat = style;
    return self.defaultDateFormatter;
}

@end
