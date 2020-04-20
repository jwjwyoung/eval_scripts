load "./eval.rb"
load "./eval_mysql.rb"
# only 1 sql query is needed, since we will add check before issuing the queries
# two connection is needed one for the db with original type, the other for inclusion to int type
inclusion_params = []

def benchmark_inclusion_queries(n, conns, sql, values)
  conn = conns[0]
  db_type = "PSQL"
  db_type = "MySQL" if conn.instance_of? Mysql2::Client
  puts sql[0]
  puts "****#{db_type}:****#{sql[1]}**inclusion**for #{n} times******"
  params_arr = generate_params(n, [""], { 0 => values })
  integer_params_arr = params_arr.map { |x| [values.index(x[0])] }
  sql_queries_before = []
  sql_queries_after = []
  for i in 0...n
    sql_queries_before << generate_query(sql[0], params_arr[i])
    sql_queries_after << generate_query(sql[0], integer_params_arr[i])
  end
  plan_before = conns[0].query("explain #{sql_queries_before[0]}")
  plan_after = conns[1].query("explain #{sql_queries_after[0]}")
  time = Benchmark.bm do |x|
    x.report { for i in 0...n; conns[0].query(sql_queries_before[i]); end }
    x.report { for i in 0...n; conns[1].query(sql_queries_after[i]); end }
  end
  return time, [plan_before, plan_after]
end

# initialize the conn
db_before = "onebody200k_dev"
db_after = "onebody200k_dev_changeStr2Int"
conn_before = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db_before, :user => "jwy", :password => "")
conn_after = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db_after, :user => "jwy", :password => "")
conns = [conn_before, conn_after]
mysql_conn_before = build_connection("onebody_dev")
mysql_conn_after = build_connection("onebody_dev_changeStr2Int")
mysql_conns = [mysql_conn_before, mysql_conn_after]
# #6
n = 1000
sql = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."gender" = $1
' ""
mysql_sql = "
SELECT `people`.* FROM `people` WHERE `people`.`site_id` = 1 AND `people`.`gender` = $1
"
values = [nil, "female", "male"]
inclusion_params << [n, conns, [sql, 6], mysql_conns, [mysql_sql, 6], values]
# benchmark_inclusion_queries(n, conns, [sql, 7], values)
# benchmark_inclusion_queries(n, mysql_conns, [mysql_sql, 7], values)

# #1
n = 10
sql = "" '
SELECT "custom_fields".* FROM "custom_fields" WHERE "custom_fields"."site_id" = 1 AND "custom_fields"."format" = $1
' ""
mysql_sql = "
SELECT `custom_fields`.* FROM `custom_fields` WHERE `custom_fields`.`site_id` = 1 AND `custom_fields`.`format` = $1
"
values = ["string", "number", "boolean", "date"]

# benchmark_inclusion_queries(n, conns, [sql, 1], values)
# benchmark_inclusion_queries(n, mysql_conns, [mysql_sql, 1], values)
inclusion_params << [n, conns, [sql, 1], mysql_conns, [mysql_sql, 1], values]

inclusion_params.each do |n, conns, sql, mysql_conns, mysql_sql, values|
  n = 100
  n = 1
  t_psqls = []
  t_mysqls = []
  group = 1000
  group.times do
    t_psql, plans_psql = benchmark_inclusion_queries(n, conns, sql, values)
    t_mysql, plans_mysql = benchmark_inclusion_queries(n, mysql_conns, mysql_sql, values)
    t_psqls << t_psql
    t_mysqls << t_mysql
  end
  t_psql_befores = t_psqls.map { |x| x[0].real }
  t_psql_afters = t_psqls.map { |x| x[1].real }
  t_mysql_befores = t_mysqls.map { |x| x[0].real }
  t_mysql_afters = t_mysqls.map { |x| x[1].real }
  print_data(t_psql_befores)
  print_data(t_psql_afters)
  print_data(t_mysql_befores)
  print_data(t_mysql_afters)
  #$final_re << [t_psql, plans_psql, t_mysql, plans_mysql, n, sql, sql[-1]]
end
