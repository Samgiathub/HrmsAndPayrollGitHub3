

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Get_Recruitment_Application_Records_Mail_Apporval 9,1358,1,1,1
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Recruitment_Application_Records_Mail_Apporval]
	  @Cmp_id numeric(18,0)
	 ,@Emp_id numeric(18,0)
	 ,@Request_id numeric(18,0)	
	 --,@Request_Type numeric(18,0)	
	 ,@Curr_rpt_level  numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @branch_id as int
		
	 --SELECT TOP 1 @branch_id=Branch_ID FROM T0095_INCREMENT
	 --WHERE EMP_ID= @Emp_id AND Increment_Effective_Date <= GETDATE()
	 --ORDER BY Increment_Effective_Date DESC, Increment_ID DESC
    
  --  print @branch_id
--    SELECT	hr1.Emp_ID,hr1.Branch_id_multi,hr1.Login_ID 
--FROM	T0011_LOGIN hr1 INNER JOIN dbo.fn_getEmpIncrement(119,13963,Getdate()) T 
--WHERE	is_hr=1 and  Cmp_ID=119 
--		AND (Exists(SELECT 1 FROM dbo.Split(hr1.Branch_id_multi,
--		Cast(T.Branch_ID As Varchar(10)), '#') T1 Where  T.Data <> '' AND CAST(T.Data INT)=T1.Branch_ID
--				OR
--				hr1.Branch_id_multi ='')
				
 --   SELECT hr1.Emp_ID,hr1.Branch_id_multi,hr1.Login_ID 
	--FROM T0011_LOGIN hr1
	--WHERE is_hr=1 and  Cmp_ID=119 
	--	AND (Exists(SELECT 1 FROM dbo.Split(hr1.Branch_id_multi, '#') T1 Where  T1.Data <> '' 
	--	AND @branch_id=T1.Branch_ID) OR hr1.Branch_id_multi ='')
	
	   CREATE TABLE #Scheme_Table
    (
		Emp_id		NUMERIC		DEFAULT 0,
		Rpt_Mgr_1	Varchar(500) DEFAULT NUll,
		Rpt_Mgr_2	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_3	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_4	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_5	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_6	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_7	Varchar(200) DEFAULT NUll,
		Rpt_Mgr_8	Varchar(200) DEFAULT NUll,
		Max_Level	int	
    )   
	
	DECLARE @Sup_Alpha_Emp_Code VARCHAR(50)
	DECLARE @Sup_Emp_ID INT
	DECLARE @today_date DATETIME
	SET @today_date=getdate()
		
		--EXEC SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@today_date,@To_Date=@today_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_Id,@Constraint=@Emp_Id,@Report_Type = 'Recruitment Request'

	INSERT INTO #Scheme_Table
	EXEC SP_RPT_SCHEME_DETAILS_ESS_GET @Cmp_ID=@Cmp_ID,@From_Date=@today_date,@To_Date=@today_date,@Branch_ID=0,@Cat_ID=0,@Grd_ID=0,@Type_ID=0,@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_Id,@Constraint=@Emp_Id,@Report_Type = 'Recruitment Request'
	
	IF ISNULL(@Curr_rpt_level,0)=1
	BEGIN
		SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_1,CHARINDEX('-',Rpt_Mgr_1)-1) FROM #Scheme_Table WHERE Rpt_Mgr_1 <>''
		SELECT @Sup_Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code											
	END	
	IF ISNULL(@Curr_rpt_level,0)=2
	BEGIN
		SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_2,CHARINDEX('-',Rpt_Mgr_2)-1) FROM #Scheme_Table WHERE Rpt_Mgr_2 <>''
		SELECT @Sup_Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code											
	END	
	IF ISNULL(@Curr_rpt_level,0)=3
	BEGIN
		SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_3,CHARINDEX('-',Rpt_Mgr_3)-1) FROM #Scheme_Table WHERE Rpt_Mgr_3 <>''
		SELECT @Sup_Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code											
	END	
	IF ISNULL(@Curr_rpt_level,0)=4
	BEGIN
		SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_4,CHARINDEX('-',Rpt_Mgr_4)-1) FROM #Scheme_Table WHERE Rpt_Mgr_4 <>''
		SELECT @Sup_Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code											
	END	
	IF ISNULL(@Curr_rpt_level,0)=5
	BEGIN
		SELECT @Sup_Alpha_Emp_Code=LEFT(Rpt_Mgr_5,CHARINDEX('-',Rpt_Mgr_5)-1) FROM #Scheme_Table WHERE Rpt_Mgr_5 <>''
		SELECT @Sup_Emp_ID=Emp_ID FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Alpha_Emp_Code=@Sup_Alpha_Emp_Code											
	END	
		
	--SELECT @Sup_Alpha_Emp_Code,	@Sup_Emp_ID		
--select * from #Scheme_Table								
		IF EXISTS (SELECT Rpt_Level FROM T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) WHERE Rec_Req_ID = @Request_id )
		BEGIN			
		--select 333
			SELECT DISTINCT 
			LLA.Rec_Req_ID as Rec_Req_ID, 
			tbl1.Rpt_Level,
			tbl1.Is_Fwd_Leave_Rej, 
			tbl1.is_final_approval AS is_final_approval,
			@Sup_Emp_ID AS s_emp_id_Scheme_current
			--tbl1.App_Emp_ID		as s_emp_id_Scheme_current	
			--CASE WHEN tbl1.Is_RM = 1 THEN tbl1.R_Emp_ID ELSE tbl1.App_Emp_ID END AS s_emp_id_Scheme_current   --Added by Jaina 02-12-2016
			FROM 
			T0052_Hrms_RecruitmentRequest_Approval LLA WITH (NOLOCK)
			inner join 		V0050_HRMS_Recruitment_Request VLA on VLA.Rec_Req_ID = LLA.Rec_Req_ID	
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID,(CASE WHEN isnull(tblFinal.Rpt_Level,1) > (select max(Rpt_Level) + 1 from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) where T0052_Hrms_RecruitmentRequest_Approval.Rec_Req_ID = @Request_id) THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , ISNULL(sd.Is_BM,0) AS is_BM, ISNULL(sd.Is_HOD,0) AS is_HOD, ISNULL(sd.Is_HR,0) AS is_HR,--added HR/Hod 29 Jan 2016 
				Leave_Days,RM.R_Emp_ID				
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)				
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail  WITH (NOLOCK)
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
								And Type = 'Recruitment Request'
							)
							--AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) 
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				INNER JOIN    --Added by Jaina 02-12-2016 Start
				(
					 select R.R_Emp_ID,ES.Emp_ID,ES.Scheme_ID from T0090_EMP_REPORTING_DETAIL  R WITH (NOLOCK)
							INNER JOIN
							(SELECT Scheme_ID,Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
								And Type = 'Recruitment Request'
							) AS ES ON ES.Emp_ID = R.Emp_ID
				) AS RM ON RM.Scheme_ID = SD.Scheme_Id  --Added by Jaina 02-12-2016 End
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
					And Type = 'Recruitment Request'
				)
				--AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) 
				and SD.Rpt_Level = (select max(Rpt_Level) + 1 from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) where T0052_Hrms_RecruitmentRequest_Approval.Rec_Req_ID = @Request_id)
				
			) as tbl1
			where lla.Rec_Req_ID = @Request_id 
			 and lla.Rpt_Level = (select max(Rpt_Level) from T0052_Hrms_RecruitmentRequest_Approval WITH (NOLOCK) where Rec_Req_ID = @Request_id)
			 and tbl1.Rpt_Level <= @Curr_rpt_level
		end
		else
			begin
			--select 444
			SELECT DISTINCT LAD.* , tbl1.Rpt_Level,tbl1.Is_Fwd_Leave_Rej, tbl1.is_final_approval AS is_final_approval,'' As Effective_Date
			,@Sup_Emp_ID AS s_emp_id_Scheme_current
			--, tbl1.App_Emp_ID  as s_emp_id_Scheme_current
			--,CASE WHEN tbl1.Is_RM = 1 THEN tbl1.R_Emp_ID ELSE tbl1.App_Emp_ID END AS s_emp_id_Scheme_current   --Added by Jaina 02-12-2016
			FROM V0050_HRMS_Recruitment_Request LAD
			CROSS JOIN
			(
				SELECT SD.Rpt_Level,SD.App_Emp_ID, (CASE WHEN isnull(tblFinal.Rpt_Level,1) > 1 THEN 0 ELSE 1 end) as is_final_approval
				,Is_Fwd_Leave_Rej, sd.Is_RM , sd.Is_BM ,  is_HOD, is_HR Leave_Days,RM.R_Emp_ID   --Added by Jaina 02-12-2016 R_Emp_Id
				FROM T0050_Scheme_Detail SD WITH (NOLOCK)
				INNER JOIN
					(
						SELECT max(Rpt_Level) as Rpt_Level,Scheme_Id from T0050_Scheme_Detail WITH (NOLOCK) 
							WHERE Scheme_Id in
							(
								SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
								And Type = 'Recruitment Request'
							)
							--AND @Request_Type IN (SELECT data FROM dbo.Split(leave,'#')) --and Rpt_Level = 1
						GROUP BY Scheme_Id
						
					) as tblFinal
				ON SD.Scheme_Id = tblFinal.Scheme_Id
				INNER JOIN    --Added by Jaina 02-12-2016 Start
				(
					 select R.R_Emp_ID,ES.Emp_ID,ES.Scheme_ID from T0090_EMP_REPORTING_DETAIL  R WITH (NOLOCK)
							INNER JOIN
							(SELECT Scheme_ID,Emp_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
								And Type = 'Recruitment Request'
							) AS ES ON ES.Emp_ID = R.Emp_ID
				) AS RM ON RM.Scheme_ID = SD.Scheme_Id  --Added by Jaina 02-12-2016 End
				WHERE SD.Scheme_Id in
				(
					SELECT Scheme_ID FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					and Effective_Date = (SELECT max(Effective_Date) FROM T0095_EMP_SCHEME WITH (NOLOCK) WHERE Emp_ID = @Emp_id AND effective_date <= getdate() And Type = 'Recruitment Request')
					And Type = 'Recruitment Request'
				)
				--AND @Request_Type IN (SELECT data FROM dbo.Split(SD.leave,'#')) 
				and SD.Rpt_Level = 1
			) as tbl1
			
			WHERE LAD.Rec_Req_ID = @Request_id
			
			
		End
END


