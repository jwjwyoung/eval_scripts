load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
# mysql_conn = build_connection(db)


# #2 
# Code: Spree::Variant.where(product_id: variant.product_id, is_master: variant.is_master?).in_stock_or_backorderable
n = 1000
psql_query = ""'
SELECT "spree_variants".* FROM "spree_variants" INNER JOIN "spree_stock_items" ON "spree_stock_items"."deleted_at" IS NULL AND "spree_stock_items"."variant_id" = "spree_variants"."id" WHERE "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = $1 AND "spree_variants"."is_master" = $2 AND ((count_on_hand > 0 OR track_inventory = FALSE) OR "spree_stock_items"."backorderable" = TRUE)
'""
psql_query2 = ""'
SELECT "spree_variants".* FROM "spree_variants" INNER JOIN "spree_stock_items" ON "spree_stock_items"."deleted_at" IS NULL AND "spree_stock_items"."variant_id" = "spree_variants"."id" WHERE "spree_variants"."deleted_at" IS NULL AND "spree_variants"."product_id" = $1 AND "spree_variants"."is_master" = $2 AND ((count_on_hand > 0 OR track_inventory = FALSE) OR "spree_stock_items"."backorderable" = TRUE) LIMIT 1
'""
sql_query = psql_query.gsub("\"", "`")
params = [1, true]
product_ids = get_all_table_fields(conn, "spree_variants", "product_id")
is_master = [true, false]
index_hash_array = {}
index_hash_array[0] = product_ids
index_hash_array[1] = is_master
sqls = [psql_query, psql_query2, 2, "add limit 1"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
puts result[1][0].map{|row| row.values}.join("\n")
puts "===="
puts result[1][1].map{|row| row.values}.join("\n")