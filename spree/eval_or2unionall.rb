load File.join(File.dirname(__FILE__),  '../eval.rb')
load File.join(File.dirname(__FILE__),  '../eval_mysql.rb')

# initialize the conn
db = "spree"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "junwen", :password => "1234")
mysql_conn = build_connection(db)

# #8 scope :eligible, -> {where(is_master: false).or(where(<<-SQL variants.id IN (SELECT MIN(variants.id) FROM variants GROUP BY product_id HAVING COUNT(*)=1))}
n = 10#00
psql_query = ""'
SELECT "spree_variants".* FROM "spree_variants" WHERE "spree_variants"."deleted_at" IS NULL AND ("spree_variants"."is_master" = FALSE OR (            "spree_variants".id IN (
    SELECT MIN("spree_variants".id) FROM "spree_variants"
    GROUP BY "spree_variants".product_id
    HAVING COUNT(*) = 1
  )
))
'""
psql_query2 = ""'
SELECT "spree_variants".* FROM "spree_variants" WHERE "spree_variants"."deleted_at" IS NULL AND ("spree_variants"."is_master" = FALSE )
    UNION ALL
    SELECT "spree_variants".* FROM "spree_variants" WHERE "spree_variants"."deleted_at" IS NULL AND
     (            "spree_variants".id IN (
    SELECT MIN("spree_variants".id) FROM "spree_variants"
    GROUP BY "spree_variants".product_id
    HAVING COUNT(*) = 1)
    )
'""

mysql_query = psql_query.gsub("\"", "`")
mysql_query2 = psql_query2.gsub("\"", "`")


sqls = [psql_query, psql_query2, 8, "or 2 union all"]
m_sqls = [mysql_query, mysql_query2, 8, "or 2 union all"]
params_arr = generate_params(n, nil, nil)
result = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
result2 = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)

if $final_re
  $final_re << [result[0], result[1], result2[0], result2[1], n, sqls, sqls[-2]]
end