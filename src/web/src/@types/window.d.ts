export { };

declare global {
    interface Window {
        ENV_CONFIG: {
            REACT_APP_API_BASE_URL: string;
            REACT_APP_APPINSIGHTS_INSTRUMENTATIONKEY: string;
        }
    }
}
