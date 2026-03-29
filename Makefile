# Example for macOS/iOS build
LDFLAGS += -framework JavaScriptCore
# Ensure we are using C++17 for modern bridge code
CXXFLAGS += -std=c++17 -I./include/modern-jsc
