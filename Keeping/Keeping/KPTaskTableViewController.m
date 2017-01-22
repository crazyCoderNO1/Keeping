//
//  KPTaskTableViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPTaskTableViewController.h"
#import "KPSeparatorView.h"
#import "TaskManager.h"
#import "Task.h"
#import "KPTaskTableViewCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Utilities.h"
#import "DateTools.h"
#import "DateUtil.h"
#import "KPTaskDetailTableViewController.h"
#import "MLKMenuPopover.h"

#define MENU_POPOVER_FRAME CGRectMake(10, 44 + 9, 140, 44 * [[Utilities getTaskSortArr] count])

@interface KPTaskTableViewController () <MLKMenuPopoverDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) UIView *background;   //图片放大的背景

@property (nonatomic,strong) NSArray *_Nonnull sortArray;
@property (nonatomic,strong) MLKMenuPopover *_Nonnull menuPopover;

@end

@implementation KPTaskTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.taskArr = [[NSMutableArray alloc] init];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    //星期几选项按钮
    for(UIButton *button in self.weekDayStack.subviews){
        [button setTintColor:[Utilities getColor]];
        [button setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
        if(button.tag != -1){
            //-1是全选按钮
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:18.0]];
            UIImage *buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
            buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
        }else{
            [button.titleLabel setFont:[UIFont fontWithName:[Utilities getFont] size:15.0]];
        }
    }
    
    self.sortFactor = @"addDate";
    
    self.selectedWeekdayArr = [[NSMutableArray alloc] init];
    [self selectAllWeekDay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (void)loadTasksOfWeekdays:(NSArray *)weekDays{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY SELF.reminderDays in %@", weekDays];
//    self.taskArr = [NSMutableArray arrayWithArray:[[[TaskManager shareInstance] getTasks] filteredArrayUsingPredicate:predicate]];
    //排序
    [self.taskArr removeAllObjects];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:self.sortFactor ascending:NO];
    self.taskArr = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:[[[TaskManager shareInstance] getTasks] filteredArrayUsingPredicate:predicate]] sortedArrayUsingDescriptors:@[sortDescriptor]]];
    
    [self.tableView reloadData];
}

- (void)addAction:(id)senders{
    [self performSegueWithIdentifier:@"addTaskSegue" sender:nil];
}

- (void)editAction:(id)senders{
    // Hide already showing popover
    [self.menuPopover dismissMenuPopover];
    
    self.menuPopover = [[MLKMenuPopover alloc] initWithFrame:MENU_POPOVER_FRAME menuItems:[[Utilities getTaskSortArr] allKeys]];
    self.menuPopover.menuPopoverDelegate = self;
    [self.menuPopover showInView:self.navigationController.view];
}

- (IBAction)selectWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    UIImage *buttonImg;
    NSNumber *tag = [NSNumber numberWithInteger:btn.tag];
    
    if([self.selectedWeekdayArr containsObject:tag]){
        //包含
        buttonImg = [UIImage imageNamed:@"CIRCLE_BORDER"];
        [self.selectedWeekdayArr removeObject:tag];
        [btn setTitleColor:[Utilities getColor] forState:UIControlStateNormal];
    }else{
        //不包含
        buttonImg = [UIImage imageNamed:@"CIRCLE_FULL"];
        [self.selectedWeekdayArr addObject:tag];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    buttonImg = [buttonImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setBackgroundImage:buttonImg forState:UIControlStateNormal];
    
    if([self.selectedWeekdayArr count] > 0){
        [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    }else{
        [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    }
    
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

- (IBAction)selectAllWeekdayAction:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if([btn.titleLabel.text isEqualToString:@"全选"]){
        [self selectAllWeekDay];
    }else if([btn.titleLabel.text isEqualToString:@"清空"]){
        [self deselectAllWeekDay];
    }
}

- (void)selectAllWeekDay{
    [self.allButton setTitle:@"清空" forState: UIControlStateNormal];
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            NSNumber *tag = [NSNumber numberWithInteger:button.tag];
            if(![self.selectedWeekdayArr containsObject:tag]){
                [self selectWeekdayAction:button];
            }
        }
    }
}

- (void)deselectAllWeekDay{
    [self.allButton setTitle:@"全选" forState: UIControlStateNormal];
    for(UIButton *button in self.weekDayStack.subviews){
        if(button.tag != -1){
            NSNumber *tag = [NSNumber numberWithInteger:button.tag];
            if([self.selectedWeekdayArr containsObject:tag]){
                [self selectWeekdayAction:button];
            }
        }
    }
}

#pragma mark - Pop Up Image

- (void)passImg:(UIImage *)img{
    [self.navigationController.navigationBar setHidden:YES];
    [self.tabBarController.tabBar setHidden:YES];
    
    //创建一个黑色背景, 初始化一个用来当做背景的View。
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height + 64)];
    self.background = bgView;
    [bgView setBackgroundColor:[UIColor colorWithRed:0/250.0 green:0/250.0 blue:0/250.0 alpha:1.0]];
    
    //创建显示图像的视图
    //初始化要显示的图片内容的imageView
    UIImageView *browseImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 64)];
    browseImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    browseImgView.image = img;
    [bgView addSubview:browseImgView];
    
    browseImgView.userInteractionEnabled = YES;
    //添加点击手势（即点击图片后退出全屏）
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)];
    [browseImgView addGestureRecognizer:tapGesture];
    
    [self.tableView addSubview:bgView];
}

- (void)closeView{
    [self.background removeFromSuperview];
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        default:
            return 1;
        case 1:
            return [self.taskArr count];
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1:
        {
            if([self.taskArr count] == 0){
                return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
            }else{
                KPSeparatorView *view = [[[NSBundle mainBundle] loadNibNamed:@"KPSeparatorView" owner:nil options:nil] lastObject];
                view.backgroundColor = [UIColor clearColor];
                [view setText:@"任务"];
                return view;
            }
        }
        default:
            return [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 1:
        {
            if([self.taskArr count] == 0){
                return 0.00001f;
            }else{
                return 20.0f;
            }
        }
        default:
            return 0.00001f;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(section == 0){
        return [UIView new];
    }else{
        return [super tableView:tableView viewForFooterInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0){
        return 0.00001f;
    }else{
        return [super tableView:tableView heightForFooterInSection:section];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        [self performSegueWithIdentifier:@"detailTaskSegue" sender:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }else{
        return 70;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 0) {
        return 10;
    }else{
        return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        static NSString *cellIdentifier = @"KPTaskTableViewCell";
        UINib *nib = [UINib nibWithNibName:@"KPTaskTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
        KPTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor clearColor];
        
        Task *t = self.taskArr[indexPath.row];
        [cell.nameLabel setText:t.name];
        
        NSString *reminderDayStr = @"";
        if([t.reminderDays count] > 0){
            NSArray *arr = t.reminderDays;
            
            if([arr isEqualToArray:@[@(1),@(2),@(3),@(4),@(5),@(6),@(7)]]){
                reminderDayStr = @"每天";
            }else if([arr isEqualToArray:@[@(2),@(3),@(4),@(5),@(6)]]){
                reminderDayStr = @"工作日";
            }else if([arr isEqualToArray:@[@(1),@(7)]]){
                reminderDayStr = @"周末";
            } else{
                for (NSNumber *i in arr) {
                    reminderDayStr = [reminderDayStr stringByAppendingString:[NSString stringWithFormat:@"%@, ", [DateUtil getWeekdayStr:[i intValue]]]];
                }
                reminderDayStr = [reminderDayStr substringToIndex:reminderDayStr.length - 2];
            }
            
            [cell.daysLabel setHidden:NO];
        }else{
            [cell.daysLabel setHidden:YES];
        }
        
        NSString *reminderTimeStr = @"";
        if(t.reminderTime != NULL){
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            reminderTimeStr = [reminderTimeStr stringByAppendingString:@", "];
            reminderTimeStr = [reminderTimeStr stringByAppendingString:[dateFormatter stringFromDate:t.reminderTime]];
        }
        [cell.daysLabel setText:[reminderDayStr stringByAppendingString:reminderTimeStr]];
        
        if(t.image != NULL){
            [cell.taskImgViewBtn setBackgroundImage:[UIImage imageWithData:t.image] forState:UIControlStateNormal];
            cell.delegate = self;
        }else{
            [cell.taskImgViewBtn setImage:[UIImage new] forState:UIControlStateNormal];
        }
        
//        NSString *dateStr =  [t.addDate formattedDateWithFormat:@"YYYY/MM/dd HH:mm:ss"];
        [cell.totalDayLabel setText:[NSString stringWithFormat:@"已添加 %ld 天, 已完成 %lu 天", (long)[[NSDate date] daysFrom:t.addDate] + 1, (unsigned long)[t.punchDateArr count]]];
        
        int totalPunchNum = [[TaskManager shareInstance] totalPunchNumberOfTask:t];
        int punchNum = (int)[t.punchDateArr count];
        //暂时 NO
        [cell.progressView setProgress:totalPunchNum == 0 ? 0 : (float)punchNum / totalPunchNum animated:NO];
        return cell;
    }else{
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1){
        return YES;
    }else{
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Task *t = self.taskArr[indexPath.row];
        
        [[TaskManager shareInstance] deleteTask:t];
        
        [self.taskArr removeObject:t];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if(self.taskArr.count == 0){
            [self.tableView reloadData];
        }
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        return UITableViewCellEditingStyleDelete;
    }else{
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"addTaskSegue"]){
        
    }else if([segue.identifier isEqualToString:@"detailTaskSegue"]){
        KPTaskDetailTableViewController *kptdtvc = (KPTaskDetailTableViewController *)[segue destinationViewController];
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        [kptdtvc setTask:self.taskArr[indexPath.row]];
    }
}

#pragma mark - DZN Empty Delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"没有任务";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:15.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:@"去新增任务" attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    [self addAction:self];
}

- (BOOL)emptyDataSetShouldBeForcedToDisplay:(UIScrollView *)scrollView{
    if(self.taskArr.count == 0){
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - MLKMenuPopoverDelegate

- (void)menuPopover:(MLKMenuPopover *)menuPopover didSelectMenuItemAtIndex:(NSInteger)selectedIndex{
    self.sortFactor = [[Utilities getTaskSortArr] allValues][selectedIndex];
    NSLog(@"按%@排序", self.sortFactor);
    [self loadTasksOfWeekdays:self.selectedWeekdayArr];
}

@end
