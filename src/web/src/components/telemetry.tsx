import React, { FC, ReactElement, useEffect, ComponentType, ComponentClass, PropsWithChildren } from 'react';
import { TelemetryProvider } from './telemetryContext';
import { reactPlugin, getAppInsights } from '../services/telemetryService';
import { withAITracking } from '@microsoft/applicationinsights-react-js';

type TelemetryProps = PropsWithChildren<unknown>;

const Telemetry: FC<TelemetryProps> = (props: TelemetryProps): ReactElement => {

    useEffect(() => {
        getAppInsights();
    }, []);

    return (
        <TelemetryProvider value={reactPlugin}>
            {props.children}
        </TelemetryProvider>
    );
}

export default Telemetry;
export const withAppInsights = (component: ComponentType<unknown>, componentName: string): ComponentClass<ComponentType<unknown>, unknown> => withAITracking<typeof component>(reactPlugin, component, componentName);
