








CREATE VIEW [dbo].[V0080_EMP_MASTER_INCREMENT_GET_BackupDivyaraj07022024]
AS

SELECT          
Isnull(e.emp_code,0) as Emp_code ,
                Isnull(e.initial,'') As initial  ,
                Isnull(e.emp_first_name,'') As emp_first_name,
                Isnull(e.emp_second_name,'') As emp_second_name ,
                Isnull(e.emp_last_name,'') As emp_last_name ,
				Isnull(e.date_of_join,'') As date_of_join ,
                Isnull(e.ssn_no,0) As ssn_no,
                Isnull(e.sin_no,0) As sin_no,
                Isnull(e.dr_lic_no,0) As dr_lic_no,
                Isnull(e.pan_no,'') As pan_no,
                Isnull(e.date_of_birth,'') As date_of_birth,
                Isnull(e.marital_status,'') As marital_status,
                Isnull(e.gender,'') As gender,
                Isnull(e.dr_lic_ex_date,'') As dr_lic_ex_date,
                Isnull(e.nationality,'') As nationality,
                Isnull(e.loc_id,0)  As loc_id,
                Isnull(e.street_1,'') As street_1,
                Isnull(e.city,'') As city,
                Isnull(e.state,'') As state,
                Isnull(e.zip_code,'') As zip_code,
                Isnull(e.home_tel_no,'') As home_tel_no,
                Isnull(e.mobile_no,'') As mobile_no,
                Isnull(e.work_tel_no,'') As work_tel_no,
                Isnull(e.work_email,'') As work_email,
                Isnull(e.other_email,'') As other_email,
                Isnull(e.image_name,'') As image_name,
                Isnull(e.emp_full_name,'') As emp_full_name,
                Isnull(e.emp_left,'') As emp_left,
                Isnull(e.emp_left_date,'') As emp_left_date,
                Isnull(i.increment_id,0) As increment_id,
                Isnull(e.present_street,'') As  present_street,
                Isnull(e.present_city,'') As present_city,
                Isnull(e.present_state,'') As present_state,
                Isnull(e.present_post_box,'') As present_post_box,
                Isnull(r.emp_superior,0) As emp_superior,
                Isnull(e.enroll_no,0) As enroll_no,
                Isnull(e.blood_group,'') As blood_group,
                Isnull(e.tally_led_name,'') As tally_led_name,
                Isnull(e.religion,'') As religion,
                Isnull(e.height,0) As height,
                Isnull(e.emp_mark_of_identification,'') As emp_mark_of_identification,
                Isnull(e.despencery,'') As despencery,
                Isnull(e.doctor_name,'') As doctor_name,
                Isnull(e.despenceryaddress,'') As despenceryaddress,
                Isnull(e.insurance_no,'') As  insurance_no,
                Isnull(e.is_gr_app,'') As is_gr_app,
                Isnull(e.is_yearly_bonus,'') As is_yearly_bonus,
                Isnull(e.yearly_leave_days,0) As yearly_leave_days,
                Isnull(e.yearly_leave_amount,0) As yearly_leave_amount,
                Isnull(e.yearly_bonus_per,0) As yearly_bonus_per,
                Isnull(e.yearly_bonus_amount,0) As yearly_bonus_amount,
                Isnull(e.emp_confirm_date,'') As emp_confirm_date,
                Isnull(e.is_on_probation,'') As is_on_probation,
                Isnull(e.tally_led_id,0) As tally_led_id,
                Isnull(e.emp_id,0) As emp_id,
                Isnull(e.cmp_id,0) As cmp_id,
                Isnull(esd.shift_id,e.shift_id)AS shift_id,
                Isnull(i.branch_id,0) As branch_id,
                Isnull(i.cat_id,0) As cat_id,
                Isnull(i.grd_id,0) As grd_id,
                Isnull(i.dept_id,0) As dept_id,
                Isnull(i.desig_id,0) As desig_id,
                Isnull(i.type_id,0) As type_id,
                Isnull(i.bank_id,0) As bank_id,
                Isnull(i.curr_id,0) As curr_id,
                Isnull(i.wages_type,'') As wages_type,
                Isnull(i.salary_basis_on,'') As salary_basis_on,
                Isnull(i_q.basic_salary,0) As basic_salary,
                Isnull(i_q.gross_salary,0) As gross_salary,
                Isnull(i.increment_effective_date,'') As increment_effective_date,
                Isnull(i.payment_mode,'') As payment_mode,
                Isnull(i.inc_bank_ac_no,'') As inc_bank_ac_no, -- Changed By Sajid 04-02-2022 -- '' Instead of 0
                Isnull(i.emp_ot,0) As emp_ot,
                Isnull(i.emp_ot_min_limit,'') As emp_ot_min_limit,
                Isnull(i.emp_ot_max_limit,0) As emp_ot_max_limit,
                Isnull(i.emp_late_mark,0) As emp_late_mark,
                Isnull(i.emp_full_pf,0) As emp_full_pf,
                Isnull(i.emp_pt,0) As emp_pt,
                Isnull(i.emp_fix_salary,0) As emp_fix_salary,
                Isnull(i.emp_part_time,0) As emp_part_time,
                Isnull(i.late_dedu_type,'') As late_dedu_type,
                Isnull(i.emp_late_limit,'') As emp_late_limit,
                Isnull(i.emp_pt_amount,0) As emp_pt_amount,
                Isnull(i.emp_childran,0) As emp_childran,
                Isnull(i.is_master_rec,0) As is_master_rec,
                Isnull(e.is_emp_fnf,'') As is_emp_fnf,
                Isnull(e.probation,0) As probation,
                Isnull(i.is_deputation_reminder,0) As is_deputation_reminder,
                Isnull(LEFT(i.deputation_end_date, 12), '') AS deputation_end_date,
                Isnull(i.increment_type,'') As increment_type,
                Isnull(e.worker_adult_no,0) As worker_adult_no,
                Isnull(e.father_name,'') As father_name,
                Isnull(e.bank_bsr,0) As bank_bsr,
                Isnull(e.old_ref_no,0) As old_ref_no,
                Isnull(e.alpha_emp_code,0) As alpha_emp_code, (
                CASE
                                WHEN Isnull(e.alpha_code, '') = '' THEN NULL
                                ELSE e.alpha_code
                END) AS alpha_code,
                e.leave_in_probation,
                e.is_lwf,
                Isnull(i_q.ctc, 0)           AS ctc,
                Isnull(i.center_id, 0)       AS center_id,
                Isnull(e.dbrd_code, '')      AS dbrd_code,
                Isnull(e.dealer_code, '')    AS dealer_code,
                Isnull(e.ccenter_remark, '') AS ccenter_remark,
                Isnull(i.emp_early_mark,0) As emp_early_mark,
                Isnull(i.early_dedu_type,'') As early_dedu_type,
                Isnull(i.emp_early_limit,'') As emp_early_limit,
                Isnull(e.ifsc_code,0) As ifsc_code,
                --Isnull(i.center_id ,0) AS Center_ID,
                Isnull(i.emp_weekday_ot_rate,0) As emp_weekday_ot_rate,
                Isnull(i.emp_holiday_ot_rate,0) As emp_holiday_ot_rate,
                Isnull(e.emp_pf_opening,'') As emp_pf_opening,
                Isnull(e.emp_category,'') As emp_category,
                Isnull(e.emp_uidno,0) As emp_uidno,
                Isnull(e.emp_cast,'') As emp_cast,
                Isnull(e.emp_annivarsary_date,'') As emp_annivarsary_date,
                Isnull(e.login_id,0) As login_id,
                Isnull(e.extra_ab_deduction,0) As extra_ab_deduction,
                Isnull(e.compoff_min_hrs,0) As compoff_min_hrs,
                Isnull(e.mother_name,'') As mother_name,
                Isnull(i.is_metro_city,'') As is_metro_city,
                Isnull(i.is_physical, 0) AS is_physical,
                Isnull(i.is_physical  , 0) AS expr2,
                Isnull(e.emp_offer_date,'') As emp_offer_date,
                Isnull(esc.saldate_id,0) As saldate_id,
                Isnull(i.emp_auto_vpf,'') As emp_auto_vpf,
                Isnull(i.segment_id,0) As segment_id,
                Isnull(i.vertical_id,0) As vertical_id,
                Isnull(i.subvertical_id,0) As subvertical_id,
                Isnull(i.subbranch_id,0) As subbranch_id,
                Isnull(e.groupjoiningdate,0) As groupjoiningdate,
                Isnull(i.monthly_deficit_adjust_ot_hrs,0) As monthly_deficit_adjust_ot_hrs,
                Isnull(i.fix_ot_hour_rate_wd,0) As fix_ot_hour_rate_wd,
                Isnull(i.fix_ot_hour_rate_wo_ho,0) As fix_ot_hour_rate_wo_ho,
                Isnull(e.ifsc_code_two,0) As ifsc_code_two,
                Isnull(i.bank_id_two,0) As bank_id_two,
                Isnull(i.payment_mode_two ,0) As payment_mode_two,
                Isnull(i.inc_bank_ac_no_two,0) As inc_bank_ac_no_two,
                Isnull(i.bank_branch_name,'') As bank_branch_name,
                Isnull(i.bank_branch_name_two,'') As  bank_branch_name_two,
                Isnull(e.code_date,'') As code_date,
                Isnull(e.code_date_format,'') As code_date_format,
                Isnull(e.empname_alias_primarybank,'') As empname_alias_primarybank,
                Isnull(e.empname_alias_pf,'') As empname_alias_pf,
                Isnull(e.empname_alias_pt,'') As empname_alias_pt,
                Isnull(e.empname_alias_secondarybank,'') As empname_alias_secondarybank,
                Isnull(e.empname_alias_tax,'') As empname_alias_tax,
                Isnull(e.empname_alias_esic,'') As empname_alias_esic,
                Isnull(e.empname_alias_salary,'') As  empname_alias_salary,
                Isnull(e.emp_notice_period,0) As emp_notice_period, 
                Isnull(e.emp_shoe_size,0) As emp_shoe_size,
                Isnull(e.emp_pent_size,0) As emp_pent_size,
                Isnull(e.emp_shirt_size,0) As emp_shirt_size,
                Isnull(e.emp_dress_code,0) As emp_dress_code,
                Isnull(e.emp_canteen_code,0) As emp_canteen_code,
                Isnull(e.thana_id,0) As thana_id,
                Isnull(e.tehsil,'') As tehsil,
                Isnull(e.district,'') As district,
                Isnull(e.thana_id_wok,0) As thana_id_wok,
                Isnull(e.tehsil_wok,0) As tehsil_wok,
                Isnull(e.district_wok,0) As district_wok, 
                Isnull(e.skilltype_id,0) As skilltype_id,
                Isnull(e.about_me,'') As  about_me,
                Isnull(e.uan_no,0) As uan_no,
                Isnull(e.compoff_wo_app_days,'') As compoff_wo_app_days,
                Isnull(e.compoff_wo_avail_days,'') As compoff_wo_avail_days,
                Isnull(e.compoff_wd_app_days,'') As compoff_wd_app_days,
                Isnull(e.compoff_wd_avail_days,'') As compoff_wd_avail_days,
                Isnull(e.compoff_ho_app_days,'') As compoff_ho_app_days,
                Isnull(e.compoff_ho_avail_days,'') As compoff_ho_avail_days,
                Isnull(e.date_of_retirement,'') As  date_of_retirement,
                Isnull(e.salary_depends_on_production,'') As salary_depends_on_production,
                Isnull(e.ration_card_type,'') As ration_card_type, 
                Isnull(e.ration_card_no,0) As ration_card_no,
                Isnull(e.vehicle_no,0) As vehicle_no,
                Isnull(e.is_on_training,'') As is_on_training, 
                Isnull(e.training_month,0) As training_month, 
                Isnull(e.aadhar_card_no,'') As aadhar_card_no,
                Isnull(e.actual_date_of_birth,'') As actual_date_of_birth, 
                Isnull(e.is_pf_trust, 0)                                                                           AS is_pf_trust,
                Isnull(e.pf_trust_no, 0)                                                                         AS pf_trust_no,
                Replace(CONVERT(VARCHAR(20), e.system_date, 106), ' ', '-') + ' ' + dbo.F_get_ampm(e.system_date) AS system_date,
                Isnull(e.extension_no,0) As extension_no,
                Isnull(e.linkedin_id,0) As linkedin_id,
                Isnull(e.twitter_id ,0) As twitter_id,
                Isnull(i.customer_audit ,'') As customer_audit,
                Isnull(e.manager_probation ,'') As manager_probation,
                Isnull(e.pf_start_date,'') As pf_start_date, -- Jaina 22-08-2016 (Customer_Audit); Rohit 26082016 (Manager_Probation);Jaina 02-09-2016(PF_Start_Date)
                
                Isnull(dm.dept_name,'') As dept_name,
                Isnull(dg.desig_name,'') As desig_name,
                Isnull(bm.branch_name,'') As branch_name,
                Isnull(gm.grd_name,'') As grd_name, -- Jimit (Dept_Name & Desig_Name on 07112016) and ( Branch_Name & Grd_Name on 12112016 )
                
                Isnull(i.sales_code , '') AS sales_code, --Ramiz 07122016 (Sales_Code)
                
                Isnull(e.signature_image_name,'') As signature_image_name, --Added by Jaina 04-01-2017
                
                Isnull(e.leave_encash_working_days,'') As leave_encash_working_days, --Added By Jimit 03022018
                
                Isnull(i.physical_percent,0) As physical_percent, --added by Krushna 05-07-2018
                
                Isnull(e.is_probation_month_days,'')  As is_probation_month_days,
                Isnull(e.is_trainee_month_days ,'') As is_trainee_month_days, 
                Isnull(e.weekoffcompoffavail_after_days,0) As  weekoffcompoffavail_after_days,
                Isnull(e.holidaycompoffavail_after_days,0) As holidaycompoffavail_after_days, 
                Isnull(e.weekdaycompoffavail_after_days,0) As weekdaycompoffavail_after_days,
				Is_VBA,I.Is_Piece_Trans_Salary,i.Emp_WeekOff_OT_Rate,
				isnull(I.Band_id,0) as Band_id
				,isnull(I.Is_Pradhan_Mantri,0) as Is_Pradhan_Mantri
				,isnull(I.Is_1time_PF_Member,0) as Is_1time_PF_Member
				,isnull(e.Emp_Cast_Join,'') as Emp_Cast_Join

				------------------------Added by ronakk 31052022 ---------------------------------

				,isnull(e.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
				,isnull(e.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
				,isnull(e.Emp_Hobby_id,'') as Emp_Hobby_id
				,isnull(e.Emp_Hobby_Name,'') as Emp_Hobby_Name
				,isnull(e.Emp_Fav_Food,'') as Emp_Fav_Food
				,isnull(e.Emp_Fav_Restro,'') as Emp_Fav_Restro
				,isnull(e.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
				,isnull(e.Emp_Fav_Festival,'') as Emp_Fav_Festival
				,isnull(e.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
				,isnull(e.Emp_Fav_Singer,'') as Emp_Fav_Singer
				
				,case when i.increment_effective_date is not null and I.Increment_Type = 'Increment' then 'Last Increment Date : ' + format(i.increment_effective_date,'dd-MMM-yyyy')
				else ''
				end as IncDate --Added by ronakk 30072022

				-----------------------------End by ronakk 3105202 -------------------------------


FROM            dbo.t0080_emp_master AS e
INNER JOIN      t0095_increment i
ON              e.emp_id = i.emp_id
INNER JOIN
                (
                           SELECT     max(i2.increment_id) AS increment_id,
                                      i2.emp_id
                           FROM       t0095_increment i2
                           INNER JOIN
                                      (
                                                 SELECT     max(increment_effective_date) AS increment_effective_date,
                                                            i3.emp_id
                                                 FROM       t0095_increment i3
                                                 INNER JOIN t0080_emp_master em
                                                 ON         em.emp_id = i3.emp_id
                                                            --WHERE I3.Increment_Effective_Date <= GETDATE() --Comment by Nilesh patel on 19042017 For future date edit
                                                 WHERE      i3.increment_effective_date <= (
                                                            CASE
                                                                       WHEN em.date_of_join >= getdate() THEN em.date_of_join
                                                                       ELSE getdate()
                                                            END)
                                                 GROUP BY   i3.emp_id ) i3
                           ON         i2.increment_effective_date=i3.increment_effective_date
                           AND        i2.emp_id=i3.emp_id
                           GROUP BY   i2.emp_id ) i2
ON              i.emp_id=i2.emp_id
AND             i.increment_id=i2.increment_id
                -----for getting CTC,Basic,Gross without transfer and deputation added By Jimit 06032018
INNER JOIN      t0095_increment i_q
ON              e.emp_id = i_q.emp_id
INNER JOIN
                (
                           SELECT     max(i2.increment_id) AS increment_id,
                                      i2.emp_id
                           FROM       t0095_increment i2
                           INNER JOIN
                                      (
                                                 SELECT     max(increment_effective_date) AS increment_effective_date,
                                                            i3.emp_id
                                                 FROM       t0095_increment i3
                                                 INNER JOIN t0080_emp_master em
                                                 ON         em.emp_id = i3.emp_id
                                                 WHERE      i3.increment_effective_date <= (
                                                            CASE
                                                                       WHEN em.date_of_join >= getdate() THEN em.date_of_join
                                                                       ELSE getdate()
                                                            END)
                                                 AND        i3.increment_type NOT IN ('Transfer',
                                                                                      'Deputation')
                                                 GROUP BY   i3.emp_id ) i3
                           ON         i2.increment_effective_date=i3.increment_effective_date
                           AND        i2.emp_id=i3.emp_id
                           GROUP BY   i2.emp_id ) i2_q
ON              i_q.emp_id=i2_q.emp_id
AND             i_q.increment_id=i2_q.increment_id
                ---------Ended------------------
LEFT OUTER JOIN
                --dbo.T0095_INCREMENT AS i ON e.Increment_ID = i.Increment_ID LEFT OUTER JOIN   --Added By Jaina 31-08-2016
                (
                           SELECT     es.shift_id,
                                      es.emp_id
                           FROM       t0100_emp_shift_detail es
                           INNER JOIN
                                      (
                                               SELECT   max(es1.for_date) AS for_date,
                                                        es1.emp_id
                                               FROM     t0100_emp_shift_detail AS es1
                                               WHERE    es1.for_date < getdate()
                                               AND      es1.shift_type <> 1 --Temp Shift not dispaly
                                               GROUP BY es1.emp_id) es1
                           ON         es.emp_id=es1.emp_id
                           AND        es.for_date=es1.for_date ) AS esd
ON              esd.emp_id = e.emp_id
LEFT OUTER JOIN
                (
                           SELECT     saldate_id,
                                      esc.emp_id
                           FROM       t0095_emp_salary_cycle esc
                           INNER JOIN
                                      (
                                               SELECT   max(effective_date) AS effective_date,
                                                        emp_id
                                               FROM     t0095_emp_salary_cycle
                                               WHERE    effective_date < getdate()
                                               GROUP BY emp_id) esc1
                           ON         esc.emp_id=esc1.emp_id
                           AND        esc.effective_date=esc1.effective_date ) esc
ON              esc.emp_id=e.emp_id
LEFT OUTER JOIN t0040_department_master dm
ON              dm.dept_id = i.dept_id
LEFT OUTER JOIN t0040_designation_master dg
ON              dg.desig_id = i.desig_id
LEFT OUTER JOIN t0040_grade_master gm
ON              gm.grd_id = i.grd_id
LEFT OUTER JOIN t0030_branch_master bm
ON              bm.branch_id = i.branch_id
LEFT OUTER JOIN
                (
                           SELECT     r.emp_id,
                                      r.r_emp_id AS emp_superior
                           FROM       t0090_emp_reporting_detail r
                           INNER JOIN
                                      (
                                                 SELECT     max(r1.row_id) AS row_id,
                                                            r1.emp_id
                                                 FROM       t0090_emp_reporting_detail r1
                                                 INNER JOIN
                                                            (
                                                                     SELECT   max(r2.effect_date) AS effect_date,
                                                                              r2.emp_id
                                                                     FROM     t0090_emp_reporting_detail r2
                                                                     GROUP BY emp_id ) r2
                                                 ON         r1.emp_id=r2.emp_id
                                                 AND        r1.effect_date=r2.effect_date
                                                 GROUP BY   r1.emp_id) r1
                           ON         r.emp_id=r1.emp_id
                           AND        r.row_id=r1.row_id ) r
ON              e.emp_id=r.emp_id
