import ctypes
from ctypes import c_void_p, c_char_p, c_uint32, POINTER

# Load the shared library
lib = ctypes.CDLL('./libmetric_utils.so')  # or .dll on Windows

# Define argument/return types
lib.FindMetricGroup.argtypes = [
    c_void_p,        # ze_device_handle_t
    c_char_p,        # metric group name
    c_uint32,        # desired sampling type
    POINTER(c_void_p) # output metric group handle
]
lib.FindMetricGroup.restype = c_uint32  # ze_result_t

# Example usage: you must provide a real ze_device_handle_t
metric_handle = c_void_p()
device_handle = 0  # replace with real ze_device_handle_t
res = lib.FindMetricGroup(
    device_handle,
    b"MyMetricGroup",
    0x1,  # example sampling type
    ctypes.byref(metric_handle)
)
print("Result:", res)
print("Metric handle:", metric_handle.value)
