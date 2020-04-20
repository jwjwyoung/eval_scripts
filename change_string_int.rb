require "pg"
require "mysql2"

def change_string2int(conn, table, field, values)
  for i in 0...values.length
    value = values[i]
    update_query = "update #{table} set #{field} = '#{i}' where #{field} = '#{value}'"
    conn.query(update_query)
  end
  if conn.instance_of? Mysql2::Client
    alter_query = "ALTER TABLE #{table} CHANGE #{field} #{field} int"
  else
    alter_query = "ALTER TABLE #{table} ALTER COLUMN #{field}  TYPE integer USING (#{field}::integer);"
  end
  conn.query(alter_query)
end

def duplicate_psql
  db = "onebody200k_dev"
  sql_file = "200k.sql"
  `pg_dump #{db} > #{sql_file}`
  new_db = "#{db}_changeStr2Int"
  `createdb #{new_db}`
  `psql #{new_db} < #{sql_file}`
  conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => new_db, :user => "jwy", :password => "")
  return conn
end

def duplicate_mysql
  db = "onebody_dev"
  sql_file = "mysql.sql"
  `mysqldump -u root #{db} > #{sql_file}`
  new_db = "#{db}_changeStr2Int"
  client = Mysql2::Client.new(:host => "localhost", :username => "root")
  create_db_query = "create database #{new_db}"
  client.query(create_db_query)
  # import the db to the newly create db
  `mysql -u root #{new_db} < #{sql_file} `
  use_db_query = "use #{new_db};"
  client.query(use_db_query)
  return client
end

tables = []

table = "custom_fields"
field = "format"
values = ["string", "number", "boolean", "date"]
tables << [table, field, values.dup]

table = "people"
field = "gender"
values = ["female", "male"]
tables << [table, field, values.dup]

conn = duplicate_psql()
# new_db = "onebody200k_dev_changeStr2Int"
# conn = conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => new_db, :user => "jwy", :password => "")
mysql_conn = duplicate_mysql()

# Mysql2::Client.new(:host => "localhost", :username => "root")
# new_db = "onebody_dev_changeStr2Int"
# mysql_conn.query("use #{new_db};")

tables.each do |table, field, values|
  change_string2int(conn, table, field, values)
  schange_string2int(mysql_conn, table, field, values)
end
