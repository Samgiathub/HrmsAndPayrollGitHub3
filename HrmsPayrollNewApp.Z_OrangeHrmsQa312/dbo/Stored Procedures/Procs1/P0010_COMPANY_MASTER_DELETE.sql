

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[P0010_COMPANY_MASTER_DELETE]
	@CMP_ID		NUMERIC
AS
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	UPDATE T0080_EMP_MASTER SET INCREMENT_ID = NULL WHERE CMP_ID = @CMP_ID
	Update T0011_LOGIN SEt Branch_ID = null Where Cmp_ID =@Cmp_ID
	
	declare @TableName as varchar(100)
	declare @Qry as varchar(1000)

	declare curDel cursor for
	select name from sysobjects O inner join 
		( SELECT Distinct ID FROM SYSCOLUMNS  where NAME ='Cmp_ID' ) s on o.id = s.id
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
			
			set @Qry = 'delete from ' + @TableName + ' where cmp_id = ' + cast(@cmp_id as varchar(4))
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




