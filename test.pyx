python -c '
import jax
import vllm
import importlib.metadata
from vllm.platforms import current_platform

tpu_version = importlib.metadata.version("tpu_inference")
print(f"vllm version: {vllm.__version__}")
print(f"tpu_inference version: {tpu_version}")
print(f"vllm platform: {current_platform.get_device_name()}")
print(f"jax backends: {jax.devices()}")
'
# Expected output:
# vllm version: 0.x.x
# tpu_inference version: 0.x.x
# vllm platform: TPU V6E (or your specific TPU architecture)
# jax backends: [TpuDevice(id=0, process_index=0, coords=(0,0,0), core_on_chip=0), ...]
ze_result_t FindMetricGroup( ze_device_handle_t hDevice,
                               char* pMetricGroupName,
                               uint32_t desiredSamplingType,
                               zet_metric_group_handle_t* phMetricGroup )
{
    // Obtain available metric groups for the specific device
    uint32_t metricGroupCount = 0;
    zetMetricGroupGet( hDevice, &metricGroupCount, nullptr );

    zet_metric_group_handle_t* phMetricGroups = malloc(metricGroupCount * sizeof(zet_metric_group_handle_t));
    zetMetricGroupGet( hDevice, &metricGroupCount, phMetricGroups );

    // Iterate over all metric groups available
    for( i = 0; i < metricGroupCount; i++ )
    {
        // Get metric group under index 'i' and its properties
        zet_metric_group_properties_t metricGroupProperties {};
        metricGroupProperties.stype = ZET_STRUCTURE_TYPE_METRIC_GROUP_PROPERTIES;
        zetMetricGroupGetProperties( phMetricGroups[i], &metricGroupProperties );

        printf("Metric Group: %sn", metricGroupProperties.name);

        // Check whether the obtained metric group supports the desired sampling type
        if((metricGroupProperties.samplingType & desiredSamplingType) == desiredSamplingType)
        {
            // Check whether the obtained metric group has the desired name
            if( strcmp( pMetricGroupName, metricGroupProperties.name ) == 0 )
            {
                *phMetricGroup = phMetricGroups[i];
                break;
            }
        }
    }

    free(phMetricGroups);
}
