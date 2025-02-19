
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GET_LEAVE_OTHER_EMP] 
	 @Cmp_ID numeric	
	,@Emp_ID numeric
	,@From_Date datetime
	,@Period numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	/*Modified by Nimesh on 02-Jan-2016*/
	/*The modification done for Havmor client. Employee can see only those employee data who belongs to their department.*/
	
	--Declare @Emp_Branch_ID numeric
	DECLARE @Dept_ID NUMERIC;
	Declare @To_Date datetime 

	set @To_Date =dateadd(day,@Period,@From_Date)

	SELECT	TOP 1 @Dept_ID=Dept_ID --@Emp_Branch_ID = Branch_ID 
	FROM	T0095_INCREMENT I WITH (NOLOCK)
	WHERE	I.Emp_ID=@Emp_ID And Cmp_ID=@Cmp_ID AND I.Increment_Effective_Date <= @FROM_DATE
	ORDER BY I.Increment_Effective_Date DESC, I.Increment_ID DESC
	
	
	SELECT DISTINCT VLA.* from V0120_LEAVE_APPROVAL VLA Inner join
	(
	
			select  For_Date,Emp_ID from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner join 
			T0040_LEAVE_MASTER LM WITH (NOLOCK) on Lt.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') <> 'COMP'   
			where Leave_Used > 0   and For_Date>= @From_Date and For_Date <= @To_Date
			and Emp_ID <> @Emp_ID and LT.cmp_ID = @cmp_ID 
			Union all
			select  For_Date,Emp_ID from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK) Inner join 
			T0040_LEAVE_MASTER LM WITH (NOLOCK) on Lt.Leave_ID = LM.Leave_ID and isnull(LM.Default_Short_Name,'') = 'COMP'   
			where (CompOff_Used - Leave_Encash_Days) > 0 and For_Date>= @From_Date  and For_Date <= @To_Date 
			and Emp_ID <> @Emp_ID and LT.cmp_ID = @cmp_ID 
			
	 ) Qry on Qry.Emp_ID = VLA.Emp_ID and qry.For_Date >= VLA.From_Date	and qry.For_Date <= VLA.To_Date           
	WHERE VLA.Dept_ID=@Dept_ID --VLA.Branch_ID = @Emp_Branch_ID 
	              
	
RETURN




