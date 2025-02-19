-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 02/08/2023
-- Description:	To Get Skill & Certification Employee List
-- =============================================
CREATE PROCEDURE [dbo].[P0500_SkillCertification_Report] 
	@Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		varchar(MAX) = ''   
	,@Grd_ID		varchar(MAX) = ''  
	,@Cat_ID		varchar(MAX) = ''  
	,@Dept_ID		varchar(MAX) = ''           
	,@Type_ID		varchar(MAX) = ''                
	,@Desig_ID		varchar(MAX) = ''     
	,@Emp_ID		varchar(MAX) = 0 
	,@Constraint	varchar(MAX) = ''	
AS
BEGIN
	SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
		
		if @Branch_ID = '' 
			set @Branch_ID = null
		if @Cat_ID = '' 
			set @Cat_ID = null
		if @Type_ID = '' 
			set @Type_ID = null
		if @Dept_ID = '' 
			set @Dept_ID = null
		if @Grd_ID = ''
			set @Grd_ID = null
		if @Emp_ID = 0
			set @Emp_ID = null
		If @Desig_ID = ''
			set @Desig_ID = null

		CREATE TABLE #EMP_CONS 
		(      
			EMP_ID		 NUMERIC ,     
			BRANCH_ID	 NUMERIC,
			INCREMENT_ID NUMERIC
		)      
	
		--EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN  @Cmp_ID,@From_Date ,@To_Date ,@Branch_ID ,@Cat_ID ,@Grd_ID ,@Type_ID ,@Dept_ID ,@Desig_ID  ,@Emp_ID ,@Constraint ,0 ,0 ,0,0,0,0,0,0,0,0,0,0	
		--CREATE UNIQUE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #EMP_CONS (EMP_ID);
		
		
						
		-----------------------------------------Get the Employee Details from Company ID--------------------------------------
		
		SELECT distinct Emp_id, [Sub-Contractor], [Cost center] as Cost_Center into #tmpSCCC
		FROM
		(	SELECT Emp_id,Column_Name,Value from [T0081_CUSTOMIZED_COLUMN] cc 
			inner join T0082_Emp_Column ec WITH (NOLOCK) on cc.Tran_Id = ec.mst_Tran_Id where 
			 Column_Name in ('Sub-Contractor','Cost center')
		) AS SourceTable
		PIVOT
		(
			MAX(Value) FOR Column_Name IN ([Sub-Contractor], [Cost center])
		) AS PivotTable;
		
		
		----select *
		--SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name,BS.Segment_Name as [Business_Unit],e.Mobile_No , desig_name as Designation, dept_name as Department
		--, branch_name as [BRANCH_NAME],grd_name as [Grade Name], TEC.[Sub-Contractor] ,TEC.[Cost_center],I.Grd_ID
		--from t0080_emp_master e
		--inner join #EMP_CONS ec on ec.EMP_ID=e.Emp_ID
	
		--inner join t0095_increment i  on i.Increment_ID=ec.INCREMENT_ID
		--	LEFT OUTER JOIN t0040_grade_master GM WITH (NOLOCK) ON I.grd_id = gm.grd_id  
		--LEFT OUTER JOIN t0030_branch_master BM WITH (NOLOCK)	ON I.branch_id = BM.branch_id 
		--LEFT OUTER JOIN t0040_department_master DM WITH (NOLOCK) ON I.dept_id = DM.dept_id 
		--LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK) ON I.desig_id = DGM.desig_id 
		--LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK)	ON I.Segment_ID = BS.Segment_ID
		--LEFT OUTER JOIN #tmpSCCC TEC ON TEC.Emp_Id = e.Emp_ID
		
		SELECT E.emp_id, E.Alpha_Emp_Code , E.emp_full_name,BS.Segment_Name as [Business_Unit],e.Mobile_No , desig_name as Designation, dept_name as Department
		, branch_name as [BRANCH_NAME],grd_name as [Grade Name], TEC.[Sub-Contractor] ,TEC.[Cost_center],I.Grd_ID ,E.Date_Of_Join
		into #EmpDetails 
		FROM   t0080_emp_master E WITH (NOLOCK)
				INNER JOIN  #EMP_CONS EC
						ON E.emp_id = EC.emp_id 
				INNER JOIN t0095_increment I  WITH (NOLOCK)
						ON EC.Increment_ID = I.Increment_ID
				LEFT OUTER JOIN t0040_grade_master GM WITH (NOLOCK)
						ON I.grd_id = gm.grd_id  
				LEFT OUTER JOIN t0030_branch_master BM WITH (NOLOCK)
						ON I.branch_id = BM.branch_id 
				LEFT OUTER JOIN t0040_department_master DM WITH (NOLOCK)
				        ON I.dept_id = DM.dept_id 
				LEFT OUTER JOIN t0040_designation_master DGM WITH (NOLOCK)
					    ON I.desig_id = DGM.desig_id 
				LEFT OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK)
						ON I.Segment_ID = BS.Segment_ID
				LEFT OUTER JOIN #tmpSCCC TEC ON TEC.Emp_Id = E.Emp_ID
		----select * from #EmpDetails

		--SELECT   EMP_ID ,CM.Cnt_Name,q2.Amount,CM.GST_Percentage,grd_id 
		--into #tmp1 
		--FROM T0150_EMP_CANTEEN_PUNCH ECP WITH (NOLOCK)
		--LEFT JOIN T0050_CANTEEN_MASTER CM WITH (NOLOCK) ON ECP.Canteen_ID = CM.Cnt_Id
		--LEFT JOIN(
		--	SELECT DISTINCT Amount,CD.Cnt_Id,cd.grd_id FROM  T0050_CANTEEN_DETAIL CD WITH (NOLOCK) inner join 
		--	(SELECT  Max(Effective_Date) AS For_Date ,Cnt_Id
		--		FROM   T0050_CANTEEN_DETAIL WITH (NOLOCK)
		--		WHERE  Effective_Date <= Getdate() AND 
		--		cmp_id = @Cmp_ID group by Cnt_Id) Q1 
		--		ON CD.Cnt_Id = Q1.Cnt_Id and CD.Effective_Date = Q1.For_Date
		--	) Q2 on CM.Cnt_Id = q2.Cnt_Id
		--	Where ECP.Canteen_Punch_Datetime between @From_Date and @To_Date 
		--	order by Emp_ID
		
		----select * from #TMP1
			
		--SELECT E.EMP_ID, E.ALPHA_EMP_CODE , E.EMP_FULL_NAME,E.MOBILE_NO,[Business_Unit],[DESIGNATION],[DEPARTMENT],[BRANCH_NAME] 
		--,E.[SUB-CONTRACTOR] ,E.[Cost_center],CNT_NAME AS [ITEM_NAME] ,
		--COUNT(CNT_NAME) AS [ITEM_QTY], 
		--AMOUNT, 
		--(COUNT(CNT_NAME) * AMOUNT) as [NET_AMOUNT]
		--FROM #EMPDETAILS E 
		--INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID AND E.GRD_ID = T.GRD_ID
		--GROUP BY E.Alpha_Emp_Code,E.emp_full_name,e.Mobile_No,[DESIGNATION],[DEPARTMENT],[BRANCH_NAME],E.EMP_ID,CNT_NAME,AMOUNT, E.[Sub-Contractor] ,E.[Cost_center],[Business_Unit],t.GST_Percentage
		--ORDER BY e.emp_id

		--DROP TABLE #EMPDETAILS
		--DROP TABLE #TMP1
		--DROP TABLE #tmpSCCC

		Select SCD.Certi_Detail_Id,SCD.Cmp_Id  ,SCD.Emp_Id ,EM.Alpha_Emp_Code ,EM.Emp_Full_Name  ,EM.Department  ,EM.Designation  ,		
		EM.BRANCH_NAME,convert(varchar,EM.Date_Of_Join,103) as Date_Of_Join,convert(varchar,SCD.Created_Date,103) as Created_Date,
		CM.Cat_Name as Category_Name,CSM.SubCat_Name,SCD.Skill_Level,SCM.Certificate_Name,SCD.Exp_Years,
		case when SCD.Is_TrainingAttended = 0 then 'NO' else 'YES' END as Is_TrainingAttended,
		case when SCD.Training_Certi_Attachment = 'No file' then 'NO' else 'YES' END as Training_Certi_Attachment,
		case when SCD.Is_ExamAttended = 0 then 'NO' else 'YES' END as Is_ExamAttended,
		case when SCD.Exam_Certi_Attachment = 'No file' then 'NO' else 'YES' END as Exam_Certi_Attachment,
		scd.Descriptions,EM.Mobile_No,Convert(varchar,SCD.Cert_Exp_Date,103) as Cert_Exp_Date
		into #tmp1
		from 
		T0500_Certificateskill_Details SCD WITH (NOLOCK)
		LEFT OUTER JOIN T0500_Certificateskill_Master SCM with (NOLOCK) ON SCM.Certi_Id = SCD.Certi_Id	
		LEFT OUTER JOIN #EmpDetails EM on EM.Emp_ID = scd.Emp_Id
		LEFT OUTER JOIN T0500_CatSkill_Master CM on CM.Cat_Id = SCM.Cat_Id
		LEFT OUTER JOIN T0500_SubCatSkill_Master CSM on CSM.SubCat_Id = SCM.SubCat_Id
		--INNER JOIN T0100_LEAVE_APPLICATION LA with (NOLOCK) on LA.Emp_ID = CA.Emp_Id
		where SCD.Cmp_Id = @Cmp_ID and 
		convert(varchar, SCD.Created_Date, 105) >= convert(varchar, @From_Date, 105) and
		convert(varchar, SCD.Created_Date, 105) <= convert(varchar, @To_Date, 105)		
		--and LA.Cmp_ID = @Cmp_ID  and LA.Application_Status = 'A'
		order by SCD.Emp_Id


		SELECT distinct ROW_NUMBER() OVER (ORDER BY T.Certi_Detail_Id)as SrNo ,E.Emp_Id ,E.Alpha_Emp_Code ,E.Emp_Full_Name  ,
		E.Department  ,E.Designation  ,	E.BRANCH_NAME,convert(varchar,E.Date_Of_Join,103) as Date_Of_Joining,T.Created_Date,
		T.Category_Name as Skill_Cat_Name,T.SubCat_Name as Skill_Sub_Cat_Name,T.Skill_Level,T.Certificate_Name,T.Exp_Years,		
		T.Is_TrainingAttended as Is_Training_Attended,T.Training_Certi_Attachment as Training_Certificate_Attachment,
		T.Is_ExamAttended as Is_Exam_Attended,T.Exam_Certi_Attachment as Exam_Certificate_Attachment,
		T.Cert_Exp_Date as Expiry_Date_Of_Certification,T.Descriptions as Comments,E.Mobile_No		
			FROM #EMPDETAILS E 
			INNER JOIN #TMP1 T ON E.EMP_ID = T.EMP_ID 
		
		DROP TABLE #EMPDETAILS
		DROP TABLE #TMP1
		DROP TABLE #tmpSCCC

END
