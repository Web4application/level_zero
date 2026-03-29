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

        printf("Metric Group: %s\n", props.name);

        if ((props.samplingType & desiredSamplingType) == desiredSamplingType &&
            strcmp(pMetricGroupName, props.name) == 0) {
            *phMetricGroup = phMetricGroups[i];
            break;
        }
    }

    free(phMetricGroups);
    return ZE_RESULT_SUCCESS;
}
