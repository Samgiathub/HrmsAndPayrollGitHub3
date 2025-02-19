

-- =============================================
-- Author:		<SHAIKH RAMIZ>
-- Create date: <28-MAR-2019>
-- Description:	<TO PROVIDE THE LIST OF EMPLOYEES ELIGIBLE FOR LWF DEDUCTION>
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Employee_Records_with_LWF]
  @Cmp_ID   numeric
 ,@From_Date  datetime
 ,@To_Date   datetime
 ,@Branch_ID  Varchar(Max) = ''
 ,@Cat_ID     Varchar(Max) = ''
 ,@Grd_ID     Varchar(Max) = ''
 ,@Type_ID    Varchar(Max) = ''
 ,@Dept_ID    Varchar(Max) = ''
 ,@Desig_ID   Varchar(Max) = ''
 ,@Emp_ID numeric = 0
 ,@Constraint varchar(Max) = ''
 ,@Report_For VARCHAR(20)	= 'EMP_RECORD'
 --,@Segment_Id  Varchar(Max) = ''
 --,@Vertical_Id Varchar(Max) = ''
 --,@SubVertical_Id Varchar(Max) = ''
 --,@SubBranch_Id Varchar(Max) = ''
 --,@Type Varchar(Max) = ''
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
   
 CREATE table #Emp_Cons 
 (      
	EMP_ID			NUMERIC ,     
	BRANCH_ID		NUMERIC,
	INCREMENT_ID	NUMERIC    
 )
 
	IF @BRANCH_ID = ''
		SET @BRANCH_ID = NULL
		
		
	EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'0',0,0   
	
	IF @Report_For = 'EMP_RECORD'
		BEGIN
			SELECT EM.EMP_ID , ALPHA_EMP_CODE , EMP_FULL_NAME , MOBILE_NO , INC.GROSS_SALARY
			FROM	#EMP_CONS EC
					INNER JOIN T0080_EMP_MASTER EM	WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID
					INNER JOIN T0095_INCREMENT INC	WITH (NOLOCK) ON INC.INCREMENT_ID = EC.INCREMENT_ID
					INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON GS.BRANCH_ID = EC.BRANCH_ID
					INNER JOIN( SELECT MAX(For_Date) For_Date , BRANCH_ID 
								FROM T0040_GENERAL_SETTING WITH (NOLOCK)
								WHERE For_Date <= @TO_DATE and Cmp_ID = @Cmp_ID
								GROUP BY BRANCH_ID
							   ) G1 on GS.Branch_ID=G1.Branch_ID AND GS.For_Date=G1.For_Date
			WHERE	EM.IS_LWF = 1 AND GS.Is_LWF = 1
		END
	ELSE
		BEGIN
			SELECT	ALPHA_EMP_CODE , EMP_FULL_NAME ,BM.BRANCH_NAME,EM.Present_Street,CAST(MOBILE_NO AS VARCHAR(12)) AS MOBILE_NO,
					'="' + CONVERT(VARCHAR(12) , EM.Date_Of_Birth , 103) + '"' AS Date_Of_Birth,'="' + EM.Aadhar_Card_No + '"' As Aadhar_Card_No,INC.GROSS_SALARY AS Actual_Gross_Salary
			FROM	#EMP_CONS EC
					INNER JOIN T0080_EMP_MASTER EM	WITH (NOLOCK) ON EC.EMP_ID = EM.EMP_ID
					INNER JOIN T0095_INCREMENT INC	WITH (NOLOCK) ON INC.INCREMENT_ID = EC.INCREMENT_ID
					INNER JOIN T0030_BRANCH_MASTER BM	WITH (NOLOCK)ON BM.BRANCH_ID = EC.BRANCH_ID
					INNER JOIN T0040_GENERAL_SETTING GS WITH (NOLOCK) ON GS.BRANCH_ID = EC.BRANCH_ID
					INNER JOIN( SELECT MAX(For_Date) For_Date , BRANCH_ID 
								FROM T0040_GENERAL_SETTING WITH (NOLOCK)
								WHERE For_Date <= @TO_DATE and Cmp_ID = @Cmp_ID
								GROUP BY BRANCH_ID
							   ) G1 on GS.Branch_ID=G1.Branch_ID AND GS.For_Date=G1.For_Date
			WHERE	EM.IS_LWF = 1 AND GS.Is_LWF = 1
			ORDER BY ALPHA_EMP_CODE
		END
	
			
	
END




