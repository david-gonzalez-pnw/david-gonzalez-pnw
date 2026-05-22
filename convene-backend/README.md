# Convene Backend

Azure Functions (C# isolated, **.NET 10**) backend for Convene — a Cronofy OAuth
broker plus account/subscription brain. See [`BACKEND.md`](BACKEND.md) for the
full design.

> Authored without a .NET SDK / Azure CLI in this environment — **not built and
> not deploy-validated**. Resource shapes were checked against current Microsoft
> Learn docs. Expect first-build/first-deploy fixes. Package versions in the
> `.csproj` are indicative.

## Layout

| Path | What |
| --- | --- |
| `BACKEND.md` | Design of record: stack, tiered auth, endpoints, data model |
| `infra/main.bicep` | All Azure resources (Flex Consumption, Cosmos, APIM, Key Vault, MI) |
| `infra/main.bicepparam` | Parameters (set Cronofy client id; pass secret at deploy) |
| `.github/workflows/deploy.yml` | OIDC login → Bicep → publish Functions |
| `src/Convene.Functions` | The Functions app |

## Endpoints

| Method + path | Auth | Purpose |
| --- | --- | --- |
| `POST /v1/auth/anonymous` | App Attest | Issue anonymous device JWT |
| `POST /v1/auth/apple` | Apple token | Link/elevate to Apple identity |
| `POST /v1/cronofy/token` | Backend JWT | Exchange Cronofy code, store refresh, return access token |
| `POST /v1/cronofy/token/refresh` | Backend JWT | Refresh access token |
| `POST /v1/webhooks/cronofy` | Cronofy HMAC | RSVP push (phase 3) |

JSON keys match the Swift client exactly (`accountID`, `redirectURI`, …).

## Run locally

```bash
cd src/Convene.Functions
cp local.settings.json.example local.settings.json   # fill in values
func start                                            # Azure Functions Core Tools
```

Needs the Cosmos DB emulator (or a real account) and Azure Functions Core Tools v4.

## Deploy

```bash
az group create -n convene-rg -l <region>
az deployment group create -g convene-rg -f infra/main.bicep -p infra/main.bicepparam \
  -p cronofyClientSecret=$CRONOFY_CLIENT_SECRET
# then publish the Functions app (see deploy.yml)
```

## Before production (tracked in BACKEND.md §Phasing)

- Implement **App Attest** verification (`Auth/Verifiers.cs`) — fails closed today.
- Implement **Apple identity-token** verification against Apple JWKS.
- Replace `PassthroughTokenProtector` with **Key Vault envelope encryption**.
- Define **APIM operations** + enable the `validate-jwt` policy in `main.bicep`.
- Wire **APNs / Notification Hubs** for live RSVP fan-out.
