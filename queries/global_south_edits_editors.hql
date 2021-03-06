with gs_editors as (
    select 
        sum(edit_count) as edit_count,
        sum(namespace_zero_edit_count) as namespace_zero_edit_count,
        -- Treat the user as a bot if it matches on any wiki
        max(is_bot_by_name or array_contains(user_groups, "bot")) as bot
    from wmf.geoeditors_daily gd
    left join canonical_data.countries cdc
    on gd.country_code = cdc.iso_code
    left join wmf.mediawiki_user_history muh
    on
        gd.wiki_db = muh.wiki_db and
        gd.user_fingerprint_or_id = muh.user_id and
        muh.snapshot = "{mediawiki_history_snapshot}" and
        muh.end_timestamp is null
    where
        month = "{metrics_month}" and
        economic_region = "Global South" and
        not user_is_anonymous
    group by user_fingerprint_or_id
)
select
    "{metrics_month_first_day}" as month,
    sum(edit_count) as Global_South_edits,
    sum(if(not bot, edit_count, 0)) as Global_South_nonbot_edits,
    sum(cast(namespace_zero_edit_count >= 5 as int)) as Global_South_active_editors
from gs_editors