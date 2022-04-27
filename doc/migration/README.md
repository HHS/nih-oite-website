# Legacy CMS database

This directory contains documentation and tooling for working with exports of data from the legacy OITE website database.

Legacy data is stored in a Mysql database. 
The existing vendor can provide exports of the data in typical `mysqldump` format (.sql.gz files in a .tar.gz wrapper).

The database is large, containing _thousands_ of tables. This makes it challenging to work with.

## Exporting data

This directory includes a script, `export-data.sh`, that can be used to export relevant data from a database dump.

To run this script, you'll need:

- A POSIX-compatible shell (tested only on macOS so far)
- Docker

To run the exporter:

1. Obtain a database dump in `.tar.gz` format.
2. Run `./export-data.sh path/to/the/dump.tar.gz`, substituting the appropriate path for the file obtained in step 1.
3. The script will export relevant data to .csv files.

### What this exporter ignores

To make the data easier to work with, this exporter ignores several types of table:

| Table(s) | Description |
| -- | -- |
| `eventlog*` | Logs used for auditing CMS usage |
| `event_<uuid>` `survey_<uuid>`, `picklist_event_<uuid>`, `picklist_survey_<uuid>` | This covers thousands of small tables, each apparently linked to a single event or survey for customization purposes. |
| `page_index` | Appears to be an index of site content already present elsewhere in the database. |
| `report_result` | Unknown purpose, but contains non-UTF8 data. |
