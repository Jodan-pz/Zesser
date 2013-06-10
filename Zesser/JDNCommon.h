//
//  JDNCommon.h
//  Zesser
//
//  Created by Daniele Giove on 6/5/13.
//  Copyright (c) 2013 Daniele Giove. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JDN_COMMON_IMAGE_INFO [UIImage imageNamed:@"info_64.png"]
#define JDN_INFO_MSG_TITLE  @"Messaggio"
#define JDN_WARN_MSG_TITLE  @"Attenzione"
#define JDN_ERRO_MSG_TITLE  @"Errore"
#define JDN_QUES_MSG_TITLE  @"Domanda"

typedef void(^ArrayDataCallBack)(NSArray *data);
typedef void(^BooleanCallBack)(BOOL result);

