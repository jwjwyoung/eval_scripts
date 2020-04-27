load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #1
# Code: (product.)classifications.where(taxon: taxon)
n = 1000
psql_query = ""'
SELECT "spree_products_taxons".* FROM "spree_products_taxons" WHERE "spree_products_taxons"."product_id" = $1 AND "spree_products_taxons"."taxon_id" = $2
'""
psql_query2 = ""'
SELECT "spree_products_taxons".* FROM "spree_products_taxons" WHERE "spree_products_taxons"."product_id" = $1 AND "spree_products_taxons"."taxon_id" = $2 LIMIT 1
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
params = [1, true]
product_ids = get_all_table_fields(conn, "spree_products", "id")
taxon_ids = get_all_table_fields(conn, "spree_taxons", "id")
index_hash_array = {}
index_hash_array[0] = product_ids
index_hash_array[1] = taxon_ids
sqls = [psql_query, psql_query2, 1, "add limit 1"]
m_sqls = [sql_query, sql_query2, 1, "add limit 1"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end

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
sql_query2 = psql_query2.gsub("\"", "`")
params = [1, true]
product_ids = get_all_table_fields(conn, "spree_variants", "product_id")
is_master = [true, false]
index_hash_array = {}
index_hash_array[0] = product_ids
index_hash_array[1] = is_master
sqls = [psql_query, psql_query2, 2, "add limit 1"]
m_sqls = [sql_query, sql_query2, 2, "add limit 1"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
# puts "before"
# puts result[1][0].map{|row| row.values}.join("\n")
# puts "===="
# puts "after"
# puts result[1][1].map{|row| row.values}.join("\n")
# puts "before"
# puts result2[1][0].map{|row| row}.join("\n")
# puts "===="
# puts "after"
# puts result2[1][1].map{|row| row}.join("\n")
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end


n = 1000
psql_query = ""'
SELECT COUNT(*) FROM "spree_stores" WHERE "spree_stores"."default" = true
'""
psql_query2 = ""'
SELECT 1 FROM "spree_stores" WHERE "spree_stores"."default" = true LIMIT 1
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
sqls = [psql_query, psql_query2, 3, "add limit 1"]
m_sqls = [sql_query, sql_query2, 3, "add limit 1"]
params_arr = generate_params(n, nil, nil)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end




# #1
# Code: (product.)classifications.where(taxon: taxon)
n = 1000
psql_query = ""'
SELECT "spree_states".* FROM "spree_states" WHERE "spree_states"."country_id" = $1 AND (name = $2 OR abbr = $2)
'""
psql_query2 = ""'
SELECT "spree_states".* FROM "spree_states" WHERE "spree_states"."country_id" = $1 AND (name = $2 OR abbr = $2) LIMIT 1
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
params = [1, ""]
country_ids = get_all_table_fields(conn, "spree_countries", "id")
name_abbrs = get_all_table_fields(conn, "spree_states", "name") + get_all_table_fields(conn, "spree_states", "abbr")
index_hash_array = {}
index_hash_array[0] = country_ids
index_hash_array[1] = name_abbrs
sqls = [psql_query, psql_query2, 5, "add limit 1"]
m_sqls = [sql_query, sql_query2, 5, "add limit 1"]
params_arr = generate_params(n, params, index_hash_array)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end