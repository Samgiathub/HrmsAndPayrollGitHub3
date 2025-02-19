


--Created By Girish On 07-AUG-2009
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Get_Asset_Current_position]
 @Cmp_ID		numeric
,@Branch_ID		numeric   = 0
,@Cat_ID		numeric  = 0
,@Grd_ID		numeric = 0
,@Type_ID		numeric  = 0
,@Dept_ID		numeric  = 0
,@Desig_ID		numeric = 0
,@Emp_ID		numeric  = 0
,@Constraint	varchar(MAX) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	CREATE table #Temp_report_Label
	(
	Row_ID  numeric(18, 0) NOt null,
	Label_Name  varchar(200) not null,
	)
	CREATE table #Temp_Salary_Muster_Report		
	(
	Emp_ID numeric(18, 0) Not Null,
	Cmp_ID numeric(18, 0) Not Null,
	Label_Name varchar(200) Not Null,
	Yes_No varchar(10) ,
	Value_String varchar(250) Not Null,
	Row_id numeric(18, 0) Null
	)
		
	if @Branch_ID = 0
		set @Branch_ID = null
	if @Cat_ID = 0
		set @Cat_ID = null
		 
	if @Type_ID = 0
		set @Type_ID = null
	if @Dept_ID = 0
		set @Dept_ID = null
	if @Grd_ID = 0
		set @Grd_ID = null
	if @Emp_ID = 0
		set @Emp_ID = null
		
	If @Desig_ID = 0
		set @Desig_ID = null
		
	Declare @Label_Name varchar(50)
	DEclare @Row_ID numeric(18,0)
	Declare @Asset_Name	 varchar(50)
	  
	EXEC Get_Asset_Current_Lable @Cmp_ID
	
	
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			Insert Into @Emp_Cons

			select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK)
					--where Increment_Effective_date <= @To_Date
					Where Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(I.Cat_ID,0) = Isnull(@Cat_ID ,Isnull(I.Cat_ID,0))
			and I.Branch_ID = isnull(@Branch_ID ,I.Branch_ID)
			and I.Grd_ID = isnull(@Grd_ID ,I.Grd_ID)
			and isnull(I.Dept_ID,0) = isnull(@Dept_ID ,isnull(I.Dept_ID,0))
			and Isnull(I.Type_ID,0) = isnull(@Type_ID ,Isnull(I.Type_ID,0))
			and Isnull(I.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I.Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			--and Date_of_Join >=@From_Date and Date_OF_Join <=@to_Date
		end
	
	DECLARE CUR_EMP CURSOR FOR
	SELECT EMP_ID  FROM  @Emp_Cons 
		OPEN  CUR_EMP
		FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		WHILE @@FETCH_STATUS = 0
			BEGIN
					set @Label_Name=''
					set @Row_ID=0
					Declare Cur_Label cursor for 
					SELECT Label_Name,Row_ID FROM #TEMP_REPORT_LABEL where Row_ID > 2
					open Cur_label
					fetch next from Cur_label into @Label_Name ,@Row_ID
					while @@fetch_Status = 0
						begin
							INSERT INTO #Temp_Salary_Muster_Report
							(Emp_ID, Cmp_ID,Label_Name,Yes_No,Value_String,Row_id)
							VALUES     (@Emp_ID, @Cmp_ID, @Label_Name,'No','',@Row_ID)
							fetch next from Cur_label into @Label_Name,@Row_ID
						end
					close Cur_Label
					deallocate Cur_Label
					
					--set @Label_Name  = ''
						declare Cur_Position   cursor for
						select Asset_Name from t0090_Emp_Asset_detail Ead WITH (NOLOCK) inner join t0040_asset_master am WITH (NOLOCK) on
						Ead.Asset_ID=am.Asset_ID where  Ead.Emp_ID = @Emp_ID and am.Cmp_ID=@Cmp_ID and Ead.Return_Date  is  null
					open Cur_Position
					fetch next from Cur_Position  into @Asset_Name
					while @@fetch_status = 0
						begin
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Asset_Name 
							UPDATE    #Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Value_String = '',Yes_No='Yes'
 							where   Label_Name = @Asset_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from Cur_Position  into @Asset_Name
						end
					close Cur_Position
					deallocate Cur_Position
					
					declare Cur_Asset_Return   cursor for
						select Asset_Name from t0090_Emp_Asset_detail Ead WITH (NOLOCK) inner join t0040_asset_master am WITH (NOLOCK) on
						Ead.Asset_ID=am.Asset_ID where  Ead.Emp_ID = @Emp_ID and am.Cmp_ID=@Cmp_ID and Ead.Return_Date  is not null
					open Cur_Asset_Return
					fetch next from Cur_Asset_Return  into @Asset_Name
					while @@fetch_status = 0
						begin
							print @Emp_id
							select @Row_ID = Row_ID from #Temp_report_label where Label_Name like @Asset_Name 
							UPDATE    #Temp_Salary_Muster_Report
 							SET              Emp_ID = @Emp_ID, Cmp_ID = @Cmp_ID, Value_String = '',Yes_No='Return'
 							where   Label_Name = @Asset_Name and Row_id = @row_Id                  
 									and Emp_ID = @Emp_ID  
							fetch next from Cur_Asset_Return  into @Asset_Name
						end
					close Cur_Asset_Return
					deallocate Cur_Asset_Return
					
			FETCH NEXT FROM CUR_EMP INTO @EMP_ID
		END
	Close Cur_Emp
	Deallocate Cur_emp	
	
	select #Temp_Salary_Muster_Report.* ,E.Date_of_Join,Emp_Full_Name, Emp_code, E.Dept_ID,dem.DEsig_Name,Dept_Name,Cmp_Name,Cmp_Address,bm.Branch_ID from #Temp_Salary_Muster_Report Inner join
		T0080_Emp_Master E WITH (NOLOCK) on #Temp_Salary_Muster_Report.Emp_Id = E.Emp_ID inner join
		( select I.Emp_Id ,Grd_ID,DEsig_ID ,Dept_ID,Branch_ID from t0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID, Emp_ID from t0095_Increment WITH (NOLOCK)
					--where Increment_Effective_date <= @To_Date
					Where Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_ID = Qry.Increment_ID )Inc_Qry on 
		E.Emp_ID = Inc_Qry.Emp_ID left outer join t0040_department_Master WITH (NOLOCK)
		on Inc_Qry.dept_ID = t0040_department_Master.Dept_ID left outer join
		t0040_Designation_master Dem WITH (NOLOCK) on  Inc_Qry.DEsig_ID = dem.DEsig_ID left outer join
		T0030_BRANCH_MASTER BM WITH (NOLOCK) on Inc_Qry.Branch_ID = BM.Branch_ID 
		 inner join t0010_company_master CM WITH (NOLOCK)  on E.cmp_id=CM.cmp_id
		order by #Temp_Salary_Muster_Report.Emp_ID
	
	RETURN








