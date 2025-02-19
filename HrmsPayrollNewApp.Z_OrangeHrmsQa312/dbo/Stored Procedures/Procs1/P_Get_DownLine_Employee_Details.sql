

-- =============================================
-- Description:	<To get direct indirect downline means Tree Structure>
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P_Get_DownLine_Employee_Details]
@Cmp_ID numeric(18,0),  
@empIdList varchar(Max),
@flag numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	
	DECLARE @EMP_id AS NUMERIC(18,0)
	DECLARE @EMPLOYEE_CODE VARCHAR(150)
	DECLARE	@EMPLOYEE_NAME VARCHAR(MAX)
	DECLARE	@BRANCH_NAME VARCHAR(200)
	DECLARE	@DESIGNATION VARCHAR(200)
	DECLARE @CTR AS NUMERIC(18,0)
	
	SET @CTR=0
	--Declare @Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @empIdList <> ''
	--	begin
	-- 		Insert Into @Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@empIdList,'#') 
	--	end
	--CREATE TABLE #EMP_LIST
	--(					
	--	EMPLOYEE_CODE VARCHAR(150),
	--	EMPLOYEE_NAME VARCHAR(MAX),
	--	BRANCH_NAME VARCHAR(200),
	--	DESIGNATION VARCHAR(200),
	--	LEVEL_NO	NUMERIC(18,0) 		
	--)	
		
	
	DECLARE DOWNLINE_EMP_DETAILS CURSOR FOR
	SELECT CAST(Data as numeric(18,0))  FROM dbo.Split(@empIdList,'#') where Data>0
	OPEN DOWNLINE_EMP_DETAILS
		fetch next from DOWNLINE_EMP_DETAILS into @EMP_ID
			while @@fetch_status = 0
				Begin
				
					--Select @EMPLOYEE_CODE=T.Alpha_Emp_Code,@EMPLOYEE_NAME=T.Emp_Full_Name,@BRANCH_NAME=BM.Branch_Name,@DESIGNATION=DM.Desig_Name
					Select T.Alpha_Emp_Code,T.Emp_Full_Name,BM.Branch_Name,DM.Desig_Name,@CTR AS LEVEL_NO
					INTO #EMP_LIST
					FROM T0080_EMP_MASTER  T WITH (NOLOCK)
							INNER JOIN (
										SELECT	Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method,MAX(Effect_Date) As Effect_Date 
										FROM	T0090_EMP_REPORTING_DETAIL E WITH (NOLOCK)
										WHERE	Effect_Date<=GetDate() 
										GROUP	BY Cmp_ID,Emp_ID,R_Emp_ID,Reporting_Method
										) E ON E.Emp_ID=T.Emp_ID And E.Cmp_ID=T.Cmp_ID 
							INNER JOIN (
										SELECT	INCREMENT_ID,I.Emp_ID,I.Cmp_ID,I.Branch_ID,I.Desig_Id
										FROM	T0095_INCREMENT I WITH (NOLOCK)
										WHERE	I.Increment_ID = (
																	SELECT	TOP 1 I1.Increment_ID
																	FROM	T0095_INCREMENT I1 WITH (NOLOCK)
																	WHERE	I1.Emp_ID=I.Emp_ID AND I1.Cmp_ID=I.Cmp_ID 
																	ORDER	BY I1.Increment_Effective_Date DESC, I1.Increment_ID DESC
																 )
										) I ON  T.Emp_ID=I.Emp_ID AND T.Cmp_ID=I.Cmp_ID
							INNER JOIN T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I.CMP_ID=BM.CMP_ID AND I.Branch_ID=BM.Branch_ID
							LEFT OUTER JOIN  T0040_DESIGNATION_MASTER DM WITH (NOLOCK) On Dm.Desig_ID = I.Desig_Id AND I.Cmp_ID = DM.Cmp_ID
					Where E.Effect_Date=(Select MAX(Effect_Date) FROM T0090_EMP_REPORTING_DETAIL ED WITH (NOLOCK)
										WHERE ED.Emp_ID=E.Emp_ID And Effect_Date<=GetDate())
					and (Emp_Left = 'N' or (Emp_Left = 'Y' and Emp_Left_Date >= GetDate()))
					AND E.R_Emp_ID=@Emp_ID AND (E.Cmp_ID=149 OR E.Reporting_Method='InDirect')			
			
					--INSERT INTO #EMP_LIST(EMPLOYEE_CODE,EMPLOYEE_NAME,BRANCH_NAME,DESIGNATION,LEVEL_NO) VALUES
					--(@EMPLOYEE_CODE,@EMPLOYEE_NAME,@BRANCH_NAME,@DESIGNATION,@CTR)
					SET @CTR = @CTR + 1
		fetch next from DOWNLINE_EMP_DETAILS into @EMP_ID
		End
	close DOWNLINE_EMP_DETAILS	
	deallocate DOWNLINE_EMP_DETAILS
	
	SELECT * FROM #EMP_LIST
END



