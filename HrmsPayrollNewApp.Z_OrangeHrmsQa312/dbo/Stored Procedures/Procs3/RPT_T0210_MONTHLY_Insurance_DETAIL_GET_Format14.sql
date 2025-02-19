


-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <15/07/2015>
-- Description:	<Get Employee Insurance Details which effect in Salary>
---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_T0210_MONTHLY_Insurance_DETAIL_GET_Format14]
 @Cmp_ID 		numeric
,@From_Date 	datetime
,@To_Date 		datetime
,@Branch_ID 	numeric
,@Cat_ID 		numeric 
,@Grd_ID 		numeric
,@Type_ID 		numeric
,@Dept_ID 		numeric
,@Desig_ID 		numeric
,@Emp_ID 		numeric
,@constraint 	varchar(max)
,@Sal_Type		numeric = 0
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 
,@Vertical_Id numeric = 0		 
,@SubVertical_Id numeric = 0	
,@SubBranch_Id numeric = 0
,@Status varchar(20) = ''		
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
		IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
	 --Added By Gadriwala on 26072013--------------
	if @Segment_Id = 0 
		set @Segment_Id = null
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
	if @SubVertical_Id = 0 
	set @SubVertical_Id= Null
	-----------------------------------------------

	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 
	 
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END 
	
		select VEID.Emp_ID,cmp_ID,Ins_Name,Ins_Policy_No,Monthly_Premium from V0090_EMP_INSURANCE_DETAIL VEID inner join
		#Emp_Cons EC on VEID.Emp_Id = EC.Emp_ID
		 where  VEID.Cmp_ID = @cmp_ID  
		and isnull(Ins_Exp_Date,@To_Date) > = @To_Date and Sal_Effective_Date <= @To_Date and Deduct_From_Salary = 1 
		
END

