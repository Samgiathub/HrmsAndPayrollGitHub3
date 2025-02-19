
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_INSURANCE_DEDUCTION_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID     varchar(max) = ''  --added jimit 19052015
	,@Cat_ID		varchar(max) = ''   --added jimit 19052015
	,@Grd_ID		varchar(max) = ''  --added jimit 19052015
	,@Type_ID		varchar(Max) = ''  --added jimit 19052015
	,@Dept_ID		varchar(max) = '' --added jimit 19052015
	,@Desig_ID		varchar(max) = '' --added jimit 19052015
	,@Emp_ID		varchar(max) = ''  --added jimit 19052015
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Emp_Loan      varchar(10)='SELECT'
	,@Vertical_ID varchar(max)=''   --Added By Jaina 5-10-2015 
	,@SubVertical_ID varchar(max)='' --Added By Jaina 5-10-2015
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	
	exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,'',@Vertical_ID,@SubVertical_ID,'',@New_Join_emp,@Left_Emp,0,'0',0,0  --Change By Jaina 5-10-2015


	SELECT I_Q.* ,E.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name
		FROM	T0080_EMP_MASTER E WITH (NOLOCK)
				INNER JOIN #Emp_Cons CONS ON E.Emp_ID=CONS.Emp_ID 
				--INNER JOIN T0090_EMP_INSURANCE_DETAIL WD on E.Emp_ID =WD.Emp_Id 
				--Added By Jaina 03-10-2010 Start
				Inner JOIN 
				(
					SELECT Distinct E.Emp_Id FROM T0090_EMP_INSURANCE_DETAIL as E WITH (NOLOCK)
					WHERE Emp_Id =
										(SELECT  TOP 1  WD.Emp_Id FROM T0090_EMP_INSURANCE_DETAIL As WD WITH (NOLOCK)
																	INNER JOIN T0040_Insurance_Master IM WITH (NOLOCK) on WD.Ins_Tran_ID=IM.Ins_Tran_ID 
													WHERE  ISNULL(WD.Ins_Exp_Date,@To_Date) >= @To_Date AND WD.Sal_Effective_Date <=  @To_Date
											AND WD.Deduct_From_Salary = 1 AND WD.Cmp_ID=E.Cmp_ID AND E.Emp_Id=WD.Emp_Id
										) 
				)As WD1 ON WD1.Emp_Id=E.Emp_ID
				--Added By Jaina 03-10-2010 End
				INNER JOIN T0010_Company_master CM WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID 
				INNER JOIN ( 
								SELECT	I.Emp_Id,Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID 
								FROM	T0095_Increment I WITH (NOLOCK)
								WHERE	I.Increment_ID=(SELECT	TOP 1 INCREMENT_ID
														FROM	T0095_INCREMENT I2 WITH (NOLOCK)
														WHERE	I2.Cmp_ID=I.Cmp_ID AND I2.Emp_ID=I.Emp_ID AND I2.Increment_Effective_Date <= @TO_DATE
														ORDER BY I2.Increment_Effective_Date DESC, I2.Increment_ID DESC
														)
										AND I.Cmp_ID=@Cmp_ID
														
							) I_Q ON E.Emp_ID = I_Q.Emp_ID  
				INNER JOIN T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID 
				LEFT OUTER JOIN T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID 
				LEFT OUTER JOIN T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id 
				LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id 
				--INNER JOIN T0040_Insurance_Master IM on WD.Ins_Tran_ID=IM.Ins_Tran_ID 
				INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 					
		WHERE	E.Cmp_ID = @Cmp_Id --AND ISNULL(WD.Ins_Exp_Date,@To_Date) >= @To_Date AND WD.Sal_Effective_Date <= @To_Date 
				--AND WD.Deduct_From_Salary = 1 
		ORDER BY	(	
						CASE WHEN ISNUMERIC(E.Alpha_Emp_Code)=1 THEN 
							RIGHT(REPLICATE('0', 30) + E.Alpha_Emp_Code, 30) 
						ELSE
							E.Alpha_Emp_Code
						END
					)	
		
	RETURN




