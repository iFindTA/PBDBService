//
//  ViewController.m
//  PBDBService
//
//  Created by nanhujiaju on 2017/9/8.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import "ViewController.h"
#import "PBDBService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [PBDBService enableDebugEncryptMode:true];
    
    [PBDBService shared];
    
    NSString *path = [PBDBService homeDirectoryPath];
    NSLog(@"home path:%@",path);
    
    NSString *usrTable = @"usr";
    if (![[PBDBService shared] isTableExist:usrTable]) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS t_usrs ( \
        uid TEXT NOT NULL PRIMARY KEY UNIQUE ON CONFLICT REPLACE,\
        age TEXT DEFAULT 0,\
        gender TEXT DEFAULT NULL,\
        nick TEXT DEFAULT NULL,\
        avatar TEXT DEFAULT NULL,\
        signature TEXT DEFAULT NULL,\
        authorName TEXT DEFAULT NULL,\
        authorID TEXT DEFAULT NULL,\
        authorType TEXT DEFAULT 0,\
        ext TEXT DEFAULT NULL\
        )";
        BOOL ret = [[PBDBService shared] createTables:@[sql] wetherFTS:false];
        NSLog(@"create result :%zd",ret);
    }
    //FTS table
    NSString *ftsTable = @"usr_ft";
    if (![[PBDBService shared] isTableExist:ftsTable]) {
        NSString *sql = @"CREATE VIRTUAL TABLE usr_ft USING fts4(acc, mob, flower, legal, alias, avatar, signature, email, gender, exist, ext);";
        BOOL ret = [[PBDBService shared] createTables:@[sql] wetherFTS:true];
        NSLog(@"create result :%zd",ret);
    } else {
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
