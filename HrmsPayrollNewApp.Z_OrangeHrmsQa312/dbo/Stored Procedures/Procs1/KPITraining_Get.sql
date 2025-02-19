

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[KPITraining_Get]
	@cmp_id as  numeric(18,0),
	@fyear as int
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	declare @tid as numeric(18,0)
	
	create table #final
(
	 trainingname  varchar(100)
	,EmpName_cnt  int 
	,train_id	numeric(18,0)
	,employee_name varchar(max)
)
create table #final_Req
(
	 trainingname  varchar(100)
	,EmpName_cnt  int 
	,train_id	numeric(18,0)
	,employee_name varchar(max)
)

 
 declare @str varchar(8000)
	set @str=''
--insert training
insert into #final
	(trainingname,train_id)  
	select Training_name,Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where Cmp_Id=@cmp_id
	
--insert training
insert into #final_Req
	(trainingname,train_id)  
	select Training_name,Training_id from T0040_Hrms_Training_master WITH (NOLOCK) where Cmp_Id=@cmp_id
	
declare cur cursor
for 
	select train_id from #final
open cur
	Fetch Next From cur Into  @tid
	WHILE @@FETCH_STATUS = 0
		begin
				update #final
				set EmpName_cnt =
					(select COUNT(KPIPMS_ID) from T0080_KPIPMS_EVAL WITH (NOLOCK) where Final_Training like '%'+  cast(@tid as varchar(18)) +'%' and KPIPMS_FinancialYr = @fyear and KPIPMS_Type=2 and Cmp_ID=@cmp_id)					
				where train_id = @tid
				
				set @str=''		
				
				SELECT @str= coalesce(SUBSTRING(@str,2,(LEN(@str))) + ',', '') + a.Emp_Full_Name 
				FROM (SELECT DISTINCT Emp_Full_Name FROM T0080_KPIPMS_EVAL k WITH (NOLOCK) inner join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = k.Emp_ID WHERE   Final_Training like '%'+  cast(@tid as varchar(18)) +'%' and KPIPMS_FinancialYr = @fyear and KPIPMS_Type=2 and k.Cmp_ID=@cmp_id) a
				
				update #final
				set employee_name = SUBSTRING(@str,2,(LEN(@str)))					
				where train_id = @tid
			Fetch Next From cur Into  @tid
		End
close cur
deallocate cur

set @tid = null

declare cur cursor
for 
	select train_id from #final_Req
open cur
	Fetch Next From cur Into  @tid
	WHILE @@FETCH_STATUS = 0
		begin
				update #final_Req
				set EmpName_cnt =
					(select COUNT(KPIPMS_ID) from T0080_KPIPMS_EVAL WITH (NOLOCK) where Final_Training_Emp like '%'+  cast(@tid as varchar(18)) +'%' and KPIPMS_FinancialYr = @fyear and KPIPMS_Type=2 and Cmp_ID=@cmp_id)
				where train_id = @tid
				
				set @str=''		
				
				SELECT @str= coalesce(SUBSTRING(@str,2,(LEN(@str))) + ',', '') + a.Emp_Full_Name 
				FROM (SELECT DISTINCT Emp_Full_Name FROM T0080_KPIPMS_EVAL k WITH (NOLOCK) inner join T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = k.Emp_ID WHERE   Final_Training_Emp like '%'+  cast(@tid as varchar(18)) +'%' and KPIPMS_FinancialYr = @fyear and KPIPMS_Type=2 and k.Cmp_ID=@cmp_id) a
				
				
				update #final_Req
				set employee_name = SUBSTRING(@str,2,(LEN(@str)))					
				where train_id = @tid
				
			Fetch Next From cur Into  @tid
		End
close cur
deallocate cur

select train_id,trainingname,isnull(EmpName_cnt,0) as EmpName_cnt,Ltrim(employee_name)as employee_name from #final
select train_id,trainingname,isnull(EmpName_cnt,0)as EmpName_cnt,Ltrim(employee_name)as employee_name from #final_Req

drop table #final
drop table #final_Req

END

