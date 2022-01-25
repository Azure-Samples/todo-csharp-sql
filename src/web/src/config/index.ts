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
        baseUrl: (process.env.NODE_ENV === 'development' || (typeof process.env.REACT_APP_API_BASE_URL === 'undefined') ? 'http://localhost:5000' : process.env.REACT_APP_API_BASE_URL)
    },
    observability: {
        instrumentationKey: process.env.REACT_APP_APPINSIGHTS_INSTRUMENTATIONKEY || ''
    }
}

export default config;