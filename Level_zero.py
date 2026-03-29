import ctypes
from ctypes import c_void_p, c_char_p, c_uint32, POINTER, byref

# -------------------------------
# Load Level Zero libraries
# -------------------------------
ze = ctypes.CDLL("libze_loader.so")
zet = ctypes.CDLL("libzet.so")

ZE_RESULT_SUCCESS = 0
ZET_STRUCTURE_TYPE_METRIC_GROUP_PROPERTIES = 1  # from Level Zero headers

# -------------------------------
# Initialize Level Zero
# -------------------------------
res = ze.zeInit(0)
if res != ZE_RESULT_SUCCESS:
    raise RuntimeError("zeInit failed")

# -------------------------------
# Get devices
# -------------------------------
device_count = c_uint32()
res = ze.zeDeviceGet(0, byref(device_count), None)
if res != ZE_RESULT_SUCCESS or device_count.value == 0:
    raise RuntimeError("No devices found")

DeviceArrayType = c_void_p * device_count.value
devices = DeviceArrayType()
res = ze.zeDeviceGet(device_count, None, devices)
if res != ZE_RESULT_SUCCESS:
    raise RuntimeError("Failed to get device handles")

# -------------------------------
# Define metric properties struct
# -------------------------------
class MetricGroupProps(ctypes.Structure):
    _fields_ = [
        ("stype", c_uint32),
        ("name", ctypes.c_char * 256),
        ("domain", c_uint32),
        ("samplingType", c_uint32),
    ]

# -------------------------------
# Open log file
# -------------------------------
log_file = "full_metric_log.txt"
with open(log_file, "w") as log:
    for idx, device in enumerate(devices):
        log.write(f"Device {idx} handle: {device}\n")

        # Get metric group count
        metric_count = c_uint32()
        res = zet.zetMetricGroupGet(device, byref(metric_count), None)
        if res != ZE_RESULT_SUCCESS or metric_count.value == 0:
            log.write("  No metric groups found\n")
            continue

        MetricArrayType = c_void_p * metric_count.value
        metrics = MetricArrayType()
        res = zet.zetMetricGroupGet(device, byref(metric_count), metrics)
        if res != ZE_RESULT_SUCCESS:
            log.write("  Failed to get metric group handles\n")
            continue

        # Loop over each metric group
        for m in metrics:
            props = MetricGroupProps()
            props.stype = ZET_STRUCTURE_TYPE_METRIC_GROUP_PROPERTIES
            res = zet.zetMetricGroupGetProperties(m, byref(props))
            if res != ZE_RESULT_SUCCESS:
                continue

            log.write(f"  Metric Group: {props.name.decode()}\n")
            log.write(f"    Domain: {props.domain}\n")
            log.write(f"    Sampling Type: {props.samplingType}\n")

            # Open metric group to read counters
            res = zet.zetMetricGroupOpen(m)
            if res != ZE_RESULT_SUCCESS:
                log.write("    Cannot open metric group\n")
                continue

            # Normally, you would allocate buffer and call zetMetricGroupReadCounters()
            # Example: buffer for counters (simplified, depends on actual Level Zero setup)
            counter_count = 4  # Example: 4 counters per group
            counter_values = (ctypes.c_double * counter_count)()
            # This is a placeholder: replace with actual zetMetricGroupReadCounters call
            for i in range(counter_count):
                counter_values[i] = 0.0  # Example: dummy values

            log.write(f"    Counter Values: {list(counter_values)}\n")

            zet.zetMetricGroupClose(m)

        log.write("-" * 40 + "\n")

print(f"All metric info saved to {log_file}")
