load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #11
n = 1000
psql_query = ""'
SELECT DISTINCT "spree_products".* FROM "spree_products" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" AND "spree_prices"."currency" = $1 WHERE "spree_products"."deleted_at" IS NULL AND "spree_prices"."amount" BETWEEN $2 AND $3 AND "spree_prices"."currency" = $1
'""
psql_query2 = ""'
SELECT "spree_products".* FROM "spree_products" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = TRUE INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" AND "spree_prices"."currency" = $1 WHERE "spree_products"."deleted_at" IS NULL AND "spree_prices"."amount" BETWEEN $2 AND $3 AND "spree_prices"."currency" = $1
'""
params = ['', 1.0, 2.0]
currencies = get_all_table_fields(conn, "spree_prices", "currency")
prices = get_all_table_fields(conn, "spree_prices", "amount")
index_hash_array = {}
index_hash_array[0] = currencies
index_hash_array[1] = prices
index_hash_array[2] = prices
sqls = [psql_query, psql_query2, 11, "remove distinct"]
m_sqls = [sql_query, sql_query2, 11, "remove distinct"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)