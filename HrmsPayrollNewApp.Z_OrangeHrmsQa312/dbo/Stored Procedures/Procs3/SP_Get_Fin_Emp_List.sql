
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Fin_Emp_List]          
  @Cmp_ID			numeric          
 ,@Fin_Year			varchar(20)          
 ,@Branch_ID		varchar(MAX)     
 ,@Cat_ID			varchar(MAX)            
 ,@Grd_ID			varchar(MAX)        
 ,@Type_ID			varchar(MAX)          
 ,@Dept_ID			varchar(MAX)            
 ,@Desig_ID			varchar(MAX)            
 ,@Emp_ID			numeric  = 0        
 ,@constraint		VARCHAR(MAX)          

AS 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Begin

		declare @From_Date as datetime
		declare @To_Date as datetime
		
		set @From_Date = cast('01-Apr-' + cast(left(@Fin_Year,4)as VARCHAR(4))as datetime)
		set	@To_Date = cast('31-Mar-' + cast(right(@Fin_Year,4)as VARCHAR(4)) as datetime)
		
		 CREATE table #Emp_Cons 
		 (      
		   Emp_ID numeric ,     
		   Branch_ID numeric,
		   Increment_ID numeric    
		 )
		 CREATE CLUSTERED INDEX IX_EMP_CONS_EMPID ON #Emp_Cons (EMP_ID);
		
		
		EXEC SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,0,@Grd_ID,@Type_ID,@Dept_ID,0,@Emp_ID,@constraint,0,0,0,0,0,0,0,0,0,'',0,0    


		select	EC.Emp_ID,E.Alpha_Emp_Code,E.Emp_Full_Name,cast(isnull(E.Alpha_Emp_Code,'') + ' - ' + E.Emp_Full_Name as varchar(500)) as Emp_Name
		from	#Emp_Cons EC
				inner join T0080_EMP_MASTER E WITH (NOLOCK) on EC.Emp_ID = E.Emp_ID
End