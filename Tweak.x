#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#import <dlfcn.h>

// 1. حماية وتزييف الجهاز (Device Spoofer)
%hook utsname
int uname(struct utsname *value) {
    int ret = %orig(value);
    strcpy(value->machine, "iPhone15,2"); 
    return ret;
}
%end

%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"E621E1F8-C36C-495A-93FC-0C247A3E6E5F"];
}
- (NSString *)systemVersion { return @"16.6"; }
%end

// 2. منع البلاغات والـ Logs (Anti-Report)
%hook TDataCollector
- (void)collectData:(int)dataType { return; }
%end

%hook TLogManager
- (void)uploadLogsToServer:(id)logs { return; }
%end

%hook ACEDataCollector
- (void)sendReport:(id)arg1 type:(int)arg2 { return; }
%end

// 3. تطبيق الأوفستات (Memory Patch)
void apply_patches() {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    // مثال لأوفست تعطيل الحماية الداخلي
    uint32_t *patchAddr = (uint32_t *)(base + 0x78A2BC4); 
    if (patchAddr) *patchAddr = 0xC0035FD6; 
}

%ctor {
    // منع الـ Debugger
    void *handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    typedef int (*ptr_t)(int, pid_t, caddr_t, int);
    ptr_t ptrace_ptr = (ptr_t)dlsym(handle, "ptrace");
    if (ptrace_ptr) ptrace_ptr(31, 0, 0, 0);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        apply_patches();
        NSLog(@"[Ahmed_Ultra] All Systems Online.");
    });
}
