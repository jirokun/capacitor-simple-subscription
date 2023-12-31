#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(SubscriptionManagerPlugin, "SubscriptionManager",
           CAP_PLUGIN_METHOD(subscribe, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(hasValidSubscription, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getSubscription, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(showManageSubscriptions, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(restoreSubscription, CAPPluginReturnPromise);
)
