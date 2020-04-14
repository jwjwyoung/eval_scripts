load "./eval.rb"

# only 1 sql query is needed, since we will add check before issuing the queries
# two connection is needed one for the db with original type, the other for inclusion to int type
def benchmark_inclusion_queries(n, conns, sql, values)
  puts sql[0]
  puts "********#{sql[1]}**********"
  puts "#{n} times on db: #{conns[0].db} & #{conns[1].db}"
  params_arr = generate_params(n, [""], {0 => values})
  integer_params_arr = params_arr.map{|x| [values.index(x[0])]}
  Benchmark.bm do |x|
    x.report { for i in 0...n; execute_sql_before(conns[0], sql[0], params_arr[i]); end }
    x.report { for i in 0...n; execute_sql_before(conns[1], sql[0], integer_params_arr[i]); end }
  end
end

# initialize the conn
db_before = "onebody200k_dev"
db_after = "onebody200k_dev_changeStr2Int"
conn_before = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db_before, :user => "jwy", :password => "")
conn_after = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db_after, :user => "jwy", :password => "")
conns = [conn_before, conn_after]

# #7
n = 100
sql = ""'
SELECT "people".* FROM "people" WHERE "people"."site_id" = 1 AND "people"."gender" = $1
'""
values = [nil, 'female', 'male']
benchmark_inclusion_queries(n, conns, [sql, 7], values)

# #1
n = 1000
sql = ""'
SELECT "custom_fields".* FROM "custom_fields" WHERE "custom_fields"."site_id" = 1 AND "custom_fields"."format" = $1
'""
values = ['string', 'number', 'boolean', 'date']


benchmark_inclusion_queries(n, conns, [sql, 1], values)

conns.each do |conn|
    conn.close
end