
load "eval.rb"

def write_format(final_re)
    log_file = open("format_#{$perc}.log", "w")
    query_plan_file = open("queryplan.log", "w")
    final_re = final_re.sort { |a, b| a[-1] <=> b[-1] }
    log_file.write("# psql_before psql_after psql_sp mysql_before mysql_after mysql_sp\n")
    final_re.each do |t_psql, plans_psql, t_mysql, plans_mysql, n, sqls, num|
    psql_before = t_psql[0].real * 1000 / n
    psql_after = t_psql[1].real * 1000 / n
    psql_sp = (psql_before / psql_after * 100).to_i / 100.0
    mysql_before = t_mysql[0].real * 1000 / n
    mysql_after = t_mysql[1].real * 1000 / n
    mysql_sp = (mysql_before / mysql_after * 100).to_i / 100.0
    log_file.write("#{num} #{psql_before.round(2)} #{psql_after.round(2)} #{psql_sp} #{mysql_before.round(2)} #{mysql_after.round(2)} #{mysql_sp}\n")
    query_plan_file.write("#{num}\n")
    query_plan_file.write("#{sqls.join(" ")}\n")
    plans_psql.each do |plan|
        if plan
        query_plan_file.write("#{plan.map { |r| r.values }.join("\n")}\n")
        query_plan_file.write("--------------------------------------\n")
        end
    end
    query_plan_file.write("*************************\n")
    plans_mysql.each do |plan|
        if plan
        query_plan_file.write("#{plan.map { |r| r }.to_s}\n")
        query_plan_file.write("--------------------------------------\n")
        end
    end
    query_plan_file.write("*************************\n")
    end
    log_file.close
    query_plan_file.close
end

def eval_perc(perc)
    $perc = perc
    $final_re = []
    load "eval_format_check.rb"
    write_format($final_re)    
end

[0.0, 1.0].each do |perc|
    eval_perc(perc)
end