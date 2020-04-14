require "pg"

def change_string2int(conn, table, field, values)
  for i in 0...values.length
    value = values[i]
    update_query = "update #{table} set #{field} = '#{i}' where #{field} = '#{value}'"
    conn.exec(update_query)
  end
  alter_query = "ALTER TABLE #{table} ALTER COLUMN #{field}  TYPE integer USING (#{field}::integer);"
  conn.exec(alter_query)
end

db = "onebody200k_dev"
sql_file = "200k.sql"
`pg_dump #{db} > #{sql_file}`
new_db = "#{db}_changeStr2Int"
`createdb #{new_db}`
`psql #{new_db} < #{sql_file}`
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => new_db, :user => "jwy", :password => "")

table = "custom_fields"
field = "format"
values = ["string", "number", "boolean", "date"]
change_string2int(conn, table, field, values)

table = "people"
field = "gender"
values = ["female", "male"]

change_string2int(conn, table, field, values)
