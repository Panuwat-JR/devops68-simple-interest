# Simple Interest Calculator API

Calculate simple interest.

## Endpoint

### GET `/calculate`

**Parameters:**
- `principal` (required): Principal amount
- `rate` (required): Interest rate (%)
- `time` (required): Time period (years)

**Example Request:**
```
http://localhost:3019/calculate?principal=1000&rate=5&time=2
```

**Example Response:**
```json
{
  "principal": 1000,
  "rate": 5,
  "time": 2,
  "simpleInterest": 100,
  "total": 1100
}
```
