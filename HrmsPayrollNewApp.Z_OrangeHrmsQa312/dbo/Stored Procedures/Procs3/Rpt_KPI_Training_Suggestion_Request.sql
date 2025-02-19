

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Rpt_KPI_Training_Suggestion_Request 9,null,null,2015,null,'',1
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_KPI_Training_Suggestion_Request]
	 @cmp_id    as numeric(18,0)
	--,@deptId    as numeric(18,0)=null
	,@deptId    as varchar(max)='' --Mukti(17062017)
	,@emp_id    as numeric(18,0)=null
	,@Fin_year	as int			
	--,@frmdate   as datetime = getdate
	--,@enddate   as datetime = getdate
	,@dyQuery   varchar(max)=''
	,@type      as int
AS
BEGIN

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


create table #Final
(
	 Training_Id		numeric(18,0)
	,Training_Name		Varchar(100)
	,fin_Year			varchar(10)	
	,Manager			Varchar(100)
	,Employee_Name		Varchar(100)
	,KPIPMS_Id			numeric(18,0)
	,EMP_Id			    numeric(18,0)
	,Branch_Name		varchar(50)
	,Grade_name			varchar(50)
	,Dept_name			varchar(50)
	,Desig_name			varchar(50)
	,typename			varchar(50)
	,cat_name			varchar(50)
	,branchid			numeric(18,0) --Mukti(19062017)
	,DesigId			numeric(18,0)
	,Grd_Id				numeric(18,0)
	,TypeId				numeric(18,0)
	,Catid				numeric(18,0)
)

declare @col1 as  numeric(18,0)
declare @col2 as varchar(100)


if @type = 1
	Begin
		Declare Cur  Cursor
		for 
		select  training_id,training_name from t0040_hrms_training_master WITH (NOLOCK) where cmp_id = @cmp_id
		open cur
			fetch next from Cur into @col1,@col2
			while @@FETCH_STATUS = 0
				begin	
				 if exists(Select 1 from T0080_KPIPMS_EVAL k WITH (NOLOCK) where k.Cmp_Id = @cmp_id and k.KPIPMS_Type = 2 and KPIPMS_FinancialYr = @Fin_year and Final_Training like ''+ cast(@col1 as varchar(3)) +'%')				
					begin						 
						Insert into #Final(fin_year,EMP_Id,KPIPMS_Id,Employee_Name,Manager,Training_Id,Training_Name,Desig_name,Dept_name,Grade_name,cat_name,typename,branchid,DesigId,Grd_Id,TypeId,Catid)
						(Select (cast(KPIPMS_FinancialYr as varchar(5))+'-'+ cast(KPIPMS_FinancialYr+1 as varchar(5))),k.Emp_ID,KPIPMS_ID,e.Emp_Full_Name,er.Emp_Full_Name,@col1,@col2,dg.Desig_Name,Dept_Name,Grd_Name,Cat_Name,TYPE_NAME,i.Branch_ID ,i.Desig_Id,i.Grd_ID,i.Type_ID,i.Cat_ID 
						from T0080_KPIPMS_EVAL K WITH (NOLOCK)
						 inner Join T0080_EMP_MASTER E WITH (NOLOCK) on k.Emp_ID = E.Emp_ID 
						inner join T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) on erd.emp_id = k.emp_id 
						INNER JOIN (select max(Effect_Date) as Effect_Date,emp_id 
						from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) where ERD1.Effect_Date <= getdate() 
						GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = isnull(ERD.Effect_Date,ERD.Effect_Date)
						 inner join T0080_EMP_MASTER er WITH (NOLOCK) on er.Emp_ID = erd.R_Emp_ID 
						 inner join T0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID = e.emp_id and i.increment_id= (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=e.Emp_ID)
						 left join T0040_DESIGNATION_MASTER dg WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id
						 left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.dept_id	
						 left join T0040_GRADE_MASTER g WITH (NOLOCK) on g.Grd_ID = i.Grd_ID 
						 left join T0030_CATEGORY_MASTER c WITH (NOLOCK) on c.Cat_ID = i.Cat_ID
						 left join T0040_TYPE_MASTER t WITH (NOLOCK) on t.Type_ID = i.Type_ID
						 where	k.Cmp_Id = @cmp_id and k.KPIPMS_Type = 2 and KPIPMS_FinancialYr = @Fin_year 
						 and Final_Training like ''+ cast(@col1 as varchar(3)) +'%')
					 End
				Else
					Begin
						Insert into #Final(Training_Id,Training_Name)
						values(@col1,@col2)	
					END
					fetch next from Cur into @col1,@col2
				END
		close cur
		deallocate cur		
	End
Else if @type = 2
	Begin
		Declare Cur  Cursor
		for 
		select  training_id,training_name from t0040_hrms_training_master WITH (NOLOCK) where cmp_id = @cmp_id
		open cur
			fetch next from Cur into @col1,@col2
			while @@FETCH_STATUS = 0
				begin	
				 if exists(Select 1 from T0080_KPIPMS_EVAL k WITH (NOLOCK) where k.Cmp_Id = @cmp_id and k.KPIPMS_Type = 2 and KPIPMS_FinancialYr = @Fin_year and Final_Training_Emp like ''+ cast(@col1 as varchar(3)) +'%')				
					begin						 
						Insert into #Final(fin_year,EMP_Id,KPIPMS_Id,Employee_Name,Manager,Training_Id,Training_Name,Desig_name,Dept_name,Grade_name,cat_name,typename,branchid,DesigId,Grd_Id,TypeId,Catid)
						(Select (cast(KPIPMS_FinancialYr as varchar(5))+'-'+ cast(KPIPMS_FinancialYr+1 as varchar(5))),k.Emp_ID,KPIPMS_ID,e.Emp_Full_Name,er.Emp_Full_Name,@col1,@col2,dg.Desig_Name,Dept_Name,Grd_Name,Cat_Name,TYPE_NAME,i.Branch_ID ,i.Desig_Id,i.Grd_ID,i.Type_ID,i.Cat_ID 
						 from T0080_KPIPMS_EVAL K WITH (NOLOCK)
						 inner Join T0080_EMP_MASTER E WITH (NOLOCK) on k.Emp_ID = E.Emp_ID 
						 inner join T0090_EMP_REPORTING_DETAIL ERD WITH (NOLOCK) on erd.emp_id = k.emp_id 
						 INNER JOIN (select max(Effect_Date) as Effect_Date,emp_id 
						 from T0090_EMP_REPORTING_DETAIL ERD1 WITH (NOLOCK) where ERD1.Effect_Date <= getdate() 
						 GROUP by emp_id ) Tbl1 ON Tbl1.Emp_ID = ERD.Emp_ID AND Tbl1.Effect_Date = isnull(ERD.Effect_Date,ERD.Effect_Date)
						 inner join T0080_EMP_MASTER er WITH (NOLOCK) on er.Emp_ID = erd.R_Emp_ID
						 inner join T0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID = e.emp_id and i.increment_id= (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=e.Emp_ID)
						 left join T0040_DESIGNATION_MASTER dg WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id
						 left join T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id = i.dept_id	
						 left join T0040_GRADE_MASTER g WITH (NOLOCK) on g.Grd_ID = i.Grd_ID 
						 left join T0030_CATEGORY_MASTER c WITH (NOLOCK) on c.Cat_ID = i.Cat_ID
						 left join T0040_TYPE_MASTER t WITH (NOLOCK) on t.Type_ID = i.Type_ID
						 where	k.Cmp_Id = @cmp_id and k.KPIPMS_Type = 2 and KPIPMS_FinancialYr = @Fin_year 
						 and Final_Training_Emp like ''+ cast(@col1 as varchar(3)) +'%')
					 End
				Else
					Begin
						Insert into #Final(Training_Id,Training_Name)
						values(@col1,@col2)	
					END
					fetch next from Cur into @col1,@col2
				END
		close cur
		deallocate cur	
	End
	
	declare @query as varchar(MAX)
	set @query='Select 
  Case When row_number() OVER ( PARTITION BY Training_Name order by Training_Name) = 1
Then  Training_Name else null end as ''Training Name'',
Case When row_number() OVER ( PARTITION BY Training_Name order by Training_Name) = 1
Then  fin_Year else null end as ''Financial Year'',
Employee_Name as Employee,
Manager,
Desig_name as Designation,
Dept_name as Department,
Grade_name as Grade,
cat_name as Category,
typename as [Type]
from #Final'

exec (@query + @dyQuery)
print  (@query + @dyQuery)
drop table #Final
END

