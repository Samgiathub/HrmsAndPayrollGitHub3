




--SP_HRMS_FINAL_SCORE 26,'01-oct-2009','31-dec-2009',0,0,0,0,0,0,530,''


---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_HRMS_FINAL_SCORE]
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
	,@Constraint	varchar(5000) = ''
	,@Flage               numeric =0
	
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

	CREATE table #Final_Score
	(
	  Emp_ID  numeric,	
	  Title_Name varchar(20),	
	  Total_rate  numeric(18,2),
	  Evaluation_Rate Numeric(18,2)	
	
	)
	


	--exec SP_HRMS_MAX_RECORD  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,1
 --	exec SP_HRMS_MAX_RECORD  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,2
 --	exec SP_HRMS_MAX_RECORD  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,3
 --	exec SP_HRMS_MAX_RECORD  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,4
  

         		
	RETURN




