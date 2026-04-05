/*
 * USB20 PLL settings for MT6735
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/io.h>

#define USBC_BASE       0x10000000
#define U3D_SSUSB_U2_PHY_PLL  (USBC_BASE + 0x007C)
#define SSUSB_U2_PORT_1US_TIMER (0x3FF << 0)

#define AP_PLL_CON0     (0x10000000 + 0x0000)
#define AP_PLL_CON1     (0x10000000 + 0x0004)
#define AP_PLL_CON2     (0x10000000 + 0x0008)
#define AP_PLL_CON3     (0x10000000 + 0x000C)
#define AP_PLL_CON4     (0x10000000 + 0x0010)

#define CON2_DA_REF2USB_TX_EN      (1 << 0)
#define CON2_DA_REF2USB_TX_LPF_EN  (1 << 1)
#define CON2_DA_REF2USB_TX_OUT_EN  (1 << 2)

static void mu3d_setmsk(void __iomem *addr, u32 mask, u32 value)
{
    u32 tmp;
    tmp = readl(addr);
    tmp = (tmp & ~mask) | (value & mask);
    writel(tmp, addr);
}

void usb20_pll_settings(int host, int forceOn)
{
    void __iomem *uap_pll_con;
    u32 val;

    pr_debug("usb20_pll_settings: host=%d, forceOn=%d\n", host, forceOn);

    uap_pll_con = ioremap(U3D_SSUSB_U2_PHY_PLL, 4);
    if (!uap_pll_con) {
        pr_err("usb20_pll: failed to ioremap U3D_SSUSB_U2_PHY_PLL\n");
        return;
    }

    if (host || forceOn) {
        val = readl(AP_PLL_CON2);
        val |= CON2_DA_REF2USB_TX_EN | CON2_DA_REF2USB_TX_LPF_EN | CON2_DA_REF2USB_TX_OUT_EN;
        writel(val, AP_PLL_CON2);

        mu3d_setmsk(uap_pll_con, SSUSB_U2_PORT_1US_TIMER, 0x3FF);
        
        pr_debug("usb20_pll: enabled USB PLL\n");
    } else {
        val = readl(AP_PLL_CON2);
        val &= ~(CON2_DA_REF2USB_TX_EN | CON2_DA_REF2USB_TX_LPF_EN | CON2_DA_REF2USB_TX_OUT_EN);
        writel(val, AP_PLL_CON2);

        pr_debug("usb20_pll: disabled USB PLL\n");
    }

    iounmap(uap_pll_con);
}
EXPORT_SYMBOL(usb20_pll_settings);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("MTK");
MODULE_DESCRIPTION("USB20 PLL settings for MT6735");