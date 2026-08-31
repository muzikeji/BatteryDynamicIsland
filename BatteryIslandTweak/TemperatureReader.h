#ifndef TemperatureReader_h
#define TemperatureReader_h

/// 读取真实电池温度（摄氏度）。越狱环境专用，失败返回 -1。
double BI_batteryTemperature(void);

/// 是否正在充电，返回 1 表示充电，0 表示否。
int BI_isCharging(void);

#endif
