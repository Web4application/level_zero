#include <JavaScriptCore/JavaScriptCore.h>
#include <string>

// Wrapper to execute modern JS strings
std::string execute_modern_js(JSContextRef ctx, const char* script_content) {
    JSStringRef script = JSStringCreateWithUTF8CString(script_content);
    JSValueRef exception = nullptr;
    
    // Modern JSC handles ES6 syntax natively if linked against latest SDK
    JSValueRef result = JSEvaluateScript(ctx, script, nullptr, nullptr, 1, &exception);
    
    if (exception) {
        // Handle ES6 syntax errors or runtime exceptions
        return "Error: Modern JS execution failed.";
    }
    
    JSStringRef resultStr = JSValueToStringCopy(ctx, result, nullptr);
    char buffer[1024];
    JSStringGetUTF8CString(resultStr, buffer, 1024);
    
    JSStringRelease(script);
    JSStringRelease(resultStr);
    return std::string(buffer);
}
