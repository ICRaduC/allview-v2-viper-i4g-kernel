/*
 * tp_wake_switch - Touchscreen wake gesture switch driver
 * Creates /sys/devices/platform/tp_wake_switch/ for gesture control
 */
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/sysfs.h>
#include <linux/device.h>
#include <linux/kernel.h>
#include <linux/slab.h>

#define TP_WAKE_DEVICE_NAME "tp_wake_switch"

static int double_wake_value = 0;
static int gesture_wake_value = 0;
static int gesture_config_value = 0;
static int factory_check_value = 0;
static int gesture_coordition_value = 0;
static int manufacturer_value = 0;

static ssize_t double_wake_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", double_wake_value);
}

static ssize_t double_wake_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
	sscanf(buf, "%d", &double_wake_value);
	return count;
}

static ssize_t gesture_wake_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", gesture_wake_value);
}

static ssize_t gesture_wake_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
	sscanf(buf, "%d", &gesture_wake_value);
	return count;
}

static ssize_t gesture_config_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", gesture_config_value);
}

static ssize_t gesture_config_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
	sscanf(buf, "%d", &gesture_config_value);
	return count;
}

static ssize_t factory_check_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", factory_check_value);
}

static ssize_t factory_check_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t count)
{
	sscanf(buf, "%d", &factory_check_value);
	return count;
}

static ssize_t gesture_coordition_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", gesture_coordition_value);
}

static ssize_t manufacturer_show(struct device *dev, struct device_attribute *attr, char *buf)
{
	return snprintf(buf, PAGE_SIZE, "%d\n", manufacturer_value);
}

static DEVICE_ATTR(double_wake, 0664, double_wake_show, double_wake_store);
static DEVICE_ATTR(gesture_wake, 0664, gesture_wake_show, gesture_wake_store);
static DEVICE_ATTR(gesture_config, 0664, gesture_config_show, gesture_config_store);
static DEVICE_ATTR(factory_check, 0664, factory_check_show, factory_check_store);
static DEVICE_ATTR(gesture_coordition, 0444, gesture_coordition_show, NULL);
static DEVICE_ATTR(manufacturer, 0444, manufacturer_show, NULL);

static struct attribute *tp_wake_switch_attrs[] = {
	&dev_attr_double_wake.attr,
	&dev_attr_gesture_wake.attr,
	&dev_attr_gesture_config.attr,
	&dev_attr_factory_check.attr,
	&dev_attr_gesture_coordition.attr,
	&dev_attr_manufacturer.attr,
	NULL
};

static struct attribute_group tp_wake_switch_attr_group = {
	.attrs = tp_wake_switch_attrs,
};

static int tp_wake_switch_probe(struct platform_device *dev)
{
	int ret;
	
	pr_info("tp_wake_switch probe\n");
	
	ret = sysfs_create_group(&dev->dev.kobj, &tp_wake_switch_attr_group);
	if (ret) {
		pr_err("tp_wake_switch: failed to create sysfs group\n");
		return ret;
	}
	
	pr_info("tp_wake_switch: created /sys/devices/platform/tp_wake_switch/\n");
	return 0;
}

static int tp_wake_switch_remove(struct platform_device *dev)
{
	sysfs_remove_group(&dev->dev.kobj, &tp_wake_switch_attr_group);
	return 0;
}

#ifdef CONFIG_OF
static const struct of_device_id tp_wake_switch_of_match[] = {
	{ .compatible = "mediatek,tp_wake_switch", },
	{},
};
#endif

static struct platform_driver tp_wake_switch_driver = {
	.probe = tp_wake_switch_probe,
	.remove = tp_wake_switch_remove,
	.driver = {
		.name = TP_WAKE_DEVICE_NAME,
		.owner = THIS_MODULE,
#ifdef CONFIG_OF
		.of_match_table = tp_wake_switch_of_match,
#endif
	}
};

static struct platform_device tp_wake_switch_device = {
	.name = TP_WAKE_DEVICE_NAME,
	.id = -1,
};

static int __init tp_wake_switch_init(void)
{
	int ret;
	
	pr_info("tp_wake_switch init\n");
	
	ret = platform_device_register(&tp_wake_switch_device);
	if (ret) {
		pr_err("tp_wake_switch: failed to register platform device\n");
		return ret;
	}
	
	ret = platform_driver_register(&tp_wake_switch_driver);
	if (ret) {
		pr_err("tp_wake_switch: failed to register platform driver\n");
		platform_device_unregister(&tp_wake_switch_device);
		return ret;
	}
	
	return 0;
}

static void __exit tp_wake_switch_exit(void)
{
	platform_driver_unregister(&tp_wake_switch_driver);
	platform_device_unregister(&tp_wake_switch_device);
}

module_init(tp_wake_switch_init);
module_exit(tp_wake_switch_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Allview");
MODULE_DESCRIPTION("Touchscreen wake gesture switch driver");
MODULE_ALIAS("platform:tp_wake_switch");
