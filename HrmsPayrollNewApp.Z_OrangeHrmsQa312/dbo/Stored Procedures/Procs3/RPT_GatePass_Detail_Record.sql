

-- =============================================
-- AUTHOR:		<JIMIT>
-- ALTER DATE: <31/05/2016>
-- ModifiedBy : Deepak
--Modified Date: <10/07/2020>
--Description: Add Paramter @GatePass_Type  and R1.Gate_Pass_Type = Case When @GatePass_Type = 'All' then R1.Gate_Pass_Type else @GatePass_Type End,and r1.Reason_Name is not null    for GatePass Type parameter
-- DESCRIPTION:	<GATEPASS DETAIL REPORT>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_GatePass_Detail_Record] 
	 @CMP_ID		NUMERIC
	,@FROM_DATE		DATETIME
	,@TO_DATE		DATETIME
	,@BRANCH_ID		VARCHAR(MAX) 
	,@CAT_ID		VARCHAR(MAX)
	,@GRD_ID		VARCHAR(MAX) 
	,@TYPE_ID		VARCHAR(MAX) 
	,@DEPT_ID		VARCHAR(MAX) 
	,@DESIG_ID		VARCHAR(MAX) 
	,@EMP_ID		NUMERIC
	,@CONSTRAINT	VARCHAR(MAX)
	,@GatePass_Type varchar(10) = 'All'
	--,@REPORT_TYPE	TINYINT = 0
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	CREATE TABLE #EMP_CONS 
	 (      
	   EMP_ID NUMERIC ,     
	   BRANCH_ID NUMERIC,
	   INCREMENT_ID NUMERIC    
	 )  
	
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @CMP_ID,@FROM_DATE,@TO_DATE,@BRANCH_ID,@CAT_ID,@GRD_ID,@TYPE_ID,@DEPT_ID,@DESIG_ID,@EMP_ID,@CONSTRAINT,0,0,'','','','',0,0,0,'0',0,0    
	
	--added by jimit 03082016
	DECLARE @GatePass_caption as Varchar(20)	
	SELECT @GatePass_caption = Isnull(Alias,'Gate Pass') from T0040_CAPTION_SETTING WITH (NOLOCK) where Cmp_Id = @Cmp_ID and SortingNo = 33
	--ended
	
	SELECT		GP.APP_ID AS APP_CODE,EM.ALPHA_EMP_CODE,EM.EMP_FULL_NAME,GP.APP_DATE AS GATE_PASS_DATE,
				convert(varchar(5),GP.FROM_TIME,108) as FROM_TIME,convert(varchar(5),GP.TO_TIME,108) as TO_TIME,GPA.Duration as Durat,GPA.MANAGER_REMARKS,
				convert(varchar(5),EGP.OUT_TIME,108) AS ACTUAL_OUT_TIME,convert(varchar(5),EGP.IN_TIME,108) AS ACTUAL_IN_TIME,EGP.[HOURS] AS DURATION,
				GP.REMARKS AS EMPLOYEE_REMARKS
				,BM.Branch_Name,DM.Dept_Name,DGM.Desig_Name,GM.Grd_Name,Tm.[Type_Name],Vs.Vertical_Name,sv.SubVertical_Name
				,Cm.Cmp_Name,Cm.Cmp_Address,BM.Comp_Name,BM.Branch_Address
				,L.Login_Name as Security_person_out_By,L1.Login_Name as Security_person_IN_By
				,@FROM_DATE as Period_From_date,@TO_DATE as Period_To_date
				,r.Reason_Name as Application_Reason,r1.Reason_Name as Approval_Reason
				,@GatePass_caption as Caption --added jimit 03082016
	FROM		T0100_GATE_PASS_APPLICATION GP WITH (NOLOCK) Left Outer join 
				T0120_GATE_PASS_APPROVAL GPA WITH (NOLOCK) ON  GP.EMP_ID = GPA.EMP_ID ANd GP.APP_ID = GPA.APP_ID  Left OUTER join 
				T0150_EMP_Gate_Pass_INOUT_RECORD EGP WITH (NOLOCK) ON GPA.EMP_ID = EGP.EMP_ID and EGP.app_Id = GPA.App_ID INNER JOIN						
				--T0120_GATE_PASS_APPROVAL GPA ON GPA.EMP_ID = EGP.EMP_ID and EGP.app_Id = GPA.App_ID INNER JOIN
				--T0100_GATE_PASS_APPLICATION GP ON GP.APP_ID = GPA.APP_ID AND GP.EMP_ID = GPA.EMP_ID INNER JOIN			
				T0080_EMP_MASTER EM WITH (NOLOCK) ON GP.EMP_ID = EM.EMP_ID INNER JOIN
				 ( SELECT I.BRANCH_ID,I.GRD_ID,I.DEPT_ID,I.DESIG_ID,I.EMP_ID,I.[Type_ID],I.Vertical_ID,I.SubVertical_ID FROM DBO.T0095_INCREMENT I WITH (NOLOCK) INNER JOIN 
							( SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM DBO.T0095_INCREMENT WITH (NOLOCK)
							WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
							AND CMP_ID = @CMP_ID
							GROUP BY EMP_ID  ) QRY ON
							I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID	)Q_I ON
				EM.EMP_ID = Q_I.EMP_ID INNER JOIN
						dbo.T0040_GRADE_MASTER GM WITH (NOLOCK) ON Q_I.Grd_Id = gm.Grd_ID INNER JOIN 
						dbo.T0030_BRANCH_MASTER BM WITH (NOLOCK) ON Q_I.BRANCH_ID = BM.BRANCH_ID LEFT OUTER JOIN
						dbo.T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON Q_I.DEPT_ID = DM.DEPT_ID LEFT OUTER JOIN 
						dbo.T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON Q_I.DESIG_ID = DGM.DESIG_ID Left Outer JOIN
						T0040_TYPE_MASTER Tm WITH (NOLOCK) On tm.[Type_ID]= Q_I.[Type_ID] Left Outer join
						T0040_Vertical_Segment Vs WITH (NOLOCK) On vs.Vertical_ID = Q_I.Vertical_ID Left Outer JOIN
						T0050_SubVertical sv WITH (NOLOCK) On sv.SubVertical_ID= Q_I.SubVertical_ID inner join
						T0010_COMPANY_MASTER Cm WITH (NOLOCK) On Cm.Cmp_Id = Em.Cmp_ID INNER JOIN
						#EMP_CONS EC ON EC.EMP_ID = GP.EMP_ID Left Outer JOIN
						T0011_LOGIN L WITH (NOLOCK) On L.Login_ID = GPA.Security_OutTime_UserID and L.Cmp_ID = GPA.Cmp_ID LEFT Outer JOIN
						T0011_LOGIN L1 WITH (NOLOCK) On l1.Login_ID = GPA.Security_InTime_UserID and L.Cmp_ID = GPA.Cmp_ID Left outer JOIN
						T0040_Reason_Master R WITH (NOLOCK) On r.Res_Id = Gp.Reason_ID --and R.Gate_Pass_Type = Case When @GatePass_Type = 'All' then R.Gate_Pass_Type else @GatePass_Type End
						Left outer JOIN
						T0040_Reason_Master R1 WITH (NOLOCK) On r1.Res_Id = GPA.Reason_ID and R1.Gate_Pass_Type = Case When @GatePass_Type = 'All' then R1.Gate_Pass_Type else @GatePass_Type End 
	WHERE		GP.FOR_DATE >= @FROM_DATE AND GP.FOR_DATE <=@TO_DATE and r1.Reason_Name is not null
	ORDER BY	Case When IsNumeric(EM.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + EM.Alpha_Emp_Code, 20)
					 When IsNumeric(EM.Alpha_Emp_Code) = 0 then Left(EM.Alpha_Emp_Code + Replicate('',21), 20)
				Else      EM.Alpha_Emp_Code
				End,GP.App_Date,GP.APP_ID						
				
	
				
END


