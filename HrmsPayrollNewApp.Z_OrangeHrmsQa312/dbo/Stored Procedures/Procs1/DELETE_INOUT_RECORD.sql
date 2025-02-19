




-- =============================================
-- Author:		<Alpesh>
-- ALTER date: <13-Oct-2011>
-- Description:	<To Delete Inout Record From T0150_EMP_INOUT_RECORD And T9999_DEVICE_INOUT_DETAIL>
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[DELETE_INOUT_RECORD]
  @Cmp_ID		numeric        
 ,@From_Date	datetime        
 ,@To_Date		datetime         
 ,@Branch_ID	numeric        
 ,@Dept_ID		numeric        
 ,@Desig_ID		numeric        
 ,@Emp_ID		numeric     
 ,@Is_Delete_Device_Data	tinyint
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	declare @Qry nvarchar(4000)
	declare @strWhr nvarchar(1000)
	declare @innerQry nvarchar(1000)
	declare @innerQry2 nvarchar(1000)
	
	set @Qry = ''
	set @strWhr = ''
	set @innerQry = ''
	set @innerQry2 = ''
	
	set @innerQry = ' and Emp_ID in (Select Emp_ID from T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = ' + cast(@Cmp_ID as varchar(5))
	set @innerQry2 = ' and Enroll_No in (Select Enroll_No from T0080_EMP_MASTER WITH (NOLOCK) Where Cmp_ID = ' + cast(@Cmp_ID as varchar(5))


if @Emp_ID <> 0
	set	@strWhr = @strWhr + ' and Emp_ID = ' + cast(@Emp_ID as varchar(5)) 

		
if @Branch_ID <> 0
begin
	set	@strWhr = @strWhr + ' and Branch_ID = ' + cast(@Branch_ID as varchar(5)) 
end

if @Dept_ID <> 0
begin
	set	@strWhr = @strWhr + ' and Dept_ID = ' + cast(@Dept_ID as varchar(5))
end

if @Desig_ID <> 0
begin
	set	@strWhr = @strWhr + ' and Desig_Id = ' + cast(@Desig_Id as varchar(5))
end	
   
   -- Insert Data into T0150_EMP_INOUT_RECORD_Deleted before Deleting
   set @Qry = 'Insert Into T0150_EMP_INOUT_RECORD_Deleted Select * from T0150_EMP_INOUT_RECORD WITH (NOLOCK) Where Cmp_ID = ' + cast(@Cmp_ID as varchar(5)) + ' and For_Date >= ''' + cast(@From_Date as varchar(20)) + ''' and For_Date <= ''' + cast(@To_Date as varchar(20)) + ''''+ @innerQry + @strWhr +')'	     
   exec(@Qry)
   ---
   
   set @Qry = 'Delete from T0150_EMP_INOUT_RECORD Where Cmp_ID = ' + cast(@Cmp_ID as varchar(5)) + ' and For_Date >= ''' + cast(@From_Date as varchar(20)) + ''' and For_Date <= ''' + cast(@To_Date as varchar(20)) + ''''+ @innerQry + @strWhr +')'	
   exec(@Qry)
   --print @Qry

	select @@rowcount as row_count
	
	if @Is_Delete_Device_Data = 1
	begin
		set @Qry = 'Delete from T9999_DEVICE_INOUT_DETAIL Where Cmp_ID = ' + cast(@Cmp_ID as varchar(5))+ ' and IO_DateTime >= ''' + cast(@From_Date as varchar(20)) + ''' and IO_DateTime <= ''' + cast(@To_Date as varchar(20)) +'''' + @innerQry2 + @strWhr +')'	
		exec(@Qry)
		--print @Qry
	end		
		
   
END




