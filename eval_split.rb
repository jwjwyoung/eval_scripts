
load "eval_mysql.rb"

# initialize the conn
db = "onebody200k_dev"
conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => db, :user => "jwy", :password => "")
mysql_conn = build_connection("onebody_dev")

# original:  Group.includes(:group_times).where('group_times.checkin_time_id is not null').order('group_times.ordering')
# q1:  Group.includes(:group_times).where('group_times.checkin_time_id is not null and groups.attendance = true').order('group_times.ordering')
# q2: Group.where(:attendance => false)

psql_before = "" '
SELECT "groups"."id" AS t0_r0, "groups"."name" AS t0_r1, "groups"."description" AS t0_r2, "groups"."meets" AS t0_r3, "groups"."location" AS t0_r4, "groups"."directions" AS t0_r5, "groups"."other_notes" AS t0_r6, "groups"."category" AS t0_r7, "groups"."creator_id" AS t0_r8, "groups"."private" AS t0_r9, "groups"."address" AS t0_r10, "groups"."members_send" AS t0_r11, "groups"."updated_at" AS t0_r12, "groups"."hidden" AS t0_r13, "groups"."approved" AS t0_r14, "groups"."link_code" AS t0_r15, "groups"."parents_of" AS t0_r16, "groups"."site_id" AS t0_r17, "groups"."blog" AS t0_r18, "groups"."email" AS t0_r19, "groups"."prayer" AS t0_r20, "groups"."attendance" AS t0_r21, "groups"."legacy_id" AS t0_r22, "groups"."gcal_private_link" AS t0_r23, "groups"."approval_required_to_join" AS t0_r24, "groups"."pictures" AS t0_r25, "groups"."cm_api_list_id" AS t0_r26, "groups"."photo_file_name" AS t0_r27, "groups"."photo_content_type" AS t0_r28, "groups"."photo_fingerprint" AS t0_r29, "groups"."photo_file_size" AS t0_r30, "groups"."photo_updated_at" AS t0_r31, "groups"."created_at" AS t0_r32, "groups"."latitude" AS t0_r33, "groups"."longitude" AS t0_r34, "groups"."membership_mode" AS t0_r35, "groups"."has_tasks" AS t0_r36, "groups"."share_token" AS t0_r37, "group_times"."id" AS t1_r0, "group_times"."group_id" AS t1_r1, "group_times"."checkin_time_id" AS t1_r2, "group_times"."sequence" AS t1_r3, "group_times"."site_id" AS t1_r4, "group_times"."created_at" AS t1_r5, "group_times"."updated_at" AS t1_r6, "group_times"."section" AS t1_r7, "group_times"."print_extra_nametag" AS t1_r8, "group_times"."checkin_folder_id" AS t1_r9, "group_times"."label_id" AS t1_r10 FROM "groups" LEFT OUTER JOIN "group_times" ON "group_times"."group_id" = "groups"."id" AND "group_times"."site_id" = 1 WHERE "groups"."site_id" = 1 AND (group_times.checkin_time_id is not null) order by group_times.sequence
' ""
psql_after = "" '
SELECT "groups"."id" AS t0_r0, "groups"."name" AS t0_r1, "groups"."description" AS t0_r2, "groups"."meets" AS t0_r3, "groups"."location" AS t0_r4, "groups"."directions" AS t0_r5, "groups"."other_notes" AS t0_r6, "groups"."category" AS t0_r7, "groups"."creator_id" AS t0_r8, "groups"."private" AS t0_r9, "groups"."address" AS t0_r10, "groups"."members_send" AS t0_r11, "groups"."updated_at" AS t0_r12, "groups"."hidden" AS t0_r13, "groups"."approved" AS t0_r14, "groups"."link_code" AS t0_r15, "groups"."parents_of" AS t0_r16, "groups"."site_id" AS t0_r17, "groups"."blog" AS t0_r18, "groups"."email" AS t0_r19, "groups"."prayer" AS t0_r20, "groups"."attendance" AS t0_r21, "groups"."legacy_id" AS t0_r22, "groups"."gcal_private_link" AS t0_r23, "groups"."approval_required_to_join" AS t0_r24, "groups"."pictures" AS t0_r25, "groups"."cm_api_list_id" AS t0_r26, "groups"."photo_file_name" AS t0_r27, "groups"."photo_content_type" AS t0_r28, "groups"."photo_fingerprint" AS t0_r29, "groups"."photo_file_size" AS t0_r30, "groups"."photo_updated_at" AS t0_r31, "groups"."created_at" AS t0_r32, "groups"."latitude" AS t0_r33, "groups"."longitude" AS t0_r34, "groups"."membership_mode" AS t0_r35, "groups"."has_tasks" AS t0_r36, "groups"."share_token" AS t0_r37, "group_times"."id" AS t1_r0, "group_times"."group_id" AS t1_r1, "group_times"."checkin_time_id" AS t1_r2, "group_times"."sequence" AS t1_r3, "group_times"."site_id" AS t1_r4, "group_times"."created_at" AS t1_r5, "group_times"."updated_at" AS t1_r6, "group_times"."section" AS t1_r7, "group_times"."print_extra_nametag" AS t1_r8, "group_times"."checkin_folder_id" AS t1_r9, "group_times"."label_id" AS t1_r10 FROM "groups" LEFT OUTER JOIN "group_times" ON "group_times"."group_id" = "groups"."id" AND "group_times"."site_id" = 1 WHERE "groups"."site_id" = 1 AND "groups"."attendance" = true AND (group_times.checkin_time_id is not null) order by group_times.sequence
' ""
sqls = [psql_before, psql_after, 7, "add predicate"]

mysql_before = psql_before.gsub("\"", "`")
mysql_after = psql_after.gsub("\"", "`")
m_sqls = [mysql_before, mysql_after, 7, "add predicate"]
n = 100
params_arr = [nil] * n

group = 1#00
t_psqls = []
t_mysqls = []
group.times do
  n = 100
  t_psql, plans_psql = benchmark_unusual_mysql_queries(n, conn, sqls, params_arr, ruby_stm = nil)
  t_mysql, plans_mysql = benchmark_unusual_mysql_queries(n, mysql_conn, m_sqls, params_arr, ruby_stm = nil)
  t_psqls << t_psql
  t_mysqls << t_mysql
end
t_psql_befores = t_psqls.map { |x| x[0].real }
t_psql_afters = t_psqls.map { |x| x[1].real }
t_mysql_befores = t_mysqls.map { |x| x[0].real }
t_mysql_afters = t_mysqls.map { |x| x[1].real }
print_data(t_psql_befores)
print_data(t_psql_afters)
print_data(t_mysql_befores)
print_data(t_mysql_afters)
