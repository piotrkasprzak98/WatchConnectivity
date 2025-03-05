#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapacitorWatchMessage, "CapacitorWatchMessage",
           CAP_PLUGIN_METHOD(sendMessageToWatch, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(sendMessageToWatch, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(startWatchAppWithWorkoutConfiguration, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(transferUserInfoToWatch, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(updateApplicationContextWatch, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isWatchPaired, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(isWatchAppInstalled, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getWatchInformation, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getWatchStoredName, CAPPluginReturnPromise);
)
