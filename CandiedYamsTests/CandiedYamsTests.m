//
//  CandiedYamsTests.m
//  CandiedYamsTests
//
//  Created by Gwynne Raskind on 12/14/21.
//

#import <XCTest/XCTest.h>
@import CandiedYams;

@interface CandiedYamsTests : XCTestCase
@end

@implementation CandiedYamsTests

- (void)testLoadString {
    NSString *yamlString = @"hello: world\nI:\n  am:\n    a:\n      tree:\nand:\n  - I\n  - am\n  - a\n  - list\n";
    NSError *error = nil;
    NSDictionary<NSString *, id> *parsedYaml = [CandiedYams loadWithYaml:yamlString encoding:NSUTF8StringEncoding error:&error];
    NSDictionary<NSString *, NSDictionary<NSString *, NSDictionary<NSString *, id> *> *> *tree = @{@"am": @{@"a": @{@"tree": NSNull.null}}};
    NSArray<NSString *> *list = @[@"I", @"am", @"a", @"list"];
    
    XCTAssertNotNil(parsedYaml);
    XCTAssertNil(error);
    NSLog(@"%@", parsedYaml);
    XCTAssertEqualObjects(parsedYaml[@"hello"], @"world");
    XCTAssertEqualObjects(parsedYaml[@"I"], tree);
    XCTAssertEqualObjects(parsedYaml[@"and"], list);
}

- (void)testSerializeObjects {
    NSDictionary<NSString *, id> *someObjects = @{
        @"hello": @"world",
        @"I": @{@"am": @{@"a": @{@"tree": NSNull.null}}},
        @"and": @[@"I", @"am", @"a", @"list"],
    };
    NSError *error = nil;
    NSString *serializedYaml = [CandiedYams dump:someObjects canonical:false indent:2 width:-1 allowUnicode:true lineBreak:LineBreakModeLf explicitStart:false explicitEnd:false majorVersion:-1 minorVersion:-1 sortKeys:false error:&error];
    
    XCTAssertNotNil(serializedYaml);
    XCTAssertNil(error);
    XCTAssertEqualObjects(serializedYaml, @"I:\n  am:\n    a:\n      tree: null\nand:\n- I\n- am\n- a\n- list\nhello: world\n");
}

@end
