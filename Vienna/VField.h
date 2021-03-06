//
//  VField.h
//  Vienna
//
//  Created by Steve on Mon Mar 22 2004.
//  Copyright (c) 2004 Steve Palmer. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>
#import "Vole.h"

#define MA_FieldType_Integer	1
#define MA_FieldType_Date		2
#define MA_FieldType_String		3
#define MA_FieldType_Flag		4
#define MA_FieldType_Folder		5

@interface VField : NSObject {
	NSString * name;
	NSString * title;
	NSString * sqlField;
	NSInteger type;
	NSInteger tag;
	NSInteger width;
	BOOL visible;
}

-(void)setName:(NSString *)newName;
-(void)setTitle:(NSString *)newTitle;
-(void)setSqlField:(NSString *)newSqlField;
-(void)setType:(NSInteger)newType;
-(void)setTag:(NSInteger)newTag;
-(void)setVisible:(BOOL)flag;
-(void)setWidth:(NSInteger)newWidth;
-(NSString *)name;
-(NSString *)title;
-(NSString *)sqlField;
-(NSInteger)tag;
-(NSInteger)type;
-(NSInteger)width;
-(BOOL)visible;
@end
