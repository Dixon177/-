#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>

// 1. حماية الجهاز وتزييف الهوية (للمراوغة من الباند)
%hookf(int, uname, struct utsname *value) {
    int ret = %orig(value);
    if (value) strcpy(value->machine, "iPhone14,2"); 
    return ret;
}

// 2. تلوين اللاعبين الذكي (Visible/Invisible Chams)
// ملاحظة: الأوفستات هنا تضرب الـ Render الخاص باللاعبين
void apply_smart_chams() {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    // أوفست كشف اللاعب خلف الجدران (Behind Wall - Red)
    uint32_t *behind_wall = (uint32_t *)(base + 0x5D1A220); 
    if (behind_wall) *behind_wall = 0x200080D2; // لون يميزه خلف الكفر

    // أوفست تمييز اللاعب المكشوف (Visible - Green)
    // هذا يتفعل لما يكون الخط بينك وبينه "مفتوح"
    uint32_t *is_visible = (uint32_t *)(base + 0x5D1A230);
    if (is_visible) *is_visible = 0x200080D3; 
}

// 3. الثبات والبولت تراك (Safe Settings)
void apply_weapon_mods() {
    uintptr_t base = (uintptr_t)_dyld_get_image_header(0);
    
    // ثبات سلاح 100% (No Recoil)
    uint32_t *recoil = (uint32_t *)(base + 0x6A1B2C4);
    if (recoil) *recoil = 0xD503201F;

    // بولت تراك خفيف 5% (Magic Bullet Light)
    uint32_t *magic = (uint32_t *)(base + 0x5F2A110);
    if (magic) *magic = 0x3F800000;
}

// 4. حماية منع البلاغات (Anti-Report)
%hook TDataCollector
- (void)sendData:(id)arg1 type:(int)arg2 {
    if (arg2 == 1 || arg2 == 2) return; // حجب بلاغات القتل المشبوه
    %orig;
}
%end

// --- [ بدء التشغيل ] ---
%ctor {
    // تأخير التفعيل 15 ثانية لضمان استقرار اللعبة عند الدخول
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        apply_smart_chams();
        apply_weapon_mods();
        NSLog(@"[Ahmed_PRO] Conqueror Script Loaded with Smart Chams.");
    });
}
