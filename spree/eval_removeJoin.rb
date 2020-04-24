load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #12
n = 1000
psql_query = ""'
SELECT DISTINCT "spree_products".* FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products_taxons"."product_id" = "spree_products"."id" INNER JOIN "spree_taxons" ON "spree_taxons"."id" = "spree_products_taxons"."taxon_id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_taxons"."id" IN $1
'""
psql_query2 = ""'
SELECT DISTINCT "spree_products".* FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products_taxons"."product_id" = "spree_products"."id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_products_taxons"."taxon_id" IN $1
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")

params = [[1]]
taxons = get_all_table_fields(conn, "spree_taxons", "id")
index_hash_array = {}
index_hash_array[0] = taxons
sqls = [psql_query, psql_query2, 12, "remove join"]
m_sqls = [sql_query, sql_query2, 12, "remove join"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)