---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[RPT_EMP_LETTER_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@Letter		varchar(30)='Offer'
	,@PBranch_ID    varchar(MAX) = ''   --added jimit 26062015
	,@reportPath    varchar(max)= '..\Reports\' --bma dynamic signature/header/footer
	,@Req_Type		int = 0  --0 employee 1 candidate
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	If @PBranch_ID = '0'
		set @PBranch_ID = null
	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	
	
	create table #finaldata
	(
		 Cmp_Id				numeric(18,0)
		,Cmp_Name			varchar(100)
		,Cmp_Address		varchar(250)
		,Cmp_Logo			IMAGE
		,Emp_Id				NUMERIC(18,0)
		,Grd_Id				numeric(18,0)
		,Branch_Id			numeric(18,0)
		,Cat_Id				numeric(18,0)
		,Desig_Id			numeric(18,0)
		,Dept_Id			numeric(18,0)
		,[Type_id]			numeric(18,0)
		,Emp_Code			varchar(100)
		,Emp_Full_Name		varchar(100)
		,Resume_Code		varchar(100)
		,Resume_Id			numeric(18,0)
		,Rec_Post_Id		NUMERIC(18,0)
		,Rec_Post_Code		varchar(100)
		,Job_Title			Varchar(200)
		,Grd_Name			varchar(100)
		,Branch_Name		varchar(100)
		,Branch_Address		varchar(250)
		,Branch_City		varchar(150)
		,Cat_Name			varchar(100)
		,Desig_Name			varchar(100)
		,Dept_Name			varchar(100)
		,[Type_Name]		varchar(100)
		,Gender				varchar(6)
		,Basic_Salary		numeric(18,2)
		,Gross_Salary		NUMERIC(18,2)
		,Join_date			DATETIME
		,Vertical_Id		NUMERIC(18,0)
		,Vertical_Name		varchar(100)
		,SubVertical_Id		NUMERIC(18,0)
		,SubVertical_Name	varchar(100)
		,BusinessSegment_Id	NUMERIC(18,0)
		,Segment_Name		VARCHAR(100)
		,Shift_Id			NUMERIC(18,0)
		,Shift_name			varchar(100)
		,Approval_Date		DATETIME
		,Present_Street		varchar(200)
		,Present_City		varchar(100)
		,Present_State		VARCHAR(100)
		,Zip_Code			Varchar(50)
		,Business_Head		NUMERIC(18,0)
		,Level2_Approval	NUMERIC(18,0) 
		,SalaryCycle_Id		NUMERIC(18,0)
		,Reporting_ManagerId 	NUMERIC(18,0)
		,Reporting_ManagerName	Varchar(200)
		,Reporting_ManagerEmail	Varchar(100)
		,ShortFall_Days		NUMERIC(18,0)
		,cmp_hr_manager		Varchar(200)	
		,rp_header			Varchar(500)
		,rp_Footer			Varchar(500)
		,rp_Sign			Varchar(500)
		,Reference_No		Varchar(200)
		,Issue_Date			DATETIME
		,Tehsil				varchar(50)
		,District			varchar(50) --Added by Sumit on 06022017
		,CTC				numeric(18,2)--added by chetan 220817
		,CTC_AMount_Word	varchar(2000)--added by chetan 220817
		,Cmp_Email			varchar(500)--added by chetan 230817
		,DOB				DATETIME --added by sneha 23082017
		,Cmp_code		Varchar(100)	--added by Rudra 09092019
		,Dept_Code		Varchar(100)	--added by Rudra 09092019
		,Emp_fName		Varchar(100)	--added by Rudra 09092019
		,Var_Pay_Amt	numeric(18,2)--added by Deepali 08022023
		,Var_Pay_Amt_Word	varchar(2000)--added by  Deepali 08022023
	)
	
	--add by Krushna 04-01-2018
	Create TABLE #finaldata_1		
	(
		 Cmp_Id				NUMERIC(18,0)
		,Emp_Id				NUMERIC(18,0)
		,CTC				NUMERIC(18,2)
		,VPay_Amt			NUMERIC(18,2)--added by Deepali 08022023
	)
	--Old Code - Commented by Deepali -10022023
	--INSERT INTO #finaldata_1
	--SELECT I.Cmp_ID,EC.Emp_ID,(isnull(I.Basic_Salary,0) + isnull(SUM(EED.E_AD_AMOUNT),0)) * 12 , 
	--isnull(SUM(EED.E_AD_AMOUNT),0)
	--FROM @Emp_Cons AS EC 
	--	INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.Emp_ID = I.Emp_ID
	--	INNER JOIN T0100_EMP_EARN_DEDUCTION as EED WITH (NOLOCK) ON I.Increment_ID = EED.INCREMENT_ID
	--	INNER JOIN T0050_AD_MASTER as AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID
	--WHERE I.Increment_Type = 'Joining' AND EED.E_AD_FLAG <> 'D' AND AM.AD_PART_OF_CTC = 1
	--	AND I.Cmp_ID = @Cmp_ID and I.Emp_ID = EC.Emp_ID
	--GROUP BY I.Cmp_ID,EC.Emp_ID,I.Basic_Salary
	--Old code - Commented by deepali - 10022023


	--= Start new Code BY Deepali - 10022023 - Start - for Variable Pay 

	INSERT INTO #finaldata_1
	SELECT I.Cmp_ID,EC.Emp_ID,(isnull(I.Basic_Salary,0) + isnull(SUM(EED.E_AD_AMOUNT),0)) * 12 , 
	(select isnull(SUM(EED1.E_AD_AMOUNT),0) from  T0095_INCREMENT I1
		INNER JOIN T0100_EMP_EARN_DEDUCTION as EED1 WITH (NOLOCK) ON I1.Increment_ID = EED1.INCREMENT_ID
		INNER JOIN T0050_AD_MASTER as AM1 WITH (NOLOCK) on EED1.AD_ID = AM1.AD_ID
		where  I1.Emp_ID =EC.Emp_ID  and I.Cmp_ID=@Cmp_ID and   AM1.AD_DEF_ID =37	GROUP BY I1.Cmp_ID,I1.Emp_ID)
	FROM @Emp_Cons AS EC 
		INNER JOIN T0095_INCREMENT AS I WITH (NOLOCK) ON EC.Emp_ID = I.Emp_ID
		INNER JOIN T0100_EMP_EARN_DEDUCTION as EED WITH (NOLOCK) ON I.Increment_ID = EED.INCREMENT_ID
		INNER JOIN T0050_AD_MASTER as AM WITH (NOLOCK) on EED.AD_ID = AM.AD_ID
	WHERE I.Increment_Type = 'Joining' AND EED.E_AD_FLAG <> 'D' AND AM.AD_PART_OF_CTC = 1
		AND I.Cmp_ID = @Cmp_ID and I.Emp_ID = EC.Emp_ID
	GROUP BY I.Cmp_ID,EC.Emp_ID,I.Basic_Salary


	select * from   #finaldata_1
	--= End -new Code BY Deepali - 10022023 - Start - for Variable Pay 


	--End Krushna
	--if @Letter ='Offer' 
	--	begin
			if @Req_Type =0
				BEGIN
					insert into #finaldata
					Select cm.Cmp_Id,cm.Cmp_Name,cm.Cmp_Address,cm.cmp_logo
						   ,ec.Emp_ID,i.Grd_ID,i.Branch_ID,i.Cat_ID,i.Desig_Id,i.Dept_ID,i.Type_ID
						   ,e.Alpha_Emp_Code,e.Emp_Full_Name,null,null,null,null,null
						   ,G.Grd_Name,B.Branch_Name,B.Branch_Address,B.Branch_City,C.Cat_Name,DG.Desig_Name,D.Dept_Name,t.Type_Name
						   ,E.Gender,i.Basic_Salary,i.Gross_Salary,E.Date_Of_Join,i.Vertical_ID,'',i.SubVertical_ID,'',i.Segment_ID,''
						   ,e.Shift_ID,SM.Shift_Name,null,E.Present_Street,E.Present_City,E.Present_State,E.Present_Post_Box
						   ,null,null,null,MAIN.R_Emp_ID,(erm.Alpha_Emp_Code +' - '+ erm.Emp_Full_Name),erm.Work_Email,e.Emp_Notice_Period
						   ,cm.Cmp_HR_Manager,CAST(@reportPath as varchar(max)) + '\report_image\header_' + cast (e.cmp_id as varchar) + '.bmp' as rp_header
						  ,CAST(@reportPath as varchar(max)) + '\report_image\Footer_' + cast (e.cmp_id as varchar) + '.bmp' as rp_Footer
						  ,replace(CAST(@reportPath as varchar(max)),'\Reports\','') + '\App_File\Signature\' + cast (g.Signature as varchar(max)) as rp_Sign
						  ,ELR.Reference_No,ELR.Issue_Date
						  ,ISNULL(E.Tehsil,''),ISNULL(E.District,'')
							,ISNULL(F1.CTC,0)
						   ,LTRIM(dbo.F_Number_TO_Word(isnull(F1.CTC,0)))
						  	--,isnull(I.CTC,0)*12,LTRIM(dbo.F_Number_TO_Word(isnull(I.CTC,0)*12))
						  ,CM.Cmp_Email,E.Date_Of_Birth --added by chetan 220817
						  ,CM.Cmp_Code 			--added by Rudra 09092019	
						  ,D.Dept_Code			--added by Rudra 09092019
						  ,E.Emp_First_Name		--added by Rudra 09092019 
						  ,ISNULL(F1.VPay_Amt,0)     --added by  Deepali 08022023
						   ,LTRIM(dbo.F_Number_TO_Word(isnull(F1.VPay_Amt,0)))  --added by  Deepali 08022023
					from @Emp_Cons Ec INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) on Ec.Emp_ID = E.Emp_ID
					LEFT join T0095_INCREMENT I WITH (NOLOCK) on I.Emp_ID = e.Emp_ID 
					--update by chetan 230817
						  LEFT Join ( 
										SELECT	I1.EMP_ID, I1.INCREMENT_ID, I1.BRANCH_ID
										FROM	T0095_INCREMENT I1 WITH (NOLOCK) INNER JOIN @Emp_Cons E1 ON I1.Emp_ID=E1.EMP_ID
										INNER JOIN (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID
										FROM	T0095_INCREMENT I2 WITH (NOLOCK) INNER JOIN @Emp_Cons E2 ON I2.Emp_ID=E2.EMP_ID
										INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
										FROM	T0095_INCREMENT I3 WITH (NOLOCK) INNER JOIN @Emp_Cons E3 ON I3.Emp_ID=E3.EMP_ID
										WHERE	I3.Increment_Effective_Date <= @to_Date
										GROUP BY I3.Emp_ID
										) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
										WHERE	I2.Cmp_ID = @Cmp_Id 
										GROUP BY I2.Emp_ID
										) I2 ON I1.Emp_ID=I2.Emp_ID AND I1.Increment_ID=I2.INCREMENT_ID	
										WHERE	I1.Cmp_ID=@Cmp_Id											
									) Qry ON I.EMP_ID=Qry.Emp_ID AND I.Increment_ID = Qry.INCREMENT_ID
						  LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on cm.Cmp_Id = e.Cmp_ID
						  LEFT Join T0040_GRADE_MASTER G WITH (NOLOCK) on G.Grd_ID = i.Grd_ID
						  LEFT JOIN T0030_BRANCH_MASTER B WITH (NOLOCK) on b.Branch_ID = i.Branch_ID
						  LEFT JOIN T0030_CATEGORY_MASTER C WITH (NOLOCK) on c.Cat_ID = i.Cat_ID
						  LEFT JOIN T0040_DESIGNATION_MASTER DG WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id
						  LEFT JOIN T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on d.Dept_Id = i.Dept_ID
						  LEFT join T0040_TYPE_MASTER T WITH (NOLOCK) on t.Type_ID = i.Type_ID
						  left join T0040_Vertical_Segment V WITH (NOLOCK) on v.Vertical_ID = i.Vertical_ID
						  left join T0050_SubVertical SV WITH (NOLOCK) on SV.SubVertical_ID = i.SubVertical_ID
						  left join T0040_Business_Segment bs WITH (NOLOCK) on bs.Segment_ID = i.Segment_ID
						  left join T0040_SHIFT_MASTER SM WITH (NOLOCK)on sm.Shift_ID = e.Shift_ID
						  left join T0081_Emp_LetterRef_Details ELR WITH (NOLOCK) on ELR.Emp_Id = e.Emp_ID and ELR.Letter_Name=@Letter --Mukti(04012017)
						  --left join T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID and er.Effect_Date =(select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where Emp_ID= e.emp_id)
						  --inner join T0080_EMP_MASTER ERM on ERM.Emp_ID = er.R_Emp_ID
						  --update by chetan 30-11-16
						  Left Join
								(SELECT		Q.EMP_ID,MAX(RD.R_EMP_ID) AS R_EMP_ID 
								 FROM		T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) INNER JOIN
											(SELECT  MAX(EFFECT_DATE) MAX_DATE,EMP_ID 
											 FROM	 T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
											 WHERE	 EFFECT_DATE <= getdate() AND CMP_ID = @CMP_ID 
											 GROUP BY EMP_ID)Q ON Q.EMP_ID = RD.EMP_ID AND Q.MAX_DATE = RD.EFFECT_DATE								 
								 GROUP BY Q.EMP_ID)MAIN	ON Main.Emp_ID = Ec.Emp_ID LEFT JOIN 
											T0080_EMP_MASTER ERM WITH (NOLOCK) ON MAIN.R_EMP_ID = ERM.EMP_ID 											
						  LEFT join #finaldata_1 as F1 on F1.Emp_Id = EC.Emp_ID
								---------------------------------------	
				END	
			ELSE if @Req_Type =1
				BEGIN
			insert into #finaldata
					select CM.cmp_id,CM.Cmp_Name,CM.Cmp_Address,CM.cmp_logo
					      ,EC.Emp_ID,E.Grd_id,E.Branch_id,NULL,E.Desig_id,E.Dept_id,E.EmploymentTypeId
					      ,E.Resume_Code,E.App_Full_name,E.Resume_Code,E.Resume_ID,E.Rec_post_Id,E.Rec_Post_Code,E.Job_title
					      ,E.Grd_Name,E.Branch_Name,Branch_Address,Branch_City,null,E.Desig_Name,E.Dept_Name,E.Type_Name
					      ,E.Gender,E.Basic_Salay,E.Total_CTC,E.Joining_date,E.Vertical_Id,E.Vertical_Name,E.SubVertical_Id,E.SubVertical_Name
					      ,E.BusinessSegment_Id,E.Segment_Name,E.ShiftId,E.Shift_Name,E.Approval_Date
					      ,E.Present_Street,E.Present_City,E.Present_State,E.Present_Post_Box,E.BusinessHead,E.Level2_Approval
					      ,E.SalaryCycle_Id,E.ReportingManager_Id,rm.Emp_Full_Name,rm.Work_Email,E.notice_period,CM.Cmp_HR_Manager
					      ,CAST(@reportPath as varchar(max)) + '\report_image\header_' + cast (e.cmp_id as varchar) + '.bmp' as rp_header
						  ,CAST(@reportPath as varchar(max)) + '\report_image\Footer_' + cast (e.cmp_id as varchar) + '.bmp' as rp_Footer
						  ,replace(CAST(@reportPath as varchar(max)),'\Reports\','') + '\App_File\Signature\' + cast (e.Signature as varchar(max)) as rp_Sign
						  ,'',GETDATE(),'','' --Added by Sumit on 06022017 to blank pass data
						  ,isnull(E.Total_CTC,0)*12,dbo.F_Number_TO_Word(isnull(E.Total_CTC,0)*12),CM.Cmp_Email,E.Date_Of_Birth --added by chetan 220817
						  ,CM.Cmp_Code,'' as Dept_Code	--added by Rudra 09092019
						  ,E.Emp_Full_Name		--added by Rudra 09092019 
						   ,0    --added by  Deepali 08022023
						   ,0  --added by  Deepali 08022023
					from @Emp_Cons EC 
						inner Join V0060_RESUME_FINAL E On EC.Emp_ID = e.Resume_ID
						inner join T0010_COMPANY_MASTER CM WITH (NOLOCK) on cm.Cmp_Id = e.Cmp_ID
						inner join T0080_EMP_MASTER RM WITH (NOLOCK) on rm.Emp_ID = e.ReportingManager_Id 
				END
		--end	
		SELECT Cmp_Id				
				,Cmp_Name			
				,Cmp_Address		
				,Cmp_Logo			
				,Emp_Id				
				,Grd_Id				
				,Branch_Id			
				,Cat_Id				
				,Desig_Id			
				,Dept_Id			
				,[Type_id]			
				,Emp_Code			
				,Emp_Full_Name		
				,Resume_Code		
				,Resume_Id			
				,Rec_Post_Id		
				,Rec_Post_Code		
				,Job_Title			
				,Grd_Name			
				,Branch_Name		
				,Branch_Address		
				,Branch_City		
				,Cat_Name			
				,Desig_Name			
				,Dept_Name			
				,[Type_Name]		
				,Gender				
				,Basic_Salary		
				,Gross_Salary		
				,Join_date	
				,Vertical_Id		
				,Vertical_Name		
				,SubVertical_Id		
				,SubVertical_Name	
				,BusinessSegment_Id	
				,Segment_Name		
				,Shift_Id			
				,Shift_name			
				,Approval_Date		
				,Present_Street		
				,Present_City		
				,Present_State		
				,Zip_Code			
				,Business_Head		
				,Level2_Approval	
				,SalaryCycle_Id		
				,Reporting_ManagerId 	
				,Reporting_ManagerName	
				,Reporting_ManagerEmail	
				,ShortFall_Days		
				,cmp_hr_manager		
				,rp_header			
				,rp_Footer			
				,rp_Sign			
				,Reference_No		
				,Issue_Date			
				,Tehsil				
				,District			
				,CTC				
				,CTC_AMount_Word	
				,Cmp_Email			
				,DOB
				,Cmp_Code			--added by Rudra 09092019
				,Dept_Code
				,Emp_fName	
				,Var_Pay_Amt        --added by  Deepali 08022023
				,Var_Pay_Amt_Word   --added by  Deepali 08022023
		FROM #finaldata
		
	DROP table #finaldata	
	RETURN




