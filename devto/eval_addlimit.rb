load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "PracticalDeveloper_development"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "jwy", :password => "")
# mysql_conn = build_connection(db)



# #3
n = 1000
psql_query = ""'
SELECT "podcast_episodes".* FROM "podcast_episodes" WHERE (("podcast_episodes"."media_url" = $1 OR "podcast_episodes"."title" = $2) OR "podcast_episodes"."guid" = $3) 
'""
psql_query2 = ""'
SELECT "podcast_episodes".* FROM "podcast_episodes" WHERE (("podcast_episodes"."media_url" = $1 OR "podcast_episodes"."title" = $2) OR "podcast_episodes"."guid" = $3) limit 1
'""
sql_query = psql_query.gsub("\"", "`")
params = ["", "", ""]
podcast_epi_media_urls = get_all_table_fields(conn, "podcast_episodes", "media_url")
podcast_epi_media_titles = get_all_table_fields(conn, "podcast_episodes", "title")
podcast_epi_media_guids = get_all_table_fields(conn, "podcast_episodes", "guid")
index_hash_array = {}
index_hash_array[0] = podcast_epi_media_urls
index_hash_array[1] = podcast_epi_media_titles
index_hash_array[2] = podcast_epi_media_guids
sqls = [psql_query, psql_query2, 3, "add limit 1"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
puts result[1][0].map{|row| row.values}.join("\n")
puts "===="
puts result[1][1].map{|row| row.values}.join("\n")

# #4
n = 1000
psql_query = ""'
SELECT "users".* FROM "users" WHERE "users"."username" IN $1
'""
sql_query = psql_query.gsub("\"", "`")
params = [['']]
user_usernames = get_all_table_fields(conn, "users", "username")
index_hash_array = {}
index_hash_array[0] = user_usernames
sqls = [psql_query, psql_query, 4, "add limit N"]
params_arr = generate_params(n, params, index_hash_array)
benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)

