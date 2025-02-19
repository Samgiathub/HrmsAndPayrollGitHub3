

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0050_CheckRange_Duplicate]
	  @deptstr  varchar(100)
	 ,@grdstr  varchar(100)
	 ,@cmp_id	as numeric(18,0)
	 ,@rangepid as numeric(18,0)
	 ,@Effective_Date as datetime = null --19 sep 2016
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	declare @col as  varchar(100)
	declare @col1 as  varchar(100)
	declare @col2 as  varchar(100)
	
	declare cur  cursor -- first cursor to iterare the split of user entered grades
for 
	select items from dbo.split2(@grdstr,'#')
	open cur
		Fetch Next From cur into @col
		WHILE @@FETCH_STATUS = 0
			Begin					
				declare cur1 cursor  -- second cursor for iterating thru' dept as result of 1st cursor
				for 
					select distinct(Range_Dept)as range_dept from T0040_HRMS_RangeMaster WITH (NOLOCK) where Range_Grade like '%#' + @col  + '#%' and Cmp_ID=@cmp_id and range_pid<>@rangepid and Effective_Date = @Effective_Date
					open cur1
						Fetch Next From cur1 into @col1
							WHILE @@FETCH_STATUS = 0
								begin
									--select @col1 as fd
									declare cur2 cursor -- third cursor to iterare the split of user entered dept
									for 
										select items from dbo.split2(@deptstr,'#')
										open cur2
											fetch next from cur2 into @col2
												while @@FETCH_STATUS = 0
													begin
														--select @col2,@col1
														If '#' + @col1 + '#' like '%#' + @col2 + '#%'
															begin
																--select @col1 as dept,@col2 as udept,@col as grade
																select Dept_Name,grd_name from T0040_DEPARTMENT_MASTER WITH (NOLOCK) ,T0040_GRADE_MASTER WITH (NOLOCK) where dept_id=@col2 and Grd_ID=@col
															End														
														fetch next from cur2 into @col2
													End
												close cur2
											deallocate cur2
									Fetch Next From cur1 into @col1
								End
					close cur1
				deallocate cur1
				Fetch Next From cur into @col
			End		
	Close cur	
Deallocate cur
END
-----------------

