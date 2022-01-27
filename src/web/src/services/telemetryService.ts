import { ReactPlugin } from "@microsoft/applicationinsights-react-js";
import { ApplicationInsights, Snippet, ITelemetryItem } from "@microsoft/applicationinsights-web";
import { createBrowserHistory } from 'history'
import config from "../config";

const plugin = new ReactPlugin();
let appInsights: ApplicationInsights;
export const reactPlugin = plugin;

export const getAppInsights = (): ApplicationInsights => {
    const browserHistory = createBrowserHistory({ window: window });
    if (appInsights) {
        return appInsights;
    }

    const appInsightsConfig: Snippet = {
        config: {
            instrumentationKey: config.observability.instrumentationKey,
            extensions: [plugin],
            extensionConfig: {
                [plugin.identifier]: { history: browserHistory }
            }
        }
    }

    appInsights = new ApplicationInsights(appInsightsConfig);
    appInsights.loadAppInsights();

    appInsights.addTelemetryInitializer((telemetry: ITelemetryItem) => {
        if (!telemetry) {
            return;
        }
        if (telemetry.tags) {
            telemetry.tags['ai.cloud.role'] = "webui";
        }
    });

    return appInsights;
}

export const trackEvent = (eventName: string, properties?: { [key: string]: unknown }): void => {
    if (!appInsights) {
        return;
    }

    appInsights.trackEvent({
        name: eventName,
        properties: properties
    });
}
