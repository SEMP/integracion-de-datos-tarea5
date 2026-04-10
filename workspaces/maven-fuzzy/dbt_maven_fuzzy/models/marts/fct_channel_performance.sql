{{ config(materialized='table') }}

with sessions as (
    select * from {{ ref('stg_sessions') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
)

select
    s.session_month,
    s.utm_source,
    s.utm_campaign,
    s.device_type,
    count(distinct s.website_session_id) as sessions,
    count(distinct o.order_id) as orders,
    round(count(distinct o.order_id) * 100.0 / nullif(count(distinct s.website_session_id), 0), 2) as conversion_rate,
    coalesce(sum(o.price_usd), 0) as revenue,
    coalesce(sum(o.margin_usd), 0) as margin,
    round(coalesce(sum(o.price_usd), 0) / nullif(count(distinct s.website_session_id), 0), 2) as revenue_per_session,
    round(coalesce(sum(o.price_usd), 0) / nullif(count(distinct o.order_id), 0), 2) as avg_order_value
from sessions s
left join orders o on s.website_session_id = o.website_session_id
group by s.session_month, s.utm_source, s.utm_campaign, s.device_type
order by s.session_month desc, revenue desc
