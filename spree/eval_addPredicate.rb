load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #1
# Code: (product.)classifications.where(taxon: taxon)
n = 100
psql_query = ""'
SELECT "spree_variants".* FROM "spree_variants" INNER JOIN "spree_stock_items" ON "spree_stock_items"."deleted_at" IS NULL AND "spree_stock_items"."variant_id" = "spree_variants"."id" WHERE "spree_variants"."deleted_at" IS NULL AND (count_on_hand > 0 OR track_inventory = FALSE)
'""
psql_query2 = ""'
SELECT "spree_variants".* FROM "spree_variants" INNER JOIN "spree_stock_items" ON "spree_stock_items"."deleted_at" IS NULL AND "spree_stock_items"."variant_id" = "spree_variants"."id" WHERE "spree_variants"."deleted_at" IS NULL AND ((backorderable and count_on_hand > 0 )OR track_inventory = FALSE)
'""
sql_query = psql_query.gsub("\"", "`")
sql_query2 = psql_query2.gsub("\"", "`")
params = [1, true]
product_ids = get_all_table_fields(conn, "spree_products", "id")
taxon_ids = get_all_table_fields(conn, "spree_taxons", "id")
params_arr = generate_params(n, nil, nil)
sqls = [psql_query, psql_query2, 6, "add predicate"]
m_sqls = [sql_query, sql_query2, 6, "add predicate"]
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
if $final_re
    $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end
