

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
create PROCEDURE [dbo].[SP_LEAVE_CF_GET_bkAswini_08/01/2024]
	@Cmp_ID 		numeric
	,@From_Date		datetime
	,@To_Date 		datetime
	,@Branch_ID		numeric   
	,@Grd_ID		numeric 
	,@Emp_ID 		numeric
	,@Leave_ID      numeric 
	,@PBranch_ID	varchar(max)= '' --Added By Jaina 24-09-2015
	,@PVertical_ID	varchar(max)= '' --Added By Jaina 24-09-2015
	,@PSubVertical_ID	varchar(max)= '' --Added By Jaina 24-09-2015
	,@PDept_ID varchar(max)=''  --Added By Jaina 24-09-2015
	
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN

if @Branch_ID = 0 
	set @Branch_ID=NULL
	
if @Grd_ID =0
	set @Grd_ID=NULL

if @Emp_ID =0	
	set @Emp_ID=NULL
	
IF @PBranch_ID = '0' or @PBranch_ID='' --Added By Jaina 25-09-2015
	set @PBranch_ID = null   	
	
if @PVertical_ID ='0' or @PVertical_ID = ''		--Added By Jaina 25-09-2015
	set @PVertical_ID = null

if @PsubVertical_ID ='0' or @PsubVertical_ID = ''	--Added By Jaina 25-09-2015
	set @PsubVertical_ID = null
	
IF @PDept_ID = '0' or @PDept_Id=''  --Added By Jaina 25-09-2015
	set @PDept_ID = NULL	 
		
--Added By Jaina 25-09-2015 Start		
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
--Added By Jaina 25-09-2015 End
	
--declare @strWhr as nvarchar(1000)
--declare @strQry as nvarchar(4000)

--	set	@strWhr = ' Where em.Cmp_ID = ' + cast(@Cmp_ID as varchar(5))
	
--if @Emp_ID <> 0
--	set	@strWhr = @strWhr + ' and em.Emp_ID = ' + cast(@Emp_ID as varchar(5)) +' and (Emp_Left = ''N'' or (Emp_Left = ''Y'' and Convert(varchar(10),Emp_Left_Date,120) >= Convert(varchar(10),GetDate(),120)))'
--else
--	Begin
		--Added By Jaina 25-09-2015 Start
		CREATE TABLE #Emp_Cons -- Ankit 08092014 for Same Date Increment
		(      
			Emp_ID NUMERIC ,     
			Branch_ID NUMERIC,
			Increment_ID NUMERIC    
		)  
		
		EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID=@Cmp_ID,@FROM_Date=@FROM_Date,@To_Date=@To_Date,@Branch_ID=@Branch_ID,@Cat_ID=0,@Grd_ID=@Grd_ID,@Type_ID=0,
			@Dept_ID=0,@Desig_ID=0,@Emp_ID=@Emp_ID,@Constraint='',@Sal_Type=0,@Salary_Cycle_ID=0,@Segment_ID=0,
			@Vertical_Id=0,@SubVertical_Id = 0,@SubBranch_Id=0,@New_Join_emp=0,@Left_Emp=0,@SalScyle_Flag=2

		--INSERT INTO #Emp_Cons(Emp_ID,Branch_Id)

		--	SELECT I2.Emp_Id,I2.Branch_ID 		
		--	FROM   dbo.T0080_EMP_MASTER AS e INNER JOIN
		--		 (SELECT	MAX(I2.Increment_ID) AS Increment_ID, I2.Emp_ID,I2.Vertical_ID,I2.SubVertical_ID,I2.Branch_ID,I2.Dept_ID
		--		  FROM	T0095_INCREMENT I2 
		--				INNER JOIN (SELECT	MAX(INCREMENT_EFFECTIVE_DATE) AS INCREMENT_EFFECTIVE_DATE, I3.EMP_ID
		--							FROM	T0095_INCREMENT I3 
		--							WHERE	I3.Increment_Effective_Date <= GETDATE()
		--							GROUP BY I3.Emp_ID
		--							) I3 ON I2.Increment_Effective_Date=I3.INCREMENT_EFFECTIVE_DATE AND I2.Emp_ID=I3.Emp_ID																		
				 
		--		  GROUP BY I2.Emp_ID,I2.Vertical_ID,I2.SubVertical_ID,I2.Branch_ID,I2.Dept_ID
		--		) I2 ON E.Emp_ID=I2.Emp_ID 
		--	WHERE e.Cmp_ID = @Cmp_Id 
		--		  and I2.Branch_ID = isnull(@Branch_Id , isnull(I2.Branch_ID,0))
		--		  and e.Grd_ID = ISNULL(@Grd_Id, isnull(e.Grd_ID,0))
		--		  and e.Emp_ID = ISNULL(@Emp_Id, isnull(e.Emp_ID,0))
		--		  and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I2.Branch_ID,0))
		--		  and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I2.Vertical_ID,0))
		--		  and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I2.SubVertical_ID,0))
		--		  and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I2.Dept_ID,0)) 
		--		  and (E.Emp_Left = 'N' OR (Emp_Left = 'Y' and Emp_Left_Date >= GetDate()))
					  				  
					
	--set	@strWhr = @strWhr + ' and em.Emp_ID in (Select Emp_ID from #Emp_Cons Where em.Cmp_ID = ' + cast(@Cmp_ID as varchar(5)) +' and (Emp_Left = ''N'' or (Emp_Left = ''Y'' and Emp_Left_Date >= GetDate())))'
	
		--Added By Jaina 25-09-2015 End
--	End
--if @Branch_ID <> 0
--begin
--	--if @strWhr = '' 	
--	--	set	@strWhr = ' Where Branch_ID = ' + cast(@Branch_ID as varchar(5))	
--	--else
--		set	@strWhr = @strWhr + ' and Branch_ID = ' + cast(@Branch_ID as varchar(5))	
--end

--if @Grd_ID <> 0
--begin
--	--if @strWhr = '' 	
--	--	set	@strWhr = ' Where Grd_ID = ' + cast(@Grd_ID as varchar(5))	
--	--else
--		set	@strWhr = @strWhr + ' and Grd_ID = ' + cast(@Grd_ID as varchar(5))	
--end

 
	--set @strQry = 'select cast(Emp_Code as varchar(15)) +'' -''+ Emp_full_name as Emp_Full_Name,em.Emp_ID, lc.* from T0080_Emp_Master em
	--left outer join (select Leave_CF_ID,CF_LEAVE_Days,CF_P_DAYS,cf_type,Leave_ID,Emp_ID From t0100_leave_cf_detail where cf_from_date ='''+ cast(@From_Date as varchar(30)) +''' and cf_to_date = '''+ cast(@To_Date as varchar(30)) +''' and Leave_ID = '+ cast(@Leave_ID as varchar(5)) +') lc 
	--on  em.Emp_ID=lc.Emp_ID' + @strWhr + ' order by em.Emp_Code'
	
	--Comment by Jaina 16-11-2016
	--set @strQry = 'select cast(Alpha_Emp_Code as varchar(15)) +'' -''+ Emp_full_name as Emp_Full_Name,em.Emp_ID,lc.*
	--				 from T0080_Emp_Master em left outer join (select Leave_CF_ID,cast(CF_LEAVE_Days as numeric(18,2)) as CF_LEAVE_Days,case when CF_Type = ''COMP'' then 0 else CF_P_DAYS end as CF_P_DAYS,CF_Type,Leave_ID,Emp_ID 
	--				From t0100_leave_cf_detail where month(cf_for_date) = '''+ cast(month(@From_Date) as varchar) +''' and year(cf_for_date) = '''+ cast(year(@To_Date) as varchar) +''' and Leave_ID = '+ cast(@Leave_ID as varchar(5)) +') lc 
	--				on  em.Emp_ID=lc.Emp_ID' + @strWhr + ' order by em.Emp_Code'
	
	--Added by Jaina 16-11-2016
	 select cast(Alpha_Emp_Code as varchar(15)) +' -'+ Emp_full_name as Emp_Full_Name,em.Emp_ID,lc.*
	 from T0080_Emp_Master em WITH (NOLOCK) inner JOIN
	 #Emp_Cons E ON E.Emp_ID = em.Emp_ID 
	 left outer join 
	 (
		select Leave_CF_ID,cast(CF_LEAVE_Days as numeric(18,2)) as CF_LEAVE_Days,
			 case when CF_Type = 'COMP' then 0 else CF_P_DAYS end as CF_P_DAYS,
			 CF_Type,Leave_ID,Emp_ID        
		From t0100_leave_cf_detail WITH (NOLOCK)
		where month(cf_for_date) = month(@From_Date)
			 and year(cf_for_date) = year(@To_Date) 
			and Leave_ID = @Leave_ID
	 ) lc  on  em.Emp_ID=lc.Emp_ID 
	 Where em.Cmp_ID = @Cmp_Id 
	  
	 order by em.Emp_Code
	 
	 
--select @strQry
--exec (@strQry)


END



