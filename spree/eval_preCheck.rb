load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #12
n = 1000
psql_query = ""'
SELECT "spree_users".* FROM "spree_users" WHERE "spree_users"."deleted_at" IS NULL AND "spree_users"."email" = $1 ORDER BY "spree_users"."id" ASC LIMIT 1
'""
sql_query = psql_query.gsub("\"", "`")
$perc = 0.3 unless $perc
format_regex = /\A[^@\s]+@[^@\s]+\z/
params_arr = generate_random_email_params(n,$perc).map{|x| [x]}
format_param_index = 0
result = benchmark_format_mysql_queries(n, conn, [psql_query, 28, "format check"], params_arr, format_regex, format_param_index, with = true)
result2 = benchmark_format_mysql_queries(n, mysql_conn, [sql_query, 28, "format check"], params_arr, format_regex, format_param_index, with = true)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end

psql_query = ""'
SELECT "spree_orders".* FROM "spree_orders" WHERE "spree_orders"."email" = $1
'""
sql_query = psql_query.gsub("\"", "`")
format_regex = /\A[^@\s]+@[^@\s]+\z/
params_arr = generate_random_email_params(n,$perc).map{|x| [x]}
format_param_index = 0
result = benchmark_format_mysql_queries(n, conn, [psql_query, 27, "format check"], params_arr, format_regex, format_param_index, with = true)
result2 = benchmark_format_mysql_queries(n, mysql_conn, [sql_query, 27, "format check"], params_arr, format_regex, format_param_index, with = true)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end