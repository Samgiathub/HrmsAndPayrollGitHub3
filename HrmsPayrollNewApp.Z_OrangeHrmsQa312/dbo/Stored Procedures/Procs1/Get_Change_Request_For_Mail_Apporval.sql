
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Change_Request_For_Mail_Apporval]
	  @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)
	 ,@Request_id numeric(18,0)	
	 ,@Request_Type numeric(18,0)	
	 ,@Curr_rpt_level  numeric(18,0)	
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if exists (SELECT Rpt_Level FROM T0115_Request_Level_Approval WITH (NOLOCK) WHERE Request_id = @Request_id )
		begin
			
			Select distinct 
			LLA.Request_id as Request_id, 
			LLA.Request_Apr_Date as Request_Date,
			LLA.Request_Type_id as Request_Type_id,
			LLA.Change_Reason as Change_Reason,
			LLA.Shift_From_Date As Shift_From_Date,
			LLA.Shift_To_Date as Shift_To_Date,
			LLA.Curr_Details as Curr_Details,
			LLA.New_Details as New_Details,
			
			LLA.Curr_Tehsil as Curr_Tehsil,
			LLA.Curr_District as Curr_District,
			LLA.Curr_Thana as Curr_Thana,
			LLA.Curr_City_Village as Curr_City_Village,
			LLA.Curr_State as Curr_State,
			isnull(LLA.Curr_Pincode,0) as Curr_Pincode,
			
			LLA.New_Tehsil as New_Tehsil,
			LLA.New_District as New_District,
			LLA.New_Thana as New_Thana,
			LLA.New_City_Village as New_City_Village,
			LLA.New_State as New_State,
			LLA.Effective_Date As Effective_Date,
			isnull(LLA.New_Pincode,0) as New_Pincode,
			tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval
			--, tbl1.App_Emp_ID  as s_emp_id_Scheme_current,
			,ISNULL((Case when isnull(tbl1.App_Emp_ID,0) =  0 then (case when isnull(tbl1.Is_RM,0) = 1  then VLA.Emp_ID  ELSE (CASE WHEN tbl1.Is_BM > 0 THEN 
			(
						SELECT Emp_id FROM T0095_MANAGERS WITH (NOLOCK)
						WHERE Effective_Date = (SELECT MAX(Effective_Date) FROM dbo.T0095_MANAGERS WITH (NOLOCK) WHERE branch_id = 
						(
							
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = LLA.Emp_ID
						
						) 
						AND Effective_Date <= LLA.Effective_Date) AND dbo.T0095_MANAGERS.branch_id = 
						(
						SELECT  inc.branch_id FROM dbo.T0080_EMP_MASTER EM WITH (NOLOCK) INNER JOIN 
							dbo.T0095_INCREMENT inc WITH (NOLOCK) ON inc.increment_id = em.Increment_ID 
							WHERE em.emp_id = lla.Emp_ID
						)

			)
			 else tbl1.App_Emp_ID END) END ) ELSE tbl1.App_Emp_ID  end ),0) as s_emp_id_Scheme_current,
			LM.Request_type as Request_type,
			LLA.Quaulification_ID,
			LLA.Specialization,
			LLA.Passing_Year,
			LLA.Score,
			LLA.Quaulification_Star_Date,
			LLA.Quaulification_End_Date,
			LLA.Dependant_Name,
			LLA.Dependant_Gender,
			LLA.Dependant_DOB,
			LLA.Dependant_Age,
			LLA.Dependant_Relationship,
			LLA.Dependant_Is_Resident,
			LLA.Dependant_Is_Dependant,
			LLA.Pass_Visa_Citizenship,
			LLA.Pass_Visa_No,
			LLA.Pass_Visa_Issue_Date,
			LLA.Pass_Visa_Exp_Date,
			LLA.Pass_Visa_Review_Date,
			LLA.Pass_Visa_Status,
			LLA.License_ID,
			LLA.License_Type,
			LLA.License_IssueDate,
			LLA.License_No,
			LLA.License_ExpDate,
			LLA.License_Is_Expired,
			LLA.Image_path,
			LLA.Curr_IFSC_Code,
			LLA.Curr_Account_No,
			LLA.Curr_Branch_Name,
			LLA.New_IFSC_Code,
			LLA.New_Account_No,
			LLA.New_Branch_Name,
			LLA.Nominess_Address,
			LLA.Nominess_Share,
			LLA.Nominess_For,
			LLA.Nominees_Row_ID,
			LLA.Hospital_Name,
			LLA.Hospital_Address,
			LLA.Admit_Date,
			LLA.MediCalim_Approval_Amount,
			LLA.Old_Pan_No,
			LLA.New_Pan_No,
			LLA.Old_Adhar_No,
			LLA.New_Adhar_No,
			LLA.Loan_Month,
			LLA.Loan_Year,
			LLA.Loan_Skip_Details
			,isnull(LLA.Child_Birth_Date,'01-01-1900') as Child_Birth_Date   --Added by Jaina 10-09-2018

             -----------------------------------------------Added by ronakk 01072022 -------------------------------------------------
					  ,isnull(LLA.Dep_OccupationID,0) as Dep_OccupationID
					  ,'' as Dep_Occupation_Name
					  ,isnull((Select isnull(Occupation_Name,'') from T0040_Occupation_Master where O_ID=LLA.Dep_OccupationID),'') as Dep_Occupation_Name
					  ,ISNULL(LLA.Dep_HobbyID,'') as Dep_HobbyID
					  ,ISNULL(LLA.Dep_HobbyName,'') as Dep_HobbyName
					  ,ISNULL(LLA.Dep_DepCompanyName,'') as Dep_DepCompanyName
					  ,ISNULL(LLA.Dep_CmpCity,'') as Dep_CmpCity
					  ,ISNULL(LLA.Dep_Standard_ID,0) as Dep_Standard_ID
					  ,isnull((Select isnull(StandardName,'') from T0040_Dep_Standard_Master where S_ID=LLA.Dep_Standard_ID ),'') as Dep_Standard_Name
					  ,ISNULL(LLA.Dep_Shcool_College,'') as Dep_Shcool_College
					  ,ISNULL(LLA.Dep_SchCity,'') as Dep_SchCity
					  ,ISNULL(LLA.Dep_ExtraActivity,'') as Dep_ExtraActivity

					  ,isnull(LLA.Emp_Fav_Sport_id,'') as Emp_Fav_Sport_id
					  ,isnull(LLA.Emp_Fav_Sport_Name,'') as Emp_Fav_Sport_Name
					  ,isnull(LLA.Emp_Hobby_id,'') as Emp_Hobby_id
					  ,isnull(LLA.Emp_Hobby_Name,'') as Emp_Hobby_Name
					  ,isnull(LLA.Emp_Fav_Food,'') as Emp_Fav_Food
					  ,isnull(LLA.Emp_Fav_Restro,'') as Emp_Fav_Restro
					  ,isnull(LLA.Emp_Fav_Trv_Destination,'') as Emp_Fav_Trv_Destination
					  ,isnull(LLA.Emp_Fav_Festival,'') as Emp_Fav_Festival
					  ,isnull(LLA.Emp_Fav_SportPerson,'') as Emp_Fav_SportPerson
					  ,isnull(LLA.Emp_Fav_Singer,'') as Emp_Fav_Singer

					 
					  ,isnull(LLA.Curr_Emp_Fav_Sport_id,'') as Curr_Emp_Fav_Sport_id
					  ,isnull(LLA.Curr_Emp_Fav_Sport_Name,'') as Curr_Emp_Fav_Sport_Name
					  ,isnull(LLA.Curr_Emp_Hobby_id,'') as Curr_Emp_Hobby_id
					  ,isnull(LLA.Curr_Emp_Hobby_Name,'') as Curr_Emp_Hobby_Name
					  ,isnull(LLA.Curr_Emp_Fav_Food,'') as Curr_Emp_Fav_Food
					  ,isnull(LLA.Curr_Emp_Fav_Restro,'') as Curr_Emp_Fav_Restro
					  ,isnull(LLA.Curr_Emp_Fav_Trv_Destination,'') as Curr_Emp_Fav_Trv_Destination
					  ,isnull(LLA.Curr_Emp_Fav_Festival,'') as Curr_Emp_Fav_Festival
					  ,isnull(LLA.Curr_Emp_Fav_SportPerson,'') as Curr_Emp_Fav_SportPerson
					  ,isnull(LLA.Curr_Emp_Fav_Singer,'') as Curr_Emp_Fav_Singer


					 ,isnull(LLA.OtherHobby,'') as OtherHobby
					 ,isnull(LLA.Dep_PancardNo,'') as Dep_PancardNo
					 ,isnull(LLA.Dep_AdharcardNo,'') as Dep_AdharcardNo
					 ,isnull(LLA.Dep_Height,'') as Dep_Height
					 ,isnull(LLA.Dep_Weight,'') as Dep_Weight

					 ,isnull(LLA.OtherSports,'') as OtherSports

				   ----------------------------------------------------End by ronakk 01072022 -----------------------------------------


			from 
			T0115_Request_Level_Approval LLA WITH (NOLOCK)
			inner join T0040_Change_Request_Master LM WITH (NOLOCK) on lm.Request_id= lla.Request_Type_id
			inner join 		V0090_Change_Request_Application VLA on VLA.Request_id = LLA.Request_id	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0115_Request_Level_Approval WITH (NOLOCK) where T0115_Request_Level_Approval.Request_id = @Request_id) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM	, Leave_Days		
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Change Request')
								And Type = 'Change Request'
							)
							AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Change Request')
					And Type = 'Change Request'
				)
				AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0115_Request_Level_Approval WITH (NOLOCK) where T0115_Request_Level_Approval.Request_id = @Request_id)
				
			) as tbl1
			where lla.Request_id = @Request_id 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0115_Request_Level_Approval WITH (NOLOCK) where Request_id = @Request_id)
			 and tbl1.Rpt_Level <= @Curr_rpt_level
			
			
		 
		end
	else
		begin
			
			SELECT 
			distinct LAD.* ,
			tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,'' As Effective_Date
			, tbl1.App_Emp_ID  as s_emp_id_Scheme_current

			 ,isnull((Select isnull(Occupation_Name,'') from T0040_Occupation_Master where O_ID=LAD.Dep_OccupationID),'') as Dep_Occupation_Name --Added by ronakk 01072022
			 ,isnull((Select isnull(StandardName,'') from T0040_Dep_Standard_Master where S_ID=LAD.Dep_Standard_ID ),'') as Dep_Standard_Name --Added by ronakk 01072022

			FROM V0090_Change_Request_Application LAD
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,(Case when SD.Is_RM = 1 THEN 
				(SELECT R_Emp_ID FROM    dbo.T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
									INNER JOIN (SELECT MAX(ROW_ID) AS ROW_ID, R2.Emp_ID
												FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
													INNER JOIN (SELECT MAX(R3.Effect_Date) AS Effect_Date, R3.Emp_ID 
													FROM T0090_EMP_REPORTING_DETAIL R3 WITH (NOLOCK) WHERE R3.Effect_Date < GETDATE()
													AND R3.Emp_ID = @Emp_id
													GROUP BY R3.Emp_ID) R3
													ON R2.Emp_ID=R3.Emp_ID AND R2.Effect_Date=R3.Effect_Date
												WHERE R2.Emp_ID = @Emp_id
												GROUP BY R2.Emp_ID
												) R2 ON R1.Row_ID=R2.ROW_ID AND R1.Emp_ID=R2.Emp_ID
												inner join t0080_emp_master Em WITH (NOLOCK) on R1.R_emp_id = Em.emp_id
												Where R1.Emp_ID = @Emp_id
				) ELSE SD.App_Emp_ID END) as App_Emp_ID, 
				(CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM , Leave_Days
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Change Request')
								And Type = 'Change Request'
							)
							AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Change Request')
					And Type = 'Change Request'
				)
				AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) and SD.Rpt_Level = 1
			) as tbl1
			
			WHERE LAD.Request_id = @Request_id
		end
	

END

