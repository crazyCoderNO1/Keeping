//
//  KPNavigationViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/18.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPNavigationViewController.h"
#import "KPTabBarViewController.h"
#import "Utilities.h"
#import "KPGuideView.h"

@interface KPNavigationViewController ()

@end

@implementation KPNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationBar setBarTintColor:[Utilities getColor]];
    
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstLaunch"]){
        KPGuideView *guideView = [[KPGuideView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [self.view addSubview:guideView];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setFont];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count != 0) {
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"NAV_BACK"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    }
    [super pushViewController:viewController animated:animated];
}

- (void)back{
    [self popViewControllerAnimated:YES];
}

- (void)setFont{
    NSDictionary *dicNav = @{
                             NSFontAttributeName:[UIFont systemFontOfSize:17.0f],
                             NSForegroundColorAttributeName: [UIColor whiteColor]
                             };
    self.navigationBar.titleTextAttributes = dicNav;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

@end
