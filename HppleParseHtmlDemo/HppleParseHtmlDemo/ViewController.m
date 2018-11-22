//
//  ViewController.m
//  HppleParseHtmlDemo
//
//  Created by Edward on 2018/11/6.
//  Copyright © 2018年 coolpeng. All rights reserved.
//

#import "ViewController.h"
#import <TFHpple.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self parseHtml];
}

- (void)parseHtml {
    [self parseStockNews];
}

// 解析股票新闻
- (void)parseStockNews {
    
    // 根据链接获取对应的 NSData 数据
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"https://finance.sina.com.cn/stock/"]];
    
    // 根据data创建TFHpple实例
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    
    // 根据标签进行过滤
    NSArray *elements = [doc searchWithXPathQuery:@"//ul[@class='list04']"];
    
    // 循环查找子节点
    for (int i = 0; i < elements.count; i++) {
        
        // 获取单个ul节点
        TFHppleElement *ulE = [elements objectAtIndex:i];
        
        // 查找该ul节点下边名称为li的子节点
        NSArray *liArr = [ulE childrenWithTagName:@"li"];
        
        // 遍历获取到的所有li子节点
        for (TFHppleElement *liE in liArr) {
            
            // 每个li节点下边的第一个子节点为时间信息
            TFHppleElement *timeE = liE.firstChild;
            
            // 获取到时间
            NSString *timeStr = [timeE text];
            
            // 查找li节点下边的p节点，因为就一个p节点，所有我们取第一个p节点
            TFHppleElement *pE = [[liE childrenWithTagName:@"p"] firstObject];
            
            // p节点有一个a子节点，所以我们取到a节点
            TFHppleElement *aE = [[pE childrenWithTagName:@"a"] lastObject];
            
            // a节点的内容为 标题
            NSString *titleStr = [aE text];
            
            // 根据a节点的href属性，获取到具体的新闻链接地址
            NSString *urlStr = [aE objectForKey:@"href"];
            
            if (!timeStr || !urlStr || !titleStr) {
                continue;
            }
            NSLog(@"Stock News:\n时间：%@\n标题：%@\n链接：%@\n",timeStr,titleStr,urlStr);
        }
    }
}

// 理财
- (void)parseFinancingMoneyNews {
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://finance.sina.com.cn/money"]];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//div[@class='info clearfix']"];
    
    for (int i = 0; i < elements.count; i++) {
        TFHppleElement *divE = [elements objectAtIndex:i];
        NSArray *timeArr = [divE childrenWithClassName:@"time"];
        
        NSString *timeStr = @"";
        NSString *urlStr = @"";
        NSString *titleStr = @"";
        if (timeArr.count > 0) {
            TFHppleElement *timeE = timeArr.firstObject;
            timeStr = [timeE text];
        }
        
        NSArray *actionArr = [divE childrenWithClassName:@"action"];
        if (actionArr.count >0) {
            TFHppleElement *actionE = actionArr.firstObject;
            NSArray *bdshareArr = [actionE childrenWithClassName:@"bdshare_t bds_tools get-codes-bdshare"];
            if (bdshareArr.count > 0) {
                TFHppleElement *bdshareE = bdshareArr.firstObject;
                NSString *dataStr = [bdshareE objectForKey:@"data"];
                NSString *str = [dataStr stringByReplacingOccurrencesOfString:@"text" withString:@"'text'"];
                NSString *str1 = [str stringByReplacingOccurrencesOfString:@"url" withString:@"'url'"];
                NSString *str2 = [str1 stringByReplacingOccurrencesOfString:@"pic" withString:@"'pic'"];
                NSString *str3 = [str2 stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
                NSDictionary *dataDic = [self dictionaryWithJsonString:str3];
                
                titleStr = dataDic[@"text"];
                urlStr = dataDic[@"url"];
            }
        }
        
        if (!titleStr || !timeStr || !urlStr) {
            continue;
        }
        
        NSLog(@"FinancingMoney News:\n时间：%@\n标题：%@\n链接：%@\n",timeStr,titleStr,urlStr);
    }
}

// 财经
- (void)parseFinanceNews {
    
    NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://finance.sina.com.cn/roll/index.d.html?cid=56589&page=1"]];
    TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
    NSArray *elements = [doc searchWithXPathQuery:@"//ul[@class='list_009']"];
    
    for (TFHppleElement *ulE in elements) {
        NSArray *liArr = [ulE childrenWithTagName:@"li"];
        
        for (TFHppleElement *liE in liArr) {
            
            TFHppleElement *spanE = [[liE childrenWithTagName:@"span"] firstObject];
            if (!spanE || spanE == NULL) {
                continue;
            }
            
            TFHppleElement *aE = [[liE childrenWithTagName:@"a"] firstObject];
            if (!aE || aE == NULL) {
                continue;
            }
            NSString *timeStr = [spanE text];
            NSString *titleStr = [aE text];
            NSString *urlStr = [aE objectForKey:@"href"];
            NSLog(@"Finance News:\n时间：%@\n标题：%@\n链接：%@\n",timeStr,titleStr,urlStr);
        }
    }
}

#pragma mark - Internal Method
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

