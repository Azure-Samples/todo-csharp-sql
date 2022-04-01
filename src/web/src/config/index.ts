export interface ApiConfig {
    baseUrl: string
}

export interface ObservabilityConfig {
    instrumentationKey: string
}

export interface AppConfig {
    api: ApiConfig
    observability: ObservabilityConfig
}

const config: AppConfig = {
    api: {
        baseUrl: process.env.REACT_APP_API_BASE_URL || 'http://localhost:3100'
    },
    observability: {
        instrumentationKey: process.env.REACT_APP_APPINSIGHTS_INSTRUMENTATIONKEY || ''
    }
}

export default config;