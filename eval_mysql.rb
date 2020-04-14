require 'mysql2'

def build_connection(dbname)
    client = Mysql2::Client.new(:host => "localhost", :username => "root")
    use_db_query = "use #{dbname}"
    client.query(use_db_query)
    return client
end

def generate_query(base_sql, params)
    sql = base_sql
    for i in 0...params.length
        p = params[i]
        sql = sql.gsub("$#{i+1}", "\"#{p}\"")
    end
    return sql
end

def execute_mysql_with_format(conn, sql, format_regex, format_parameter)
    if format_parameter =~ format_regex
        conn.query(sql)
    end
end

def execute_mysql_without_format(conn, sql, format_regex, format_parameter)
    unless format_parameter =~ format_regex
        conn.query(sql)
    end
end

# only 1 sql query is needed, since we will add check before issuing the queries
def benchmark_format_mysql_queries(n, conn, sql, params, format_regex, format_param_index, index_range_hash, with = true)
    puts sql[0]
    puts format_regex
    puts "********#{sql[1]}**********"
    params_arr = generate_params(n, params, index_range_hash)
    format_parameters = params_arr.map { |row| row[format_param_index] }
    puts format_parameters.select { |x| x =~ format_regex }.length
    sql_queries = []
    for i in 0...n
        sql_queries << generate_query(sql[0], params_arr[i])
    end
    if with
      Benchmark.bm do |x|
        x.report { for i in 0...n; conn.query(sql_queries[i]); end }
        x.report { for i in 0...n; execute_mysql_with_format(conn, sql_queries[i], format_regex, format_parameters[i]); end }
      end
    else
        Benchmark.bm do |x|
            x.report { for i in 0...n; conn.query(sql_queries[i]); end }
            x.report { for i in 0...n; execute_mysql_without_format(conn, sql_queries[i], format_regex, format_parameters[i]); end }
        end
    end
  end

