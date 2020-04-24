load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')


# initialize the conn
db = "PracticalDeveloper_development"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "jwy", :password => "")
# mysql_conn = build_connection(db)

n = 100
psql_query = ""'
SELECT "articles".* FROM "articles" WHERE "articles"."published" = true AND NOT (("articles"."video" = \'\'  OR "articles"."video" IS NULL)) AND NOT (("articles"."video_thumbnail_url" = \'\' OR "articles"."video_thumbnail_url" IS NULL)) AND (score > -4)
'""
psql_query2 = ""'
SELECT  "articles".* FROM "articles" INNER JOIN "users" ON "users"."id" = "articles"."user_id" WHERE (users.created_at < \'2020-04-08 18:39:14.151587\') AND "articles"."published" = true AND NOT (("articles"."video" = \'\'  OR "articles"."video" IS NULL)) AND NOT (("articles"."video_thumbnail_url" = \'\'  OR "articles"."video_thumbnail_url" IS NULL)) AND (articles.score > -4)
'""

sqls = [psql_query, psql_query2, 62, "add join"]
result = benchmark_unusual_mysql_queries(n, conn, sqls, [nil] * n, ruby_stm = nil)
puts "==========before============"
puts result[1][0].map{|row| row.values}.join("\n")
puts "==========after============"
puts result[1][1].map{|row| row.values}.join("\n")
puts "==========Finish============"
