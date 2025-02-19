




CREATE PROCEDURE [dbo].[P0095_PRE_CMP_TRANSFER_MULTI]

@cmp_id numeric(18,0),
@Multi_Value nvarchar(max)

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN
	

	 
	declare @detail						nvarchar(3000)
	declare @query						nvarchar(3000)	
	declare @Tran_Id					nvarchar(50)	
	declare @Old_Emp_ID					nvarchar(50)
	declare @Old_Cmp_ID					nvarchar(50)
	declare @New_Cmp_ID					nvarchar(50)
	declare @Increment_Effective_Date	nvarchar(50)

	set @Tran_Id	= '0'
	set @Old_Emp_ID	= ''
	set @Old_Cmp_ID	= ''
	set @New_Cmp_ID	= ''
	set @Increment_Effective_Date	= ''
    	
    	
    	
	declare  curMulti  cursor
	for
		select  data as val from dbo.Split(@Multi_Value,'$') 
	open curMulti
	fetch curMulti into @detail
	while @@FETCH_STATUS = 0
		begin
			IF @detail <> ''	 
				Begin
					
					select @Old_Cmp_ID = [1], @Old_Emp_ID = [2], @New_Cmp_ID = [3],@Increment_Effective_Date = [4] from 
					(
					 
						select [1],[2],[3],[4] from
						(
						select id,part  from dbo.SplitString2(@detail,'#') 
						) as tbl
						PIVOT
						(
							max(part)
							for id in ([1],[2],[3],[4] )
						) as pvt
								 
					) as multData

					 
							  
								set @query = 'exec P0095_EMP_CMP_TRANSFER_INSERT_MULTI ' + @Tran_Id + ',' + @Old_Emp_ID + ',' + @Old_Cmp_ID + ',' + @New_Cmp_ID +',''' + replace(convert(nvarchar(20),@Increment_Effective_Date,106),'','-') + ''',''I'''  
								 
								exec(@query)
				End
							
			fetch curMulti into @detail	
					
		end
	close curMulti
	deallocate curMulti

END

