

---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_EMP_FNF_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	,@Branch_ID		numeric   = 0
	,@Cat_ID		numeric  = 0
	,@Grd_ID		numeric = 0
	,@Type_ID		numeric  = 0
	,@Dept_ID		numeric  = 0
	,@Desig_ID		numeric = 0
	,@Emp_ID		numeric  = 0
	,@Constraint		varchar(max) =''
	,@Emp_Search int= 0				--Added By Gadriwala 28112013
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 06-10-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 06-10-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 06-10-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 06-10-2015
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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
	
	IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 06-10-2015
	set @PBranch_ID = null   	
	
if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 06-10-2015
	set @PVertical_ID = null

if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 06-10-2015
	set @PsubVertical_ID = null
	
IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 06-10-2015
	set @PDept_ID = NULL	 
	
	
		
--Added By Jaina 06-10-2015 Start		
	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0'
	End
	
	if @PVertical_ID is null
	Begin	
		select   @PVertical_ID = COALESCE(@PVertical_ID + ',', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
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
--Added By Jaina 06-10-2015 End
	
	if (@Dept_ID > 0)
		set @PDept_ID = cast(@Dept_ID as varchar);
	if (@Branch_ID > 0)
		set @PBranch_ID = CAST(@Branch_ID AS VARCHAR)
		
	begin

			SELECT   case @Emp_Search  --Added By Gadriwala 28112013
			when 0
				then cast( E.Alpha_Emp_Code as varchar) + ' - '+ E.Emp_Full_Name
			when 1
				then  cast( E.Alpha_Emp_Code as varchar) + ' - '+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 2
				then  cast( E.Alpha_Emp_Code as varchar)
			when 3
				then  e.Initial+SPACE(1)+ e.Emp_First_Name+SPACE(1)+e.Emp_Second_Name+SPACE(2)+e.Emp_Last_Name
			when 4
				then  e.Emp_First_Name + SPACE(1)+ e.Emp_Second_Name + SPACE(2)+ e.Emp_Last_Name + ' - ' + cast( E.Alpha_Emp_Code as varchar)	
			end as Emp_Full_Name,E.Emp_id,Dept_Name,Desig_Name,IS_Emp_FNF,Grd_Name,Branch_Name,Date_of_Join,le.left_Date,le.left_reason,I_Q.Branch_ID as Branch_id
				,E.Alpha_Emp_Code
			from T0080_EMP_MASTER E WITH (NOLOCK) inner join 
			T0100_left_emp le WITH (NOLOCK) ON E.emp_id = le.emp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,I.Vertical_ID,I.SubVertical_ID from T0095_Increment I  WITH (NOLOCK) inner join 
					( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 09/09/2014 for Same Date Increment
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id	 
				where Cmp_ID = @Cmp_ID) I_Q  --Changed by Hardik 09/09/2014 for Same Date Increment  'changed by Gadriwala Muslim 12012015
				on E.Emp_ID = I_Q.Emp_ID Left outer join
				
			T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id Left outer join
			T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
			T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID inner JOIN
			T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 
		--	where le.left_date >= @From_date and le.left_Date <= @To_Date and 
			Where E.cmp_id=@cmp_id 
		    --and I_Q.Branch_ID = isnull(@Branch_ID ,I_Q.Branch_ID)
			and I_Q.Grd_ID = isnull(@Grd_ID ,I_Q.Grd_ID)
			--and isnull(I_Q.Dept_ID,0) = isnull(@Dept_ID ,isnull(I_Q.Dept_ID,0))
			and Isnull(I_Q.Type_ID,0) = isnull(@Type_ID ,Isnull(I_Q.Type_ID,0))
			and Isnull(I_Q.Desig_ID,0) = isnull(@Desig_ID ,Isnull(I_Q.Desig_ID,0))
			and E.Emp_ID = isnull(@Emp_ID ,E.Emp_ID) 
			and isnull(is_EMp_FNF,0)= 0
			--Added By Jaina 6-10-2015 Start
			and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I_Q.Branch_ID,0))
			and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=isnull(I_Q.Vertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I_Q.SubVertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I_Q.Dept_ID,0)) 
			--Added By Jaina 6-10-2015 End
			and Left_Date <=@To_Date
			and le.Left_Reason <> 'Default Company Transfer'	/* Company transfer Employee Not Get in Employee FNF	--Ankit 08122015  */
			ORDER BY  --Added By Mukti Orderby clause 07/11/2014
			  Case @Emp_Search 
				When 3 Then
					e.Emp_First_Name
				When 4 Then
					e.Emp_First_Name
				Else
					Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
				When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
					Else e.Alpha_Emp_Code
				end
				
			end
	end
		
RETURN




