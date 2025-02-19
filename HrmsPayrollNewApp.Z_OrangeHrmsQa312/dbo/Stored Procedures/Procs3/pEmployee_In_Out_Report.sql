



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[pEmployee_In_Out_Report]
	@Cmp_ID as numeric
	,@From_Date as datetime
   ,@To_Date as datetime
   ,@Grd_ID as numeric
   ,@Dept_ID as numeric
   ,@Desig_Id as numeric
   ,@Type_ID as numeric
   
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	Declare @strwhere varchar(200)
	declare @sqlquery varchar(200)
	set @strwhere = 'Cmp_ID = ' + @Cmp_ID + ' and Emp_Left =' + 'N'
	 
	 declare @Empployee_In_Out_Table table
	 (
		 EmployeeName varchar(100)
	    ,OnDate datetime
	    ,InTime varchar(8)
	    ,OutTime varchar(8)
	    ,Duration varchar(8)
	    ,LateIn varchar(8)
	    ,LateOut varchar(8)
	    ,EarlyIn varchar(8)
	    ,EarlyOut varchar(8)
	    ,TotalWork varchar(8)
	    ,Deficit varchar(8)
	    ,Surplus varchar(8)
	 )
	 	 /* Creating Query  Employee Master*/
	 if @Grd_ID <> 0 
		set @strwhere = ' and Grd_ID = ' + cast(@Grd_ID as varchar)
		
	if 	@Dept_ID <> 0
		set @strwhere = @strwhere + ' and  @Dept_ID = ' + cast(@Dept_ID as varchar)
		
	if @Desig_Id <> 0
		set @strwhere = @strwhere + ' and  Desig_Id = ' + cast(@Desig_Id as varchar)
	if @Type_ID <> 0
	 set @strwhere = @strwhere + ' and  Type_ID = ' + cast(@Type_ID as varchar)
	 
	set  @sqlquery = 'select Emp_ID,Emp_Full_Name from T0080_EMP_MASTER WITH (NOLOCK) where' + @strwhere
	print @sqlquery
	 
	RETURN




