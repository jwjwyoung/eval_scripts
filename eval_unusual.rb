load "./eval.rb"
load "./eval_mysql.rb"

conn = PG.connect(:hostaddr => "127.0.0.1", :port => 5432, :dbname => "onebody200k_dev", :user => "jwy", :password => "")
dbname = "onebody_dev"
mysql_conn = build_connection(dbname)
# or for a non IP address :host => 'my.host.name.com' instead of hostaddr
run_params = []

# remove join #2
sql_before = "SELECT COUNT(*) FROM people INNER JOIN families ON families.id = people.family_id AND families.site_id = 1 WHERE people.site_id = 1"
sql_after = "select count(*) from people"
# benchmark_queries(1000, conn, [sql_before, sql_after, 2], nil, nil)
n = 1 #000
sqls = [sql_before, sql_after, 2, "remove join"]
run_params << [n, conn, sqls, sqls, nil, nil, nil]
params_arr = generate_params(n, nil, nil)
# benchmark_unusual_mysql_queries(n, mysql_conn, sqls, params_arr) #keep the original sqls since it works under both db

# add limit 1 #4
sql_before = "" '
UPDATE "people" SET "primary_emailer" = false WHERE "people"."id" IN (SELECT "people"."id" FROM "people" WHERE "people"."site_id" = $1 AND "people"."family_id" = $2 AND "people"."deleted" = $3 AND "people"."email" = $4 AND ("people"."id" != $5)  ORDER BY "people"."position" ASC)
' ""
sql_after = "" '
UPDATE "people" SET "primary_emailer" = false WHERE "people"."id" IN (SELECT "people"."id" FROM "people" WHERE "people"."site_id" = $1 AND "people"."family_id" = $2 AND "people"."deleted" = $3 AND "people"."email" = $4 AND ("people"."id" != $5)   LIMIT 1)
' ""
mysql_query1 = "UPDATE `people` SET `people`.`primary_emailer` = 0 WHERE `people`.`site_id` = 1 AND `people`.`family_id` = $2 AND `people`.`deleted` = 0 AND `people`.`email` = $4 AND (`people`.`id` != $5) ORDER BY `people`.`position` ASC"
mysql_query2 = "UPDATE `people` SET `people`.`primary_emailer` = 0 WHERE `people`.`site_id` = 1 AND `people`.`family_id` = $2 AND `people`.`deleted` = 0 AND `people`.`email` = $4 AND (`people`.`id` != $5) ORDER BY `people`.`position` ASC LIMIT 1"
# family_id, email, id needs to be generated
# ["site_id", 1], ["family_id", 1], ["deleted", "f"], ["email", "sdf"], ["id", 2]
family_ids = get_all_table_fields(conn, "families", "id")
people_emails = get_all_table_fields(conn, "people", "email")
people_ids = get_all_table_fields(conn, "people", "id")
index_range_hash = {}
index_range_hash[1] = family_ids
index_range_hash[3] = people_emails
index_range_hash[4] = people_ids
sqls = [sql_before, sql_after, 4, "add limit 1"]
params = [1, 1, false, "", 2]
params_arr = generate_params(n, params, index_range_hash)
n = 1000
# benchmark_queries(n, conn, sqls, params, index_range_hash)
mysql_sqls = [mysql_query1, mysql_query2, 4, "add limit 1"]
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
params_arr = generate_params(n, params, index_range_hash)
#benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

# add limit 1 second #10
sql_before = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = $1 AND "people"."family_id" = $2 AND "people"."deleted" = $3 AND "people"."email" = $4 AND ("people"."id" != $5)  ORDER BY "people"."position" ASC
' ""
sql_after = "" '
SELECT "people".* FROM "people" WHERE "people"."site_id" = $1 AND "people"."family_id" = $2 AND "people"."deleted" = $3 AND "people"."email" = $4 AND ("people"."id" != $5)  LIMIT 1
' ""
mysql_query1 = "
SELECT `people`.* FROM `people` WHERE `people`.`site_id` = 1 AND `people`.`family_id` = $2 AND `people`.`deleted` = 0 AND `people`.`email` = $4 AND (`people`.`id` != $5)  ORDER BY `people`.`position` ASC
"
mysql_query2 = "
SELECT  `people`.* FROM `people` WHERE `people`.`site_id` = 1 AND `people`.`family_id` = $2 AND `people`.`deleted` = 0 AND `people`.`email` = $4 AND (`people`.`id` != $5)  LIMIT 1
"
# family_id, email, id needs to be generated
# ["site_id", 1], ["family_id", 1], ["deleted", "f"], ["email", "sdf"], ["id", 2]
sqls = [sql_before, sql_after, 10, "add limit 1"]
params = [1, 1, false, "", 2]
n = 1000
# benchmark_queries(n, conn, sqls, params, index_range_hash)
mysql_sqls = [mysql_query1, mysql_query2, 10, "add limit 1"]
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
params_arr = generate_params(n, params, index_range_hash)
# benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

# remove predicate is null #8
sql_before = "" '
SELECT "people"."id" AS t0_r0, "people"."legacy_id" AS t0_r1, "people"."family_id" AS t0_r2, "people"."position" AS t0_r3, "people"."gender" AS t0_r4, "people"."first_name" AS t0_r5, "people"."last_name" AS t0_r6, "people"."suffix" AS t0_r7, "people"."mobile_phone" AS t0_r8, "people"."work_phone" AS t0_r9, "people"."fax" AS t0_r10, "people"."birthday" AS t0_r11, "people"."email" AS t0_r12, "people"."email_changed" AS t0_r13, "people"."website" AS t0_r14, "people"."classes" AS t0_r15, "people"."shepherd" AS t0_r16, "people"."mail_group" AS t0_r17, "people"."encrypted_password" AS t0_r18, "people"."business_name" AS t0_r19, "people"."business_description" AS t0_r20, "people"."business_phone" AS t0_r21, "people"."business_email" AS t0_r22, "people"."business_website" AS t0_r23, "people"."about" AS t0_r24, "people"."testimony" AS t0_r25, "people"."share_mobile_phone" AS t0_r26, "people"."share_work_phone" AS t0_r27, "people"."share_fax" AS t0_r28, "people"."share_email" AS t0_r29, "people"."share_birthday" AS t0_r30, "people"."anniversary" AS t0_r31, "people"."updated_at" AS t0_r32, "people"."alternate_email" AS t0_r33, "people"."email_bounces" AS t0_r34, "people"."business_category" AS t0_r35, "people"."account_frozen" AS t0_r36, "people"."messages_enabled" AS t0_r37, "people"."business_address" AS t0_r38, "people"."flags" AS t0_r39, "people"."visible" AS t0_r40, "people"."parental_consent" AS t0_r41, "people"."admin_id" AS t0_r42, "people"."friends_enabled" AS t0_r43, "people"."member" AS t0_r44, "people"."staff" AS t0_r45, "people"."elder" AS t0_r46, "people"."deacon" AS t0_r47, "people"."legacy_family_id" AS t0_r48, "people"."feed_code" AS t0_r49, "people"."share_activity" AS t0_r50, "people"."site_id" AS t0_r51, "people"."twitter_account" AS t0_r52, "people"."api_key" AS t0_r53, "people"."salt" AS t0_r54, "people"."deleted" AS t0_r55, "people"."child" AS t0_r56, "people"."custom_type" AS t0_r57, "people"."custom_fields" AS t0_r58, "people"."can_pick_up" AS t0_r59, "people"."cannot_pick_up" AS t0_r60, "people"."medical_notes" AS t0_r61, "people"."relationships_hash" AS t0_r62, "people"."photo_file_name" AS t0_r63, "people"."photo_content_type" AS t0_r64, "people"."photo_fingerprint" AS t0_r65, "people"."photo_file_size" AS t0_r66, "people"."photo_updated_at" AS t0_r67, "people"."description" AS t0_r68, "people"."share_anniversary" AS t0_r69, "people"."share_address" AS t0_r70, "people"."share_home_phone" AS t0_r71, "people"."password_hash" AS t0_r72, "people"."password_salt" AS t0_r73, "people"."created_at" AS t0_r74, "people"."facebook_url" AS t0_r75, "people"."twitter" AS t0_r76, "people"."incomplete_tasks_count" AS t0_r77, "people"."primary_emailer" AS t0_r78, "people"."last_seen_stream_item_id" AS t0_r79, "people"."last_seen_group_id" AS t0_r80, "people"."provider" AS t0_r81, "people"."uid" AS t0_r82, "people"."status" AS t0_r83, "people"."alias" AS t0_r84, "people"."last_seen_at" AS t0_r85, "families"."id" AS t1_r0, "families"."legacy_id" AS t1_r1, "families"."name" AS t1_r2, "families"."last_name" AS t1_r3, "families"."address1" AS t1_r4, "families"."address2" AS t1_r5, "families"."city" AS t1_r6, "families"."state" AS t1_r7, "families"."zip" AS t1_r8, "families"."home_phone" AS t1_r9, "families"."email" AS t1_r10, "families"."latitude" AS t1_r11, "families"."longitude" AS t1_r12, "families"."updated_at" AS t1_r13, "families"."visible" AS t1_r14, "families"."site_id" AS t1_r15, "families"."deleted" AS t1_r16, "families"."barcode_id" AS t1_r17, "families"."barcode_assigned_at" AS t1_r18, "families"."barcode_id_changed" AS t1_r19, "families"."alternate_barcode_id" AS t1_r20, "families"."photo_file_name" AS t1_r21, "families"."photo_content_type" AS t1_r22, "families"."photo_fingerprint" AS t1_r23, "families"."photo_file_size" AS t1_r24, "families"."photo_updated_at" AS t1_r25, "families"."country" AS t1_r26, "groups"."id" AS t2_r0, "groups"."name" AS t2_r1, "groups"."description" AS t2_r2, "groups"."meets" AS t2_r3, "groups"."location" AS t2_r4, "groups"."directions" AS t2_r5, "groups"."other_notes" AS t2_r6, "groups"."category" AS t2_r7, "groups"."creator_id" AS t2_r8, "groups"."private" AS t2_r9, "groups"."address" AS t2_r10, "groups"."members_send" AS t2_r11, "groups"."updated_at" AS t2_r12, "groups"."hidden" AS t2_r13, "groups"."approved" AS t2_r14, "groups"."link_code" AS t2_r15, "groups"."parents_of" AS t2_r16, "groups"."site_id" AS t2_r17, "groups"."blog" AS t2_r18, "groups"."email" AS t2_r19, "groups"."prayer" AS t2_r20, "groups"."attendance" AS t2_r21, "groups"."legacy_id" AS t2_r22, "groups"."gcal_private_link" AS t2_r23, "groups"."approval_required_to_join" AS t2_r24, "groups"."pictures" AS t2_r25, "groups"."cm_api_list_id" AS t2_r26, "groups"."photo_file_name" AS t2_r27, "groups"."photo_content_type" AS t2_r28, "groups"."photo_fingerprint" AS t2_r29, "groups"."photo_file_size" AS t2_r30, "groups"."photo_updated_at" AS t2_r31, "groups"."created_at" AS t2_r32, "groups"."latitude" AS t2_r33, "groups"."longitude" AS t2_r34, "groups"."membership_mode" AS t2_r35, "groups"."has_tasks" AS t2_r36, "groups"."share_token" AS t2_r37 FROM "people" LEFT OUTER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = $1 LEFT OUTER JOIN "memberships" ON "memberships"."person_id" = "people"."id" AND "memberships"."site_id" = $2 LEFT OUTER JOIN "groups" ON "groups"."id" = "memberships"."group_id" AND "groups"."site_id" = $3 WHERE "people"."site_id" = $4 AND (groups.category != $5 OR groups.category IS NULL)
' ""
sql_after = "" '
 SELECT "people"."id" AS t0_r0, "people"."legacy_id" AS t0_r1, "people"."family_id" AS t0_r2, "people"."position" AS t0_r3, "people"."gender" AS t0_r4, "people"."first_name" AS t0_r5, "people"."last_name" AS t0_r6, "people"."suffix" AS t0_r7, "people"."mobile_phone" AS t0_r8, "people"."work_phone" AS t0_r9, "people"."fax" AS t0_r10, "people"."birthday" AS t0_r11, "people"."email" AS t0_r12, "people"."email_changed" AS t0_r13, "people"."website" AS t0_r14, "people"."classes" AS t0_r15, "people"."shepherd" AS t0_r16, "people"."mail_group" AS t0_r17, "people"."encrypted_password" AS t0_r18, "people"."business_name" AS t0_r19, "people"."business_description" AS t0_r20, "people"."business_phone" AS t0_r21, "people"."business_email" AS t0_r22, "people"."business_website" AS t0_r23, "people"."about" AS t0_r24, "people"."testimony" AS t0_r25, "people"."share_mobile_phone" AS t0_r26, "people"."share_work_phone" AS t0_r27, "people"."share_fax" AS t0_r28, "people"."share_email" AS t0_r29, "people"."share_birthday" AS t0_r30, "people"."anniversary" AS t0_r31, "people"."updated_at" AS t0_r32, "people"."alternate_email" AS t0_r33, "people"."email_bounces" AS t0_r34, "people"."business_category" AS t0_r35, "people"."account_frozen" AS t0_r36, "people"."messages_enabled" AS t0_r37, "people"."business_address" AS t0_r38, "people"."flags" AS t0_r39, "people"."visible" AS t0_r40, "people"."parental_consent" AS t0_r41, "people"."admin_id" AS t0_r42, "people"."friends_enabled" AS t0_r43, "people"."member" AS t0_r44, "people"."staff" AS t0_r45, "people"."elder" AS t0_r46, "people"."deacon" AS t0_r47, "people"."legacy_family_id" AS t0_r48, "people"."feed_code" AS t0_r49, "people"."share_activity" AS t0_r50, "people"."site_id" AS t0_r51, "people"."twitter_account" AS t0_r52, "people"."api_key" AS t0_r53, "people"."salt" AS t0_r54, "people"."deleted" AS t0_r55, "people"."child" AS t0_r56, "people"."custom_type" AS t0_r57, "people"."custom_fields" AS t0_r58, "people"."can_pick_up" AS t0_r59, "people"."cannot_pick_up" AS t0_r60, "people"."medical_notes" AS t0_r61, "people"."relationships_hash" AS t0_r62, "people"."photo_file_name" AS t0_r63, "people"."photo_content_type" AS t0_r64, "people"."photo_fingerprint" AS t0_r65, "people"."photo_file_size" AS t0_r66, "people"."photo_updated_at" AS t0_r67, "people"."description" AS t0_r68, "people"."share_anniversary" AS t0_r69, "people"."share_address" AS t0_r70, "people"."share_home_phone" AS t0_r71, "people"."password_hash" AS t0_r72, "people"."password_salt" AS t0_r73, "people"."created_at" AS t0_r74, "people"."facebook_url" AS t0_r75, "people"."twitter" AS t0_r76, "people"."incomplete_tasks_count" AS t0_r77, "people"."primary_emailer" AS t0_r78, "people"."last_seen_stream_item_id" AS t0_r79, "people"."last_seen_group_id" AS t0_r80, "people"."provider" AS t0_r81, "people"."uid" AS t0_r82, "people"."status" AS t0_r83, "people"."alias" AS t0_r84, "people"."last_seen_at" AS t0_r85, "families"."id" AS t1_r0, "families"."legacy_id" AS t1_r1, "families"."name" AS t1_r2, "families"."last_name" AS t1_r3, "families"."address1" AS t1_r4, "families"."address2" AS t1_r5, "families"."city" AS t1_r6, "families"."state" AS t1_r7, "families"."zip" AS t1_r8, "families"."home_phone" AS t1_r9, "families"."email" AS t1_r10, "families"."latitude" AS t1_r11, "families"."longitude" AS t1_r12, "families"."updated_at" AS t1_r13, "families"."visible" AS t1_r14, "families"."site_id" AS t1_r15, "families"."deleted" AS t1_r16, "families"."barcode_id" AS t1_r17, "families"."barcode_assigned_at" AS t1_r18, "families"."barcode_id_changed" AS t1_r19, "families"."alternate_barcode_id" AS t1_r20, "families"."photo_file_name" AS t1_r21, "families"."photo_content_type" AS t1_r22, "families"."photo_fingerprint" AS t1_r23, "families"."photo_file_size" AS t1_r24, "families"."photo_updated_at" AS t1_r25, "families"."country" AS t1_r26, "groups"."id" AS t2_r0, "groups"."name" AS t2_r1, "groups"."description" AS t2_r2, "groups"."meets" AS t2_r3, "groups"."location" AS t2_r4, "groups"."directions" AS t2_r5, "groups"."other_notes" AS t2_r6, "groups"."category" AS t2_r7, "groups"."creator_id" AS t2_r8, "groups"."private" AS t2_r9, "groups"."address" AS t2_r10, "groups"."members_send" AS t2_r11, "groups"."updated_at" AS t2_r12, "groups"."hidden" AS t2_r13, "groups"."approved" AS t2_r14, "groups"."link_code" AS t2_r15, "groups"."parents_of" AS t2_r16, "groups"."site_id" AS t2_r17, "groups"."blog" AS t2_r18, "groups"."email" AS t2_r19, "groups"."prayer" AS t2_r20, "groups"."attendance" AS t2_r21, "groups"."legacy_id" AS t2_r22, "groups"."gcal_private_link" AS t2_r23, "groups"."approval_required_to_join" AS t2_r24, "groups"."pictures" AS t2_r25, "groups"."cm_api_list_id" AS t2_r26, "groups"."photo_file_name" AS t2_r27, "groups"."photo_content_type" AS t2_r28, "groups"."photo_fingerprint" AS t2_r29, "groups"."photo_file_size" AS t2_r30, "groups"."photo_updated_at" AS t2_r31, "groups"."created_at" AS t2_r32, "groups"."latitude" AS t2_r33, "groups"."longitude" AS t2_r34, "groups"."membership_mode" AS t2_r35, "groups"."has_tasks" AS t2_r36, "groups"."share_token" AS t2_r37 FROM "people" LEFT OUTER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = $1 LEFT OUTER JOIN "memberships" ON "memberships"."person_id" = "people"."id" AND "memberships"."site_id" = $2 LEFT OUTER JOIN "groups" ON "groups"."id" = "memberships"."group_id" AND "groups"."site_id" = $3 WHERE "people"."site_id" = $4 AND (groups.category != $5) 
' ""
mysql_query1 = "
SELECT `people`.`id` AS t0_r0, `people`.`legacy_id` AS t0_r1, `people`.`family_id` AS t0_r2, `people`.`position` AS t0_r3, `people`.`gender` AS t0_r4, `people`.`first_name` AS t0_r5, `people`.`last_name` AS t0_r6, `people`.`suffix` AS t0_r7, `people`.`mobile_phone` AS t0_r8, `people`.`work_phone` AS t0_r9, `people`.`fax` AS t0_r10, `people`.`birthday` AS t0_r11, `people`.`email` AS t0_r12, `people`.`email_changed` AS t0_r13, `people`.`website` AS t0_r14, `people`.`classes` AS t0_r15, `people`.`shepherd` AS t0_r16, `people`.`mail_group` AS t0_r17, `people`.`encrypted_password` AS t0_r18, `people`.`business_name` AS t0_r19, `people`.`business_description` AS t0_r20, `people`.`business_phone` AS t0_r21, `people`.`business_email` AS t0_r22, `people`.`business_website` AS t0_r23, `people`.`about` AS t0_r24, `people`.`testimony` AS t0_r25, `people`.`share_mobile_phone` AS t0_r26, `people`.`share_work_phone` AS t0_r27, `people`.`share_fax` AS t0_r28, `people`.`share_email` AS t0_r29, `people`.`share_birthday` AS t0_r30, `people`.`anniversary` AS t0_r31, `people`.`updated_at` AS t0_r32, `people`.`alternate_email` AS t0_r33, `people`.`email_bounces` AS t0_r34, `people`.`business_category` AS t0_r35, `people`.`account_frozen` AS t0_r36, `people`.`messages_enabled` AS t0_r37, `people`.`business_address` AS t0_r38, `people`.`flags` AS t0_r39, `people`.`visible` AS t0_r40, `people`.`parental_consent` AS t0_r41, `people`.`admin_id` AS t0_r42, `people`.`friends_enabled` AS t0_r43, `people`.`member` AS t0_r44, `people`.`staff` AS t0_r45, `people`.`elder` AS t0_r46, `people`.`deacon` AS t0_r47, `people`.`legacy_family_id` AS t0_r48, `people`.`feed_code` AS t0_r49, `people`.`share_activity` AS t0_r50, `people`.`site_id` AS t0_r51, `people`.`twitter_account` AS t0_r52, `people`.`api_key` AS t0_r53, `people`.`salt` AS t0_r54, `people`.`deleted` AS t0_r55, `people`.`child` AS t0_r56, `people`.`custom_type` AS t0_r57, `people`.`custom_fields` AS t0_r58, `people`.`can_pick_up` AS t0_r59, `people`.`cannot_pick_up` AS t0_r60, `people`.`medical_notes` AS t0_r61, `people`.`relationships_hash` AS t0_r62, `people`.`photo_file_name` AS t0_r63, `people`.`photo_content_type` AS t0_r64, `people`.`photo_fingerprint` AS t0_r65, `people`.`photo_file_size` AS t0_r66, `people`.`photo_updated_at` AS t0_r67, `people`.`description` AS t0_r68, `people`.`share_anniversary` AS t0_r69, `people`.`share_address` AS t0_r70, `people`.`share_home_phone` AS t0_r71, `people`.`password_hash` AS t0_r72, `people`.`password_salt` AS t0_r73, `people`.`created_at` AS t0_r74, `people`.`facebook_url` AS t0_r75, `people`.`twitter` AS t0_r76, `people`.`incomplete_tasks_count` AS t0_r77, `people`.`primary_emailer` AS t0_r78, `people`.`last_seen_stream_item_id` AS t0_r79, `people`.`last_seen_group_id` AS t0_r80, `people`.`provider` AS t0_r81, `people`.`uid` AS t0_r82, `people`.`status` AS t0_r83, `people`.`alias` AS t0_r84, `people`.`last_seen_at` AS t0_r85, `families`.`id` AS t1_r0, `families`.`legacy_id` AS t1_r1, `families`.`name` AS t1_r2, `families`.`last_name` AS t1_r3, `families`.`suffix` AS t1_r4, `families`.`address1` AS t1_r5, `families`.`address2` AS t1_r6, `families`.`city` AS t1_r7, `families`.`state` AS t1_r8, `families`.`zip` AS t1_r9, `families`.`home_phone` AS t1_r10, `families`.`email` AS t1_r11, `families`.`latitude` AS t1_r12, `families`.`longitude` AS t1_r13, `families`.`updated_at` AS t1_r14, `families`.`visible` AS t1_r15, `families`.`site_id` AS t1_r16, `families`.`deleted` AS t1_r17, `families`.`barcode_id` AS t1_r18, `families`.`barcode_assigned_at` AS t1_r19, `families`.`barcode_id_changed` AS t1_r20, `families`.`alternate_barcode_id` AS t1_r21, `families`.`photo_file_name` AS t1_r22, `families`.`photo_content_type` AS t1_r23, `families`.`photo_fingerprint` AS t1_r24, `families`.`photo_file_size` AS t1_r25, `families`.`photo_updated_at` AS t1_r26, `families`.`country` AS t1_r27, `groups`.`id` AS t2_r0, `groups`.`name` AS t2_r1, `groups`.`description` AS t2_r2, `groups`.`meets` AS t2_r3, `groups`.`location` AS t2_r4, `groups`.`directions` AS t2_r5, `groups`.`other_notes` AS t2_r6, `groups`.`category` AS t2_r7, `groups`.`creator_id` AS t2_r8, `groups`.`private` AS t2_r9, `groups`.`address` AS t2_r10, `groups`.`members_send` AS t2_r11, `groups`.`updated_at` AS t2_r12, `groups`.`hidden` AS t2_r13, `groups`.`approved` AS t2_r14, `groups`.`link_code` AS t2_r15, `groups`.`parents_of` AS t2_r16, `groups`.`site_id` AS t2_r17, `groups`.`blog` AS t2_r18, `groups`.`email` AS t2_r19, `groups`.`prayer` AS t2_r20, `groups`.`attendance` AS t2_r21, `groups`.`legacy_id` AS t2_r22, `groups`.`gcal_private_link` AS t2_r23, `groups`.`approval_required_to_join` AS t2_r24, `groups`.`pictures` AS t2_r25, `groups`.`cm_api_list_id` AS t2_r26, `groups`.`photo_file_name` AS t2_r27, `groups`.`photo_content_type` AS t2_r28, `groups`.`photo_fingerprint` AS t2_r29, `groups`.`photo_file_size` AS t2_r30, `groups`.`photo_updated_at` AS t2_r31, `groups`.`created_at` AS t2_r32, `groups`.`latitude` AS t2_r33, `groups`.`longitude` AS t2_r34, `groups`.`membership_mode` AS t2_r35, `groups`.`has_tasks` AS t2_r36, `groups`.`share_token` AS t2_r37 FROM `people` LEFT OUTER JOIN `families` ON `families`.`id` = `people`.`family_id` AND `families`.`site_id` = 1 LEFT OUTER JOIN `memberships` ON `memberships`.`person_id` = `people`.`id` AND `memberships`.`site_id` = 1 LEFT OUTER JOIN `groups` ON `groups`.`id` = `memberships`.`group_id` AND `groups`.`site_id` = 1 WHERE `people`.`site_id` = 1 AND (groups.category != $5 OR groups.category IS NULL)
"
mysql_query2 = "
SELECT `people`.`id` AS t0_r0, `people`.`legacy_id` AS t0_r1, `people`.`family_id` AS t0_r2, `people`.`position` AS t0_r3, `people`.`gender` AS t0_r4, `people`.`first_name` AS t0_r5, `people`.`last_name` AS t0_r6, `people`.`suffix` AS t0_r7, `people`.`mobile_phone` AS t0_r8, `people`.`work_phone` AS t0_r9, `people`.`fax` AS t0_r10, `people`.`birthday` AS t0_r11, `people`.`email` AS t0_r12, `people`.`email_changed` AS t0_r13, `people`.`website` AS t0_r14, `people`.`classes` AS t0_r15, `people`.`shepherd` AS t0_r16, `people`.`mail_group` AS t0_r17, `people`.`encrypted_password` AS t0_r18, `people`.`business_name` AS t0_r19, `people`.`business_description` AS t0_r20, `people`.`business_phone` AS t0_r21, `people`.`business_email` AS t0_r22, `people`.`business_website` AS t0_r23, `people`.`about` AS t0_r24, `people`.`testimony` AS t0_r25, `people`.`share_mobile_phone` AS t0_r26, `people`.`share_work_phone` AS t0_r27, `people`.`share_fax` AS t0_r28, `people`.`share_email` AS t0_r29, `people`.`share_birthday` AS t0_r30, `people`.`anniversary` AS t0_r31, `people`.`updated_at` AS t0_r32, `people`.`alternate_email` AS t0_r33, `people`.`email_bounces` AS t0_r34, `people`.`business_category` AS t0_r35, `people`.`account_frozen` AS t0_r36, `people`.`messages_enabled` AS t0_r37, `people`.`business_address` AS t0_r38, `people`.`flags` AS t0_r39, `people`.`visible` AS t0_r40, `people`.`parental_consent` AS t0_r41, `people`.`admin_id` AS t0_r42, `people`.`friends_enabled` AS t0_r43, `people`.`member` AS t0_r44, `people`.`staff` AS t0_r45, `people`.`elder` AS t0_r46, `people`.`deacon` AS t0_r47, `people`.`legacy_family_id` AS t0_r48, `people`.`feed_code` AS t0_r49, `people`.`share_activity` AS t0_r50, `people`.`site_id` AS t0_r51, `people`.`twitter_account` AS t0_r52, `people`.`api_key` AS t0_r53, `people`.`salt` AS t0_r54, `people`.`deleted` AS t0_r55, `people`.`child` AS t0_r56, `people`.`custom_type` AS t0_r57, `people`.`custom_fields` AS t0_r58, `people`.`can_pick_up` AS t0_r59, `people`.`cannot_pick_up` AS t0_r60, `people`.`medical_notes` AS t0_r61, `people`.`relationships_hash` AS t0_r62, `people`.`photo_file_name` AS t0_r63, `people`.`photo_content_type` AS t0_r64, `people`.`photo_fingerprint` AS t0_r65, `people`.`photo_file_size` AS t0_r66, `people`.`photo_updated_at` AS t0_r67, `people`.`description` AS t0_r68, `people`.`share_anniversary` AS t0_r69, `people`.`share_address` AS t0_r70, `people`.`share_home_phone` AS t0_r71, `people`.`password_hash` AS t0_r72, `people`.`password_salt` AS t0_r73, `people`.`created_at` AS t0_r74, `people`.`facebook_url` AS t0_r75, `people`.`twitter` AS t0_r76, `people`.`incomplete_tasks_count` AS t0_r77, `people`.`primary_emailer` AS t0_r78, `people`.`last_seen_stream_item_id` AS t0_r79, `people`.`last_seen_group_id` AS t0_r80, `people`.`provider` AS t0_r81, `people`.`uid` AS t0_r82, `people`.`status` AS t0_r83, `people`.`alias` AS t0_r84, `people`.`last_seen_at` AS t0_r85, `families`.`id` AS t1_r0, `families`.`legacy_id` AS t1_r1, `families`.`name` AS t1_r2, `families`.`last_name` AS t1_r3, `families`.`suffix` AS t1_r4, `families`.`address1` AS t1_r5, `families`.`address2` AS t1_r6, `families`.`city` AS t1_r7, `families`.`state` AS t1_r8, `families`.`zip` AS t1_r9, `families`.`home_phone` AS t1_r10, `families`.`email` AS t1_r11, `families`.`latitude` AS t1_r12, `families`.`longitude` AS t1_r13, `families`.`updated_at` AS t1_r14, `families`.`visible` AS t1_r15, `families`.`site_id` AS t1_r16, `families`.`deleted` AS t1_r17, `families`.`barcode_id` AS t1_r18, `families`.`barcode_assigned_at` AS t1_r19, `families`.`barcode_id_changed` AS t1_r20, `families`.`alternate_barcode_id` AS t1_r21, `families`.`photo_file_name` AS t1_r22, `families`.`photo_content_type` AS t1_r23, `families`.`photo_fingerprint` AS t1_r24, `families`.`photo_file_size` AS t1_r25, `families`.`photo_updated_at` AS t1_r26, `families`.`country` AS t1_r27, `groups`.`id` AS t2_r0, `groups`.`name` AS t2_r1, `groups`.`description` AS t2_r2, `groups`.`meets` AS t2_r3, `groups`.`location` AS t2_r4, `groups`.`directions` AS t2_r5, `groups`.`other_notes` AS t2_r6, `groups`.`category` AS t2_r7, `groups`.`creator_id` AS t2_r8, `groups`.`private` AS t2_r9, `groups`.`address` AS t2_r10, `groups`.`members_send` AS t2_r11, `groups`.`updated_at` AS t2_r12, `groups`.`hidden` AS t2_r13, `groups`.`approved` AS t2_r14, `groups`.`link_code` AS t2_r15, `groups`.`parents_of` AS t2_r16, `groups`.`site_id` AS t2_r17, `groups`.`blog` AS t2_r18, `groups`.`email` AS t2_r19, `groups`.`prayer` AS t2_r20, `groups`.`attendance` AS t2_r21, `groups`.`legacy_id` AS t2_r22, `groups`.`gcal_private_link` AS t2_r23, `groups`.`approval_required_to_join` AS t2_r24, `groups`.`pictures` AS t2_r25, `groups`.`cm_api_list_id` AS t2_r26, `groups`.`photo_file_name` AS t2_r27, `groups`.`photo_content_type` AS t2_r28, `groups`.`photo_fingerprint` AS t2_r29, `groups`.`photo_file_size` AS t2_r30, `groups`.`photo_updated_at` AS t2_r31, `groups`.`created_at` AS t2_r32, `groups`.`latitude` AS t2_r33, `groups`.`longitude` AS t2_r34, `groups`.`membership_mode` AS t2_r35, `groups`.`has_tasks` AS t2_r36, `groups`.`share_token` AS t2_r37 FROM `people` LEFT OUTER JOIN `families` ON `families`.`id` = `people`.`family_id` AND `families`.`site_id` = 1 LEFT OUTER JOIN `memberships` ON `memberships`.`person_id` = `people`.`id` AND `memberships`.`site_id` = 1 LEFT OUTER JOIN `groups` ON `groups`.`id` = `memberships`.`group_id` AND `groups`.`site_id` = 1 WHERE `people`.`site_id` = 1 AND (groups.category != $5)
"
n = 2
sqls = [sql_before, sql_after, 8, "remove predicate is null"]
params = [1, 1, 1, 1, ""]
group_categores = get_all_table_fields(conn, "groups", "category")
index_range_hash = {}
index_range_hash[4] = group_categores
#benchmark_queries(n, conn, sqls, params, index_range_hash)
mysql_sqls = [mysql_query1, mysql_query2, 8, "remove predicate is null"]
params_arr = generate_params(n, params, index_range_hash)
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
#benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

# union or #3
# add index on barcode_id to try again tried no big improvement
n = 10 #00
sql_before = "" '
SELECT "families".* FROM "families" WHERE "families"."site_id" = 1 AND (barcode_id = $1 or alternate_barcode_id = $1)
' ""
sql_after = "" 'SELECT "families".* FROM "families" WHERE "families"."site_id" = 1 AND (barcode_id = $1) union all SELECT "families".* FROM "families" WHERE "families"."site_id" = 1 AND (alternate_barcode_id = $1)' ""
mysql_query1 = "
SELECT `families`.* FROM `families` WHERE `families`.`site_id` = 1 AND (barcode_id = $1 or alternate_barcode_id = $1)
"
mysql_query2 = "
SELECT `families`.* FROM `families` WHERE `families`.`site_id` = 1 AND barcode_id = $1
union
SELECT `families`.* FROM `families` WHERE `families`.`site_id` = 1 AND alternate_barcode_id = $1
"
params = [""]
sqls = [sql_before, sql_after, 3, "union all"]
familiy_barcode_ids = get_all_table_fields(conn, "families", "barcode_id") + get_all_table_fields(conn, "families", "alternate_barcode_id")
index_range_hash = {}
index_range_hash[0] = familiy_barcode_ids
#benchmark_queries(n, conn, sqls, params, index_range_hash)
mysql_sqls = [mysql_query1, mysql_query2, 3, "union all"]
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
params_arr = generate_params(n, params, index_range_hash)
benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

#union all #5
#n = 1000
sql_before = "" '
SELECT "people".* FROM "people" INNER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = 1 WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND ((families.barcode_id = $1 or families.alternate_barcode_id = $1)) 
' ""
sql_after = "" '
SELECT "people".* FROM "people" INNER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = 1 WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND ((families.barcode_id = $1))
union all
SELECT "people".* FROM "people" INNER JOIN "families" ON "families"."id" = "people"."family_id" AND "families"."site_id" = 1 WHERE "people"."site_id" = 1 AND "people"."deleted" = false AND ((families.alternate_barcode_id = $1))  
' ""
mysql_query1 = "
SELECT `people`.* FROM `people` INNER JOIN `families` ON `families`.`id` = `people`.`family_id` AND `families`.`site_id` = 1 WHERE `people`.`site_id` = 1 AND `people`.`deleted` = 0 AND ((families.barcode_id = $1 or families.alternate_barcode_id = $1))
"
mysql_query2 = "
SELECT `people`.* FROM `people` INNER JOIN `families` ON `families`.`id` = `people`.`family_id` AND `families`.`site_id` = 1 WHERE `people`.`site_id` = 1 AND `people`.`deleted` = 0 AND families.barcode_id = $1
union all
SELECT `people`.* FROM `people` INNER JOIN `families` ON `families`.`id` = `people`.`family_id` AND `families`.`site_id` = 1 WHERE `people`.`site_id` = 1 AND `people`.`deleted` = 0 AND families.alternate_barcode_id = $1
"
sqls = [sql_before, sql_after, 5, "union all"]
# benchmark_queries(n, conn, sqls, params, index_range_hash)
mysql_sqls = [mysql_query1, mysql_query2, 5, "union all"]
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
params_arr = generate_params(n, params, index_range_hash)
#benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

# remove predicate #9
n = 10
sql_before = "" "
select path, id from pages where path != $1 and site_id = 1  order by path
" ""
sql_after = "" "
select path, id from pages where site_id = 1  order by path
" ""
ruby_stm = "results.select{|r| r['path'] != $1}"
sqls = [sql_before, sql_after, 9, "remove predicate"]
params = [""]
page_paths = get_all_table_fields(conn, "pages", "path")
index_range_hash = {}
index_range_hash[0] = page_paths
#benchmark_queries(n, conn, sqls, params, index_range_hash, ruby_stm)
mysql_sqls = sqls.dup
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
params_arr = generate_params(n, params, index_range_hash)
# benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)

# add limit N #28 this is special since we need to add limit N in the end of the query
n = 1000
sql_before = "" '
SELECT "membership_requests".* FROM "membership_requests" WHERE "membership_requests"."site_id" = $1 AND "membership_requests"."group_id" = $2 AND "membership_requests"."person_id" IN $3
' ""
sql_after = "" '
SELECT "membership_requests".* FROM "membership_requests" WHERE "membership_requests"."site_id" = $1 AND "membership_requests"."group_id" = $2 AND "membership_requests"."person_id" IN $3
' ""
mysql_query1 = "
SELECT `membership_requests`.* FROM `membership_requests` WHERE `membership_requests`.`site_id` = 1 AND `membership_requests`.`group_id` = $2 AND `membership_requests`.`person_id` IN $3
"
params = [1, 2, [1]]
index_range_hash = {}
index_range_hash[1] = get_all_table_fields(conn, "groups", "id")
index_range_hash[2] = get_all_table_fields(conn, "people", "id")[0...10]
params_arr = generate_params(n, params, index_range_hash)
sqls = [sql_before, sql_before, "28", "limit N"]
mysql_sqls = [mysql_query1, mysql_query1, "28", "limit N"]
run_params << [n, conn, sqls.dup, mysql_sqls.dup, params.dup, index_range_hash.dup, nil]
# benchmark_unusual_mysql_queries(n, conn, sqls, params_arr)
# benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)



run_params.sort { |a, b| a[2][3] <=> b[2][3] }.each do |n, conn, sqls, mysql_sqls, params, index_range_hash, ruby_stm|
  #benchmark_queries(n, conn, sqls, params, index_range_hash, ruby_stm)
  params_arr = generate_params(n, params, index_range_hash)
  benchmark_unusual_mysql_queries(n, conn, sqls, params_arr)
  benchmark_unusual_mysql_queries(n, mysql_conn, mysql_sqls, params_arr)
end
