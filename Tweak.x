#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#import <dlfcn.h>

// 1. تزييف الجهاز
%hook utsname
int uname(struct utsname *value) {
    int ret = %orig(value);
    if (value) {
        strcpy(value->machine, "iPhone15,2"); 
    }
    return ret;
}
%end

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}
- (NSString *)systemVersion { return @"16.6"; }
%end

// 2. منع البلاغات
%hook TDataCollector
- (void)collectData:(int)dataType { return; }
%end

%hook TLogManager
- (void)uploadLogsToServer:(id)logs { return; }
%end

%hook ACEDataCollector
- (void)sendReport:(id)arg1 type:(int)arg2 { return; }
%end

// 3. تشغيل الحماية عند فتح اللعبة
%ctor {
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    typedef int (*ptr_t)(int, pid_t, caddr_t, int);
    ptr_t ptrace_ptr = (ptr_t)dlsym(handle, "ptrace");
    if (ptrace_ptr) ptrace_ptr(31, 0, 0, 0);

    NSLog(@"[Ahmed_Ultra] Active.");
}
