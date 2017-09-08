//
//  PBDBService.h
//  PBDBService
//
//  Created by nanhujiaju on 2016/9/8.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import <FMDB/FMDB.h>

/**
 *  DB Engine just implement a few of fucntions about Thread-Safely Queue
 *
 *  to use more function please write a category for FLKDBService
 *
 */
@interface PBDBService : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 the app's home directory
 
 @return result
 */
+ (NSString *)homeDirectoryPath;

/**
 wether enable encrypt mode for debug mode, default is no
 
 @param enable :wether enable
 */
+ (void)enableDebugEncryptMode:(BOOL)enable;

/**
 create DB instance for path
 
 @param path the db's path, will use the default path when its nil
 */
+ (BOOL)setupDB4Path:(NSString *)path;

/**
 singletone mode
 
 @return the instance
 */
+ (PBDBService *)shared;

/**
 release instance
 */
+ (void)released;

/**
 create tables by sqls
 
 @param sqls the tabel sql
 @param fts wether the table support fts
 @return result
 */
- (BOOL)createTables:(NSArray<NSString *> *)sqls wetherFTS:(BOOL)fts;

/**
 wether db contains the table
 
 @param table name
 @return result
 */
- (BOOL)isTableExist:(NSString *)table;

/**
 drop table
 
 @param table name
 @return result
 */
- (BOOL)dropTable:(NSString *)table;

/**
 clean datas for table
 
 @param table name
 @return result
 */
- (BOOL)cleanTable:(NSString *)table;

/**
 whether table contains the column
 
 @param col name
 @param table name
 @return result
 */
- (BOOL)whetherColumn:(NSString *)col existInTable:(NSString *)table;

/**
 Transaction for db event
 
 @param block to excuted
 */
- (void)begainTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block;

#pragma mark -- DB Util Methods

/**
 date formatter by default: yyyy-MM-dd HH:mm:ss
 
 @return formatter
 */
- (NSDateFormatter *)defaultDateFormatter;
- (NSDateFormatter *)dateFormatter4Style:(NSString *)style;

@end

/**
 install tokenizer for db
 
 @param db the db file
 */
FOUNDATION_EXTERN void initializedSimpleTokenizerForDB(FMDatabase *db);

NS_ASSUME_NONNULL_END
