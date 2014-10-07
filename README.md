MySQL to PostgreSQL Converter
=============================

Lanyrd's MySQL to PostgreSQL conversion script. Use with care.

This script was designed for our specific database and column requirements -
notably, it doubles the lengths of VARCHARs due to a unicode size problem we
had, places indexes on all foreign keys, and presumes you're using Django
for column typing purposes.

favrik-specific changes
-----------------------

These are on top of the `gitlab` branch:

- Convert floats to numeric using the same precision and scale.


GitLab-specific changes
-----------------------

The `gitlab` branch of this fork contains the following changes made for
GitLab.

- Guard against replacing '0000-00-00 00:00:00' inside SQL text fields.
- Replace all MySQL zero-byte string literals `\0`. This is safe as of GitLab
  6.8 because the GitLab database schema contains no binary columns.
- Add the `add_index_statements.rb` script to recreate indices dropped by
  `dbconverter.py`.

How to use
----------

First, dump your MySQL database in PostgreSQL-compatible format

    mysqldump --compatible=postgresql --default-character-set=utf8 \
    -r databasename.mysql -u root gitlabhq_production

Then, convert it using the dbconverter.py script

`python dbconverter.py databasename.mysql databasename.psql`

It'll print progress to the terminal.

Next, load your new dump into a fresh PostgreSQL database using: 

`psql -f databasename.psql -d gitlabhq_production`

Finally, recreate the indexes for your GitLab version; see
http://doc.gitlab.com/ce/update/mysql_to_postgresql.html#rebuild-indexes .

More information
----------------

You can learn more about the move which this powered at http://lanyrd.com/blog/2012/lanyrds-big-move/ and some technical details of it at http://www.aeracode.org/2012/11/13/one-change-not-enough/.
