



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_EMP_MASTER_DELETE]
	@CMP_ID		NUMERIC,
	@EMP_ID		NUMERIC
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	UPDATE T0080_EMP_MASTER SET INCREMENT_ID = NULL WHERE EMP_ID = @EMP_ID
	Update T0011_LOGIN SET Branch_ID = null Where EMP_ID =@EMP_ID
	
	
	Delete from T0210_PAYSLIP_DATA Where Sal_Tran_ID in (select Sal_Tran_ID From T0200_Monthly_Salary WITH (NOLOCK) where Emp_ID=@Emp_ID)
	
	declare @TableName as varchar(100)
	declare @Qry as varchar(1000)

	declare curDel cursor for
	select name from sysobjects O inner join 
		( SELECT Distinct ID FROM SYSCOLUMNS  where NAME ='EMP_ID' ) s on o.id = s.id
	where type = 'U'
	order by name desc

	
	open curDel
	fetch next from curDel into @TableName

	while @@Fetch_Status = 0
	begin
		--print 'For Table:' + @TableName
		if substring(@TableName,1,1) = 'T' and @TableName <> 'T0001_LOCATION_MASTER'
		begin
			set @Qry = 'alter table ' + @TableName + ' disable trigger all'
			--print @Qry
			exec (@Qry)
			
			set @Qry = 'delete from ' + @TableName + ' where EMP_ID = ' + cast(@EMP_ID as varchar(4))
			--print @Qry
			exec (@Qry)
		
			set @Qry = 'alter table ' + @TableName + ' enable trigger all'
			--print @Qry
			exec (@Qry)
			
		end
		--print '--------------'
		
		fetch next from curDel into @TableName
	end

	close curDel
	deallocate curDel	

	
	RETURN




