load "./eval.rb"
load "./eval_mysql.rb"
require "faker"

# only 1 sql query is needed, since we will add check before issuing the queries
def benchmark_queries(n, conn, sql, params, format_regex, format_param_index, index_range_hash, with = true)
  puts sql[0]
  puts format_regex
  puts "********#{sql[1]}**********"
  params_arr = generate_params(n, params, index_range_hash)
  format_parameters = params_arr.map { |row| row[format_param_index] }
  puts format_parameters.select { |x| x =~ format_regex }.length
  if with
    Benchmark.bm do |x|
      x.report { for i in 0...n; execute_sql_before(conn, sql[0], params_arr[i]); end }
      x.report { for i in 0...n; execute_sql_after(conn, sql[0], params_arr[i], format_regex, format_parameters[i]); end }
    end
  else
    Benchmark.bm do |x|
      x.report { for i in 0...n; execute_sql_before(conn, sql[0], params_arr[i]); end }
      x.report { for i in 0...n; execute_sql_after_without(conn, sql[0], params_arr[i], format_regex, format_parameters[i]); end }
    end
  end
end

db = "onebody200k_dev"
# initialize the conn
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "jwy", :password => "")
mysql_conn = build_connection("onebody_dev")

# # format check barcode_id #11
n = 1000
sql = "" '
SELECT "families".* FROM "families" WHERE "families"."site_id" = 1 AND (barcode_id = $1 or alternate_barcode_id = $1)
' ""
mysql_query = "
SELECT `families`.* FROM `families` WHERE `families`.`site_id` = 1 AND (barcode_id = $1 or alternate_barcode_id = $1)
"
params = [""]
familiy_barcode_ids = get_all_table_fields(conn, "families", "barcode_id") + get_all_table_fields(conn, "families", "alternate_barcode_id")
index_range_hash = {}
index_range_hash[0] = familiy_barcode_ids
index_range_hash[0] = generate_random_barcode_id_params(n)
# index_range_hash[0] = [nil] * n
format_regex = /\A\d+\z/
format_param_index = 0
benchmark_queries(n, conn, [sql, 11], params, format_regex, format_param_index, index_range_hash)
benchmark_format_mysql_queries(n, mysql_conn, [mysql_query, 11], params, format_regex, format_param_index, index_range_hash, with = true)

# #23
sql = "" '
SELECT  "families".* FROM "families" WHERE "families"."site_id" = 1 AND "families"."barcode_id" = $1 AND "families"."deleted" = false  ORDER BY "families"."id" ASC LIMIT 1
' ""
benchmark_queries(n, conn, [sql, 23], params, format_regex, format_param_index, index_range_hash)

# #24
sql = "" '
SELECT  "families".* FROM "families" WHERE "families"."site_id" = 1 AND "families"."alternate_barcode_id" = $1 AND "families"."deleted" = false  ORDER BY "families"."id" ASC LIMIT 1
' ""
benchmark_queries(n, conn, [sql, 24], params, format_regex, format_param_index, index_range_hash)

# #26
sql = "" '
SELECT  "families".* FROM "families" WHERE "families"."site_id" = 1 AND "families"."deleted" = false AND (barcode_id = $1 or alternate_barcode_id = $1)  ORDER BY "families"."id" ASC LIMIT 1
' ""
benchmark_queries(n, conn, [sql, 26], params, format_regex, format_param_index, index_range_hash)

# #27
sql = "" '
SELECT "people".* FROM "people" INNER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = 1 WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND ((families.barcode_id = $1 or families.alternate_barcode_id = $1)) 
' ""
benchmark_queries(n, conn, [sql, 27], params, format_regex, format_param_index, index_range_hash)

puts "------Finish family related--------"
# #14
n = 1
sql = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = 1 AND (lower(email) = $1)
' ""
params = [""]
# people_emails = get_all_table_fields(conn, "people", "email")
people_emails = generate_random_email_params(n)
index_range_hash = {}
index_range_hash[0] = people_emails
format_regex = /\A[a-z\-_0-9\.%]+(\+[a-z\-_0-9\.%]+)?\@[a-z\-0-9\.]+\.[a-z\-]{2,}\z/i
format_param_index = 0
benchmark_queries(n, conn, [sql, 14], params, format_regex, format_param_index, index_range_hash)

# #15
sql = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = 1 AND (lower(alternate_email) = $1)
' ""
benchmark_queries(n, conn, [sql, 15], params, format_regex, format_param_index, index_range_hash)

# #16
n = 1000
sql = "" '
SELECT  "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND "people"."email" = $1  ORDER BY "people"."id" ASC LIMIT 1
' ""
benchmark_queries(n, conn, [sql, 16], params, format_regex, format_param_index, index_range_hash)

# #17
n = 1000
sql = "" '
SELECT  "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."email" = $1  ORDER BY "people"."id" ASC LIMIT 1
' ""
benchmark_queries(n, conn, [sql, 17], params, format_regex, format_param_index, index_range_hash)

# #25
n = 1000
sql = "" '
SELECT  "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND "people"."email" = $1  ORDER BY "people"."id" ASC LIMIT 1 
' ""
benchmark_queries(n, conn, [sql, 25], params, format_regex, format_param_index, index_range_hash)

# #18
n = 1000
# code: query = Person.undeleted.where(email: email).where.not(id: id || 0).where.not(family_id: family_id || 0).any?
sql = "" '
SELECT COUNT(*) FROM "people" WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND "people"."email" = $1 AND ("people"."id" != $2) AND ("people"."family_id" != $3)  
' ""
params = ["", 1, 1]
people_emails = generate_random_email_params(n)
index_range_hash = {}
index_range_hash[0] = people_emails
index_range_hash[1] = get_all_table_fields(conn, "people", "id")
index_range_hash[2] = get_all_table_fields(conn, "families", "id")
puts "#21"
benchmark_queries(n, conn, [sql, 18], params, format_regex, format_param_index, index_range_hash)

# #19
n = 1000
# code: family.people.undeleted.where(email: email).where.not(id: id)
# params $1 email $2 people.id $3 family_id
sql = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."family_id" = $3 AND "people"."deleted" = false AND "people"."email" = $1 AND ("people"."id" != $2)  ORDER BY "people"."position" ASC
' ""
benchmark_queries(n, conn, [sql, 19], params, format_regex, format_param_index, index_range_hash)

# #20
n = 1000
# code: family.people.undeleted.where(email: email).where.not(id: id).update_all(primary_emailer: false)
# params params $1 email $2 people.id $3 family_id
sql = "" '
UPDATE "people" SET "primary_emailer" = false WHERE "people"."id" IN (SELECT "people"."id" FROM "people" WHERE "people"."site_id" = 1 AND "people"."family_id" = $3 AND "people"."deleted" = false AND "people"."email" = $1 AND ("people"."id" != $2)  ORDER BY "people"."position" ASC)
' ""
benchmark_queries(n, conn, [sql, 20], params, format_regex, format_param_index, index_range_hash)

# #22
# code: Person.undeleted.where(email: email, api_key: api_key).first
# params $1 email $2 api_key
sql = "" '
SELECT  "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND "people"."email" = $1 AND "people"."api_key" = $2 ORDER BY "people"."id" ASC LIMIT 1
' ""
params = ["", ""]
index_range_hash = {}
people_emails = generate_random_email_params(n)
index_range_hash[0] = people_emails
index_range_hash[1] = get_all_table_fields(conn, "people", "api_key")
benchmark_queries(n, conn, [sql, 22], params, format_regex, format_param_index, index_range_hash)

puts "---------Finish email related query--------------"
n = 1000
# #13
# Code: Site.where(host: address.downcase.split("@").last).first
sql = "" '
SELECT  "sites".* FROM "sites" WHERE "sites"."host" = $1  ORDER BY "sites"."id" ASC LIMIT 1
' ""
params = [""]
site_hosts = generate_random_host_params(n)
index_range_hash = {}
index_range_hash[0] = site_hosts
format_param_index = 0
format_regex = /\A(https?:\/\/|www\.)/
benchmark_queries(n, conn, [sql, 13], params, format_regex, format_param_index, index_range_hash, false)

# #21
# code: Site.where(host: request.host, active: true).first
sql = "" '
SELECT  "sites".* FROM "sites" WHERE "sites"."host" = $1 AND "sites"."active" = true ORDER BY "sites"."id" ASC LIMIT 1 
' ""
benchmark_queries(n, conn, [sql, 21], params, format_regex, format_param_index, index_range_hash, false)

# close the db connection
conn.close
