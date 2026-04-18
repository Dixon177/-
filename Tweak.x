#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#import <dlfcn.h>

// تزييف اسم الجهاز (iPhone 14 Pro)
%hookf(int, uname, struct utsname *value) {
    int ret = %orig(value);
    if (value) {
        strcpy(value->machine, "iPhone15,2");
    }
    return ret;
}

// تزييف هوية الجهاز ومنع الباند
%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}
- (NSString *)systemVersion { return @"16.6"; }
- (NSString *)model { return @"iPhone"; }
%end

// منع إرسال البلاغات (Anti-Report)
%hook TDataCollector
- (void)collectData:(int)dataType { return; }
%end

%hook TLogManager
- (void)uploadLogsToServer:(id)logs { return; }
%end

%hook ACEDataCollector
- (void)sendReport:(id)arg1 type:(int)arg2 { return; }
%end

%ctor {
    // منع مراقبة التطبيق (Anti-Debugger)
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    int (*ptrace)(int, pid_t, caddr_t, int) = (int (*)(int, pid_t, caddr_t, int))dlsym(handle, "ptrace");
    if (ptrace) ptrace(31, 0, 0, 0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"[Ahmed_Bypass] Shield Active.");
    });
}
