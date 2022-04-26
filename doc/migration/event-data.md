# Migrating legacy event data

The legacy OITE site stores its data in a Mysql database. Once you've obtained copy of the data, you can load it into a local Mysql / MariaDb server and export event data as CSV using the following SQL:

```sql
SELECT
    site_event.*,
    picklist_event_topic.value AS topic,
    picklist_trainee_type.value AS audience
FROM
    site_event
    LEFT JOIN _ObjectPicks _TopicsPick ON (_TopicsPick.object_id = site_event.id AND _TopicsPick.field_name = 'topics')
    LEFT JOIN picklist_event_topic ON picklist_event_topic.id = _TopicsPick.field_value
    LEFT JOIN _ObjectPicks _AudiencePick ON (_AudiencePick.object_id = site_event.id AND _AudiencePick.field_name = 'audience')
    LEFT JOIN picklist_trainee_type ON picklist_trainee_type.id = _AudiencePick.field_value
ORDER BY site_event.id;
```

## Database dump

Database tables containing user-entered content appear to hold UTF-8 data, but are marked as using the `latin1` character set. 
It might be best to load data using `utf8mb4` charset. This 


## Notes on database structure

Event data is stored in the `site_event` table. There is another table, `_ObjectPicks`, which is used to join records from different tables with "picklist" values–basically id/value pairs used single- and multi-value attributes. (Think things like "what topics does this event relate to?").

