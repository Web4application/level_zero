import os 
import ctypes
from ctypes import c_void_p, c_char_p, c_uint32, POINTER

# -------------------------------
# 1. Write the C code to file
# -------------------------------
c_code = """
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <level_zero/ze_api.h>
#include <level_zero/zet_api.h>

ze_result_t FindMetricGroup(
    ze_device_handle_t hDevice,
    const char* pMetricGroupName,
    uint32_t desiredSamplingType,
    zet_metric_group_handle_t* phMetricGroup
) {
    uint32_t metricGroupCount = 0;
    ze_result_t res = zetMetricGroupGet(hDevice, &metricGroupCount, NULL);
    if (res != ZE_RESULT_SUCCESS || metricGroupCount == 0) {
        *phMetricGroup = NULL;
        return res;
    }

    zet_metric_group_handle_t* phMetricGroups = (zet_metric_group_handle_t*)malloc(
        metricGroupCount * sizeof(zet_metric_group_handle_t)
    );

    if (!phMetricGroups) {
        *phMetricGroup = NULL;
        return ZE_RESULT_ERROR_OUT_OF_HOST_MEMORY;
    }

    res = zetMetricGroupGet(hDevice, &metricGroupCount, phMetricGroups);
    if (res != ZE_RESULT_SUCCESS) {
        free(phMetricGroups);
        *phMetricGroup = NULL;
        return res;
    }

    *phMetricGroup = NULL;  // default if no match
    for (uint32_t i = 0; i < metricGroupCount; i++) {
        zet_metric_group_properties_t props = {0};
        props.stype = ZET_STRUCTURE_TYPE_METRIC_GROUP_PROPERTIES;

        res = zetMetricGroupGetProperties(phMetricGroups[i], &props);
        if (res != ZE_RESULT_SUCCESS) continue;

        printf("Metric Group: %s\\n", props.name);

        if ((props.samplingType & desiredSamplingType) == desiredSamplingType &&
            strcmp(pMetricGroupName, props.name) == 0) {
            *phMetricGroup = phMetricGroups[i];
            break;
        }
    }

    free(phMetricGroups);
    return ZE_RESULT_SUCCESS;
}
"""

with open("metric_utils.c", "w") as f:
    f.write(c_code)

# -------------------------------
# 2. Compile the C code to shared library
# -------------------------------
lib_name = "libmetric_utils.so"
os.system(f"gcc -shared -fPIC -o {lib_name} metric_utils.c -lze_loader -lzet")

# -------------------------------
# 3. Load the library
# -------------------------------
lib = ctypes.CDLL(f"./{lib_name}")

lib.FindMetricGroup.argtypes = [
    c_void_p,        # ze_device_handle_t
    c_char_p,        # metric group name
    c_uint32,        # desired sampling type
    POINTER(c_void_p) # output metric group handle
]
lib.FindMetricGroup.restype = c_uint32  # ze_result_t

# -------------------------------
# 4. Initialize Level Zero
# -------------------------------
ze_result = ctypes.CDLL("libze_loader.so").zeInit(0)
if ze_result != 0:
    raise RuntimeError("Failed to initialize Level Zero")

# Get device count
device_count = c_uint32()
res = ctypes.CDLL("libze_loader.so").zeDeviceGet(0, ctypes.byref(device_count), None)
if res != 0 or device_count.value == 0:
    raise RuntimeError("No Level Zero devices found")

DeviceArrayType = c_void_p * device_count.value
devices = DeviceArrayType()
res = ctypes.CDLL("libze_loader.so").zeDeviceGet(device_count, None, devices)
if res != 0:
    raise RuntimeError("Failed to get Level Zero devices")

# -------------------------------
# 5. Enumerate metric groups & save log
# -------------------------------
log_file = "metric_log.txt"
with open(log_file, "w") as log:
    for i, device in enumerate(devices):
        log.write(f"Device {i} handle: {device}\n")
        metric_handle = c_void_p()
        # Example: searching for metric group named "MyMetricGroup" with sampling type 1
        res = lib.FindMetricGroup(device, b"MyMetricGroup", 0x1, ctypes.byref(metric_handle))
        log.write(f"Result: {res}, Metric handle: {metric_handle.value}\n")
        log.write("-" * 40 + "\n")

print(f"All metric info saved to {log_file}")
