require "mysql2"
require "pg"
require "benchmark"

def print_data(data_arr)
  puts "#{data_arr.max} #{data_arr.min} #{data_arr.inject(0, :+) / data_arr.length}"
end

def build_connection(dbname)
  client = Mysql2::Client.new(:host => "localhost", :username => "root")
  use_db_query = "use #{dbname}"
  client.query(use_db_query)
  return client
end

def generate_query(base_sql, params)
  sql = base_sql
  if params
    for i in 0...params.length
      p = params[i]
      if p.class != Array
        if p == nil or p.class == String
          p = p.gsub("'", "") if p
          sql = sql.gsub("$#{i + 1}", "\'#{p}\'")
        else
          sql = sql.gsub("$#{i + 1}", "#{p}")
        end
      else
        if p[0].class == String
          sql = sql.gsub("$#{i + 1}", "(#{p.map{|x| "\'#{x}\'"}.join(",")})")
        else
          sql = sql.gsub("$#{i + 1}", "(#{p.join(",")})")
        end
      end
      #puts "#{p.class} #{sql}"
    end
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
def benchmark_format_mysql_queries(n, conn, sql, params_arr, format_regex, format_param_index, with = true)
  db_type = "PSQL"
  db_type = "MySQL" if conn.instance_of? Mysql2::Client
  puts sql[0]
  puts format_regex
  puts "****#{db_type}:****#{sql[1]}**format check**on #{n}******"
  format_parameters = params_arr.map { |row| row[format_param_index] }
  puts params_arr.select { |x| x[format_param_index] =~ format_regex }.length
  sql_queries = []
  for i in 0...n
    sql_queries << generate_query(sql[0], params_arr[i])
  end
  plan_before = conn.query("explain #{sql_queries[0]}")
  if with
    time = Benchmark.bm do |x|
      x.report { for i in 0...n; conn.query(sql_queries[i]); end }
      x.report { for i in 0...n; execute_mysql_with_format(conn, sql_queries[i], format_regex, format_parameters[i]); end }
    end
  else
    time = Benchmark.bm do |x|
      x.report { for i in 0...n; conn.query(sql_queries[i]); end }
      x.report { for i in 0...n; execute_mysql_without_format(conn, sql_queries[i], format_regex, format_parameters[i]); end }
    end
  end
  return time, [plan_before, nil]
end

def benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
  db_type = "PSQL"
  db_type = "MySQL" if conn.instance_of? Mysql2::Client
  puts "****#{db_type}:****#{sqls[-2..-1]}****on #{n}******"
  sql_before_queries = []
  sql_after_queries = []
  for i in 0...n
    sql_before_queries << generate_query(sqls[0], params_arr[i])
    if sqls[-1].include? "limit N"
        limit_sql = generate_query(sqls[1], params_arr[i]) + " limit #{params_arr[i][-1].uniq.length}"
        sql_after_queries << limit_sql
    else
      sql_after_queries << generate_query(sqls[1], params_arr[i])
    end
  end
  plan_before = conn.query("explain #{sql_before_queries[0]}")
  plan_after = conn.query("explain #{sql_after_queries[0]}")
  unless ruby_stm
    time = Benchmark.bm do |x|
      x.report { for i in 0...n; conn.query(sql_before_queries[i]); end }
      x.report { for i in 0...n; conn.query(sql_after_queries[i]); end }
    end
  else
    time = Benchmark.bm do |x|
      x.report { for i in 0...n; conn.query(sql_before_queries[i]); end }
      x.report { for i in 0...n; results = conn.query(sql_after_queries[i]); eval("#{ruby_stm}"); end }
    end
  end
  return time, [plan_before, plan_after]
end
