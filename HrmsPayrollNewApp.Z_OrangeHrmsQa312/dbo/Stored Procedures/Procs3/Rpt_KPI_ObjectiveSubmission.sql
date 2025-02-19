

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Rpt_KPI_ObjectiveSubmission 9,null,2015,'-1'
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Rpt_KPI_ObjectiveSubmission]
	@cmp_id    as numeric(18,0)
	,@emp_id    as numeric(18,0)=null
	,@Fin_year	as int	
	,@condition   varchar(max)= '-1'
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 08-10-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 08-10-2015
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	if @condition = '-1'
		set @condition = '1=1'
	
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 08-10-2015
	set @PBranch_ID = null   	
	
	if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 08-10-2015
		set @PVertical_ID = null

	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 08-10-2015
		set @PsubVertical_ID = null
		
	IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 08-10-2015
		set @PDept_ID = NULL	 
	
	
		
	--Added By Jaina 08-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK)where Cmp_ID=@Cmp_ID 
		
		If @PVertical_ID IS NULL
			set @PVertical_ID = '0';
		else
			set @PVertical_ID = @PVertical_ID + ',0'		
	End
	if @PsubVertical_ID is null
	Begin	
		select   @PsubVertical_ID = COALESCE(@PsubVertical_ID + ',', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		If @PsubVertical_ID IS NULL
			set @PsubVertical_ID = '0';
		else
			set @PsubVertical_ID = @PsubVertical_ID + ',0'
	End
	IF @PDept_ID is null
	Begin
		select   @PDept_ID = COALESCE(@PDept_ID + ',', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		if @PDept_ID is null
			set @PDept_ID = '0';
		else
			set @PDept_ID = @PDept_ID + ',0'
	End
	--Added By Jaina 08-10-2015 End

	declare @col as numeric(18,0)
	
	create table #final
	(
		 empkpiid			numeric(18,0)
		,emp_id				numeric(18,0)
		,emp_code			varchar(50)
		,emp_full_name		varchar(100)
		,branch				varchar(50)
		,branch_id			numeric(18,0)
		,dept_id			numeric(18,0)
		,dept_name			varchar(50)
		,desig_id			numeric(18,0)
		,desig_name			varchar(50)
		,grade_id			numeric(18,0)
		,grade_name			varchar(50)
		,subvertical_id		numeric(18,0)
		,subvertical_name	varchar(50)
		,cat_id				numeric(18,0)
		,cat_name			varchar(50)
		,typeid				numeric(18,0)
		,typename			varchar(50)
		,Doj				datetime
		,gender				varchar(10)
		,Obj_Status			varchar(100)
		,Submissiondate		datetime	
		,first_levelId		numeric(18,0)
		,first_levelcode	varchar(50)
		,first_levelName	varchar(100)	
		,second_levelId		numeric(18,0)
		,second_levelcode	varchar(50)
		,second_levelName	varchar(100)
		,third_levelId		numeric(18,0)
		,third_levelcode	varchar(50)
		,third_levelName	varchar(100)
		,fourth_levelId		numeric(18,0)
		,fourth_levelcode	varchar(50)
		,fourth_levelName	varchar(100)
		,fifth_levelId		numeric(18,0)
		,fifth_levelcode	varchar(50)
		,fifth_levelName	varchar(100)
		,vertical_id  numeric(18,0)   --Added By Jaina 8-10-2015
		
	)
	
		
	insert into #final(empkpiid,emp_id,emp_code,emp_full_name,branch,branch_id,dept_id,dept_name,desig_id,desig_name,grade_id,grade_name,
						subvertical_id,subvertical_name,cat_id,cat_name,typeid,typename,Doj,gender,Obj_Status,submissiondate,vertical_id)	 --Change By Jaina 8-10-2015 Vertical_id
	(select k.EmpKPI_Id,k.emp_id,e.Alpha_Emp_Code,e.Emp_Full_Name,b.Branch_Name,i.Branch_ID,i.Dept_ID,d.dept_name,i.Desig_Id,dg.desig_name,
			i.Grd_ID,g.Grd_Name,i.SubVertical_ID,sv.SubVertical_Name,i.Cat_ID,c.Cat_Name,i.Type_ID,t.Type_Name,e.Date_Of_Join,
			case when e.Gender = 'F' then 'Female' else 'Male' end,
			case when k.Status=0 then 'Draft' else case when k.Status=1 then 'Send for Employee Review & Approval' else case when k.Status=2 then 'Reviewed By Employee' else case when k.Status=3 then 'Approved by Employee' else case when k.Status=4 then 'Approved by Line Manager' 
			else case when k.Status=5 then 'Send For Manager Review' else case when k.Status=6 then 'Approved By HR' end end end end end end end,
			case when k.Status = 0 then null else k.CreatedDate end			
			,I.Vertical_ID   --Added By Jaina 8-10-2015
	from T0080_EmpKPI k  WITH (NOLOCK)
		inner join  T0080_EMP_MASTER E WITH (NOLOCK)  on E.Emp_ID = k.Emp_Id 
		inner join  T0095_INCREMENT I WITH (NOLOCK) on i.emp_id = e.Emp_ID and i.Increment_ID = (select MAX(Increment_ID) from T0095_INCREMENT WITH (NOLOCK) where Emp_ID=k.Emp_Id)	
		left  join  T0030_BRANCH_MASTER b WITH (NOLOCK) on b.Branch_ID = i.Branch_ID
		left  join  T0040_DEPARTMENT_MASTER d WITH (NOLOCK) on d.Dept_Id=i.Dept_ID
		left  join  T0040_DESIGNATION_MASTER dg WITH (NOLOCK) on dg.Desig_ID = i.Desig_Id 
		left  join  T0040_GRADE_MASTER g WITH (NOLOCK) on g.Grd_ID = i.grd_id
		left  join  T0050_SubVertical sv WITH (NOLOCK) on sv.SubVertical_ID = i.SubVertical_ID
		left  join  T0030_CATEGORY_MASTER C WITH (NOLOCK) on c.Cat_ID = i.Cat_ID
		left  join  T0040_TYPE_MASTER T WITH (NOLOCK) on t.Type_ID =i.Type_ID
   	    --Added By Jaina 14-10-2015
	where  EXISTS (select Data from dbo.Split(@PBranch_ID, ',') B Where cast(B.data as numeric)=Isnull(I.Branch_ID,0))
		and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
		and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
		and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
		--Added By Jaina 14-10-2015 end
		and k.FinancialYr=@Fin_year and k.Cmp_Id=@cmp_id)   
			
	
	declare cur cursor
	for 
		select empkpiid from #final
	open cur
			fetch next from Cur into @col
			while @@FETCH_STATUS = 0
				begin
					--1st level
					update #final 
					set first_levelId	= u.s_emp_id,
						first_levelName	= u.Emp_Full_Name,
						first_levelcode = u.Alpha_Emp_Code
					from (select A.s_emp_id,alpha_emp_code, Emp_Full_Name 
						  from T0090_EmpKPI_Approval A WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID=A.S_Emp_Id
						  where A.EmpKPI_Id=@col and Rpt_Level=1) u
					where empkpiid=@col
					
					--2nd level
					update #final 
					set second_levelId =	u.s_emp_id,
						second_levelName=	 u.Emp_Full_Name,
						second_levelcode =  u.Alpha_Emp_Code
					from (select A.s_emp_id,alpha_emp_code,Emp_Full_Name 
						  from T0090_EmpKPI_Approval A WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID=A.S_Emp_Id
						  where A.EmpKPI_Id=@col and Rpt_Level=2) u
					where empkpiid=@col
					
					--3rd level
					update #final 
					set third_levelId =	u.s_emp_id,
						third_levelName=	 u.Emp_Full_Name,
						third_levelcode = u.Alpha_Emp_Code
					from (select A.s_emp_id,alpha_emp_code,Emp_Full_Name 
						  from T0090_EmpKPI_Approval A WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID=A.S_Emp_Id
						  where A.EmpKPI_Id=@col and Rpt_Level=3) u
					where empkpiid=@col
					
					--4th level
					update #final 
					set fourth_levelId =	u.s_emp_id,
						fourth_levelName=	 u.Emp_Full_Name,
						fourth_levelcode =  u.Alpha_Emp_Code
					from (select A.s_emp_id,alpha_emp_code,Emp_Full_Name 
						  from T0090_EmpKPI_Approval A WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID=A.S_Emp_Id
						  where A.EmpKPI_Id=@col and Rpt_Level=4) u
					where empkpiid=@col
					
					--5th level
					update #final 
					set fifth_levelId =	u.s_emp_id,
						fifth_levelName=	 u.Emp_Full_Name,
						fifth_levelcode =   u.Alpha_Emp_Code
					from (select A.s_emp_id,alpha_emp_code,Emp_Full_Name 
						  from T0090_EmpKPI_Approval A WITH (NOLOCK) inner join
								T0080_EMP_MASTER E WITH (NOLOCK) on e.Emp_ID=A.S_Emp_Id
						  where A.EmpKPI_Id=@col and Rpt_Level=3) u
					where empkpiid=@col
					
					fetch next from Cur into @col
				end
	close cur
	deallocate cur
	
	declare @query as varchar(max) 
	set @query = '
		select  emp_code as ''Employee Code'',
				emp_full_name as ''Employee Name'',
				branch ''Branch'',
				grade_name as ''Grade'',
				desig_name as ''Designation'',
				dept_name as ''Department'',
				REPLACE(CONVERT(VARCHAR(11),Doj,105),'' '',''/'') as ''DOJ'',
				Gender, 
				subvertical_name as ''Sub Vertical'',
				Obj_Status as ''Status'',
				REPLACE(CONVERT(VARCHAR(11),Submissiondate,105),'' '',''/'') as ''Submission Date'',
				first_levelcode as ''Emp_Sup_1 Code'',
				first_levelName as ''Emp_Sup_1 Name'',
				isnull(second_levelcode,'''') as ''Emp_Sup_2 Code'',
				isnull(second_levelName,'''') as ''Emp_Sup_2 Name'',
				isnull(third_levelcode,'''') as ''Emp_Sup_3 Code'',
				isnull(third_levelName,'''') as ''Emp_Sup_3 Name'',
				isnull(fourth_levelcode,'''') as ''Emp_Sup_4 Code'',
				isnull(fourth_levelName,'''') as ''Emp_Sup_4 Name'',
				isnull(fifth_levelcode,'''') as ''Emp_Sup_5 Code'',
				isnull(fifth_levelName,'''') as ''Emp_Sup_5 Name''
							
		from #final	'
	
	exec (@query + ' where ' + @condition)
	--print (@query + ' where ' + @condition)
	
	
	drop table #final
	
END

