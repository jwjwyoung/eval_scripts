require "pg"
require "benchmark"
require "faker"

def execute_sql(conn, sql, params, format_check, ruby_stm = nil)
  if sql.class != Array
    if sql.include? "$"
      results = conn.exec_params(sql, params)
    else
      results = conn.exec(sql)
    end
    if ruby_stm
      stm = ruby_stm.gsub("$1", params[0])
      #puts stm
      eval("#{ruby_stm}")
    end
  else
    for s in sql
      execute_sql(conn, s, params, format_check)
    end
  end
end

def execute_sql_before(conn, sql, params)
  if sql.include? "$"
    results = conn.exec_params(sql, params)
  else
    results = conn.exec(sql)
  end
end

def generate_random_host_params(n, perc=0.3)
  results = []
  valid_size = (n * perc).to_i
  invalid_size = n - valid_size
  valid_size.times do 
    results << Faker::Internet.email.split("@").last
  end
  invalid_size.times do 
    results << Faker::Internet.url
  end
  return results.shuffle
end

def generate_random_email_params(n,perc=0.3)
  results = []
  valid_size = (n * perc).to_i
  invalid_size = n - valid_size
  valid_size.times do 
    results << Faker::Internet.email
  end
  invalid_size.times do 
    results << "#{Faker::Code.ean}"
  end
  return results.shuffle
end

def generate_random_barcode_id_params(n,perc=0.3)
  results = []
  valid_size = (n * perc).to_i
  invalid_size = n - valid_size
  valid_size.times do 
    results << Faker::Code.ean
  end
  invalid_size.times do 
    results << "#{Faker::Name.first_name}"
  end
  return results.shuffle
end

def execute_sql_after(conn, sql, params, format_regex, format_parameter)
  if format_parameter =~ format_regex
    execute_sql_before(conn, sql, params)
  end
end

def execute_sql_after_without(conn, sql, params, format_regex, format_parameter)
  unless format_parameter =~ format_regex
    execute_sql_before(conn, sql, params)
  end
end

def benchmark_queries(n, conn, sqls, params, index_range_hash, ruby_stm = nil)
  params_arr = generate_params(n, params, index_range_hash)
  puts "********#{sqls[-2..-1]} run #{n} times on #{conn.db}**********"
  Benchmark.bm do |x|
    x.report { for i in 0...n; execute_sql(conn, sqls[0], params_arr[i], nil); end }
    x.report { for i in 0...n; execute_sql(conn, sqls[1], params_arr[i], nil, ruby_stm); end }
  end
end

def generate_params(n, params, index_range_hash)
  results = []
  for i in 0...n
    if params
      p = params.dup
      for key, value in index_range_hash
        length = value.length
        if params[key].class == Array
          arr = []
          arr_size = 1 + rand(30)
          arr_size.times do
            v = value[rand(length)]
            # if params[key][0].class == Fixnum
            #     v = v.to_i
            # end
            arr << v
          end
          p[key] = arr
        else
          p[key] = value[rand(length)]
          if params[key].class == Fixnum
            p[key] = p[key].to_i
          end
        end
      end
    else
      p = nil
    end
    results << p
  end
  return results
end

def get_all_table_fields(conn, table, field)
  sql = "select #{field} from #{table}"
  res = conn.exec(sql)
  results = []
  for i in 0...res.ntuples
    results << res[i]["#{field}"]
  end
  return results
end
