# Guide de configuration

## Gateway

- Mode : `local`
- Port : `18789`
- Bind : `lan` dans le container
- Host binding : `127.0.0.1`

## AI provider

- Provider : Google
- Authentication : Gemini API Key
- Default model : `google/gemini-3.1-flash-lite`

## Storage

- Type : Docker named volume
- Volume : `openclaw-state`
- Container path : `/home/node/.openclaw`

## Environment variables

| Variable               | Description            |
| ---------------------- | ---------------------- |
| OPENCLAW_IMAGE         | Docker image           |
| OPENCLAW_GATEWAY_PORT  | Gateway host port      |
| OPENCLAW_GATEWAY_TOKEN | Gateway authentication |
| GEMINI_API_KEY         | Google API credentials |
| TZ                     | Timezone               |
