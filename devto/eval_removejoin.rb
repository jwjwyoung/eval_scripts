load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "PracticalDeveloper_development"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "jwy", :password => "")
# mysql_conn = build_connection(db)


# #8 remove join
n = 1000
psql_query = ""'
SELECT "chat_channel_memberships"."chat_channel_id" FROM "chat_channel_memberships" LEFT OUTER JOIN "chat_channels" ON "chat_channels"."id" = "chat_channel_memberships"."chat_channel_id" WHERE "chat_channel_memberships"."user_id" = $1 AND "chat_channel_memberships"."has_unopened_messages" = true
'""
psql_query2 = ""'
SELECT "chat_channel_memberships"."chat_channel_id" FROM "chat_channel_memberships" WHERE "chat_channel_memberships"."user_id" = $1 AND "chat_channel_memberships"."has_unopened_messages" = true
'""

params = [1]
chat_channel_memberships_user_ids = get_all_table_fields(conn, "chat_channel_memberships", "user_id")
index_hash_array = {}
index_hash_array[0] = chat_channel_memberships_user_ids
sqls = [psql_query, psql_query2, 8, "remove join"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
puts result[1][0].map{|row| row.values}.join("\n")
puts "===="
puts result[1][1].map{|row| row.values}.join("\n")