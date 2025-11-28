## Production Observability

Grafana MCP tools provide access to production metrics and logs for performance analysis.

### Datasources
| Name | UID | Use |
|------|-----|-----|
| Thanos (Prometheus) | `PC96415006F908B67` | Metrics, latencies |
| Loki | `e38bdfea-097e-47fa-a7ab-774fd2487741` | Application logs |

### Key Metrics
- `rails_request_duration_seconds_bucket:rate1m:sum_by_app:quantiles{app="fizzy"}` - Request latency percentiles
- `rails_request_total:rate1m:sum_by_controller_action{app="fizzy"}` - Request rates by endpoint
- `fizzy_replica_wait_seconds` - Database replica consistency wait times

### Loki Log Labels and Query Patterns

**Base label selector:**
```logql
{service_namespace="fizzy", deployment_environment_name="production", service_name="rails"}
```

**Useful JSON fields:** `event_duration_ms`, `performance_time_db_ms`, `performance_time_cpu_ms`, `rails_endpoint`, `rails_controller`, `url_path`, `authentication_identity_id`, `http_response_status_code`

**Query patterns:**
- Filter by fields: `{labels} | field_name = "value"`
- Multiple field filters: `{labels} | field1 = "value1" | field2 = "value2"`
- Reduce returned labels: `{labels} | filters | keep field1,field2,field3` (reduces label payload)
- Minimize log line content: `{labels} | filters | line_format "{{.field_name}}"` (replaces raw log line)
- Combine both for minimal tokens: `{labels} | filters | keep field1,field2 | line_format "{{.field1}}"`
- **Important:** Fields are pre-parsed by the OTel collector. Don't use string search (`|=`) when filtering structured fields
- **Important:** Do NOT use `| json` - it will cause JSONParserErr since fields are already parsed as labels

**Token management (CRITICAL):**
- Always probe with `limit: 3` first to check response size before running larger queries
- Aggregations return time series (many data points), not single values - can explode token usage
- NEVER use `sum by (field)` - returns a time series per unique value, easily exceeds token limits
- For breakdowns by field: fetch raw logs with `| keep field | line_format "{{.field}}"` and count client-side

**Aggregations for statistics (use instead of fetching raw logs):**
- `mcp__grafana__query_loki_logs` returns limited results (default 10, max ~100) and large responses get truncated; use aggregations for statistics on large datasets
- Count: `sum(count_over_time({labels} | filters [12h]))`
- Percentiles: `quantile_over_time(0.95, {labels} | filters | unwrap field_name | __error__="" [12h]) by ()`
- Average: `avg_over_time({labels} | filters | unwrap field_name | __error__="" [12h]) by ()`
- Min/Max: `min_over_time(...)` / `max_over_time(...)`
- The `| unwrap field_name | __error__=""` pattern extracts numeric values from pre-parsed labels
- Use `by ()` or wrap in `sum()` to avoid cardinality limits

**Documentation:** For advanced LogQL syntax (aggregations, pattern matching, etc.), consult https://grafana.com/docs/loki/latest/query/

### Instrumentation
Yabeda-based metrics exported at `:9394/metrics`. Config in `config/initializers/yabeda.rb`.

### Sentry Error Tracking
Organization: `basecamp` | Project: `fizzy` | Region: `https://us.sentry.io`

Use Sentry MCP tools to investigate production errors:
- `search_issues` - Find grouped issues by natural language query
- `get_issue_details` - Get full stacktrace and context for a specific issue
- `analyze_issue_with_seer` - AI-powered root cause analysis with code fix suggestions
