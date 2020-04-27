load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #11
n = 10#00
psql_query = ""'
SELECT DISTINCT "spree_products".* FROM "spree_products" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" AND "spree_prices"."currency" = $1 WHERE "spree_products"."deleted_at" IS NULL AND "spree_prices"."amount" BETWEEN $2 AND $3 AND "spree_prices"."currency" = $1
'""
psql_query2 = ""'
SELECT "spree_products".* FROM "spree_products" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = TRUE INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" AND "spree_prices"."currency" = $1 WHERE "spree_products"."deleted_at" IS NULL AND "spree_prices"."amount" BETWEEN $2 AND $3 AND "spree_prices"."currency" = $1
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
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

if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end



# #9
n = 1000
psql_query = ""'
SELECT DISTINCT spree_products.*, spree_products_taxons.position FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products"."id" = "spree_products_taxons"."product_id" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_products_taxons"."taxon_id" = $1 AND ("spree_products".discontinue_on IS NULL or "spree_products".discontinue_on >= \'2020-04-27 19:17:33.866307\') AND ("spree_products".available_on <= \'2020-04-27 19:17:33.866274\') ORDER BY "spree_products_taxons"."position"
'""
psql_query2 = ""'
SELECT spree_products.*, spree_products_taxons.position FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products"."id" = "spree_products_taxons"."product_id" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_products_taxons"."taxon_id" = $1 AND ("spree_products".discontinue_on IS NULL or "spree_products".discontinue_on >= \'2020-04-27 19:17:33.866307\') AND ("spree_products".available_on <= \'2020-04-27 19:17:33.866274\') ORDER BY "spree_products_taxons"."position"
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
params = ['', 1.0, 2.0]
taxon_ids = get_all_table_fields(conn, "spree_taxons", "id")
index_hash_array = {}
index_hash_array[0] = taxon_ids
sqls = [psql_query, psql_query2, 9, "remove distinct"]
m_sqls = [sql_query, sql_query2, 9, "remove distinct"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)

if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end



# #10
n = 1000
psql_query = ""'
SELECT DISTINCT spree_products.*, spree_products_taxons.position FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products"."id" = "spree_products_taxons"."product_id" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_products_taxons"."taxon_id" = $1 AND ("spree_products".discontinue_on IS NULL or "spree_products".discontinue_on >= \'2020-04-27 19:27:11.050118\') AND ("spree_products".available_on <= \'2020-04-27 19:27:11.050108\') AND NOT (spree_products.id in $2) ORDER BY "spree_products_taxons"."position"
'""
psql_query2 = ""'
SELECT spree_products.*, spree_products_taxons.position FROM "spree_products" INNER JOIN "spree_products_taxons" ON "spree_products"."id" = "spree_products_taxons"."product_id" INNER JOIN "spree_variants" ON "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = "spree_products"."id" AND "spree_variants"."is_master" = true INNER JOIN "spree_prices" ON "spree_prices"."deleted_at" IS NULL AND "spree_prices"."variant_id" = "spree_variants"."id" WHERE "spree_products"."deleted_at" IS NULL AND "spree_products_taxons"."taxon_id" = $1 AND ("spree_products".discontinue_on IS NULL or "spree_products".discontinue_on >= \'2020-04-27 19:27:11.050118\') AND ("spree_products".available_on <= \'2020-04-27 19:27:11.050108\') AND NOT (spree_products.id in $2) ORDER BY "spree_products_taxons"."position"
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
params = [1, [1,2]]
taxon_ids = get_all_table_fields(conn, "spree_taxons", "id")
product_ids = get_all_table_fields(conn, "spree_products", "id")
index_hash_array = {}
index_hash_array[0] = taxon_ids
index_hash_array[1] = product_ids
sqls = [psql_query, psql_query2, 10, "remove distinct"]
m_sqls = [sql_query, sql_query2, 10, "remove distinct"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)

if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end
