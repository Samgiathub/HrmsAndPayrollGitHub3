
CREATE PROCEDURE [dbo].[KPMS_DASHBOARD_DETAILS]
	 @Privilege_ID AS numeric
	,@CMP_ID AS numeric
	,@Login_Id as numeric
	,@Type as numeric = 0
	,@From_Date		datetime = NULL
	,@To_Date 		datetime = NULL
	,@Branch_ID		numeric = 0
	,@Cat_ID 		numeric = 0
	,@Grd_ID 		numeric= 0
	,@Type_ID 		numeric= 0
	,@Dept_ID 		numeric= 0
	,@Desig_ID 		numeric= 0
	,@Emp_ID 		numeric= 0
	,@GoalSheet      numeric= 0
	,@constraint 	varchar(5000)= ''
	,@PBranch_ID	varchar(5000)= ''
	,@PVertical_ID	varchar(5000)= ''
	,@PSubVertical_ID	varchar(5000)= ''
	,@PDept_ID varchar(5000)='' 
	,@PCatID varchar(max)=''	
	,@PSalCycle varchar(max)=''	
	,@PBusinSgmt varchar(max)=''
	,@PSubBranch varchar(max)=''
	,@PBand varchar(max)=''		
	,@PEmpType varchar(max)=''	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	if isnull(@from_date,getdate()) = getdate()
		set @from_date = getdate()
	
	if isnull(@to_date,getdate()) = getdate()
		set @to_date = getdate()
	
	IF @Branch_ID = 0  
		set @Branch_ID = null
		
	IF @Cat_ID = 0  
		set @Cat_ID = null

	IF @Grd_ID = 0  
		set @Grd_ID = null

	IF @Type_ID = 0  
		set @Type_ID = null

	IF @Dept_ID = 0  
		set @Dept_ID = null

	IF @Desig_ID = 0  
		set @Desig_ID = null

	IF @Emp_ID = 0  
		set @Emp_ID = null
		
	IF @PBranch_ID = '0' or @PBranch_ID = ''
		set @PBranch_ID = null   	
	if @PVertical_ID ='0' or @PVertical_ID = ''		
		set @PVertical_ID = null
	if @PsubVertical_ID ='0' or @PsubVertical_ID = ''
		set @PsubVertical_ID = null
	
	IF @PDept_ID = '0' or @PDept_Id='' 
		set @PDept_ID = NULL	
		

	IF @PCatID = '0' or @PCatID='' 
		set @PCatID = NULL	

	IF @PSalCycle = '0' or @PSalCycle='' 
		set @PSalCycle = NULL

	IF @PBusinSgmt = '0' or @PBusinSgmt='' 
		set @PBusinSgmt = NULL

	IF @PSubBranch = '0' or @PSubBranch='' 
		set @PSubBranch = NULL

	IF @PBand = '0' or @PBand='' 
		set @PBand = NULL

	IF @PEmpType = '0' or @PEmpType='' 
		set @PEmpType = NULL

	if @PBranch_ID is null
	Begin	
		select   @PBranch_ID = COALESCE(@PBranch_ID + ',', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @PBranch_ID = @PBranch_ID + ',0';
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


if @PCatID is null  
 Begin 
 
  select   @PCatID = COALESCE(@PCatID + ',', '') + cast(Cat_ID as nvarchar(5))  from T0030_Category_Master WITH (NOLOCK) where cmp_ID=@Cmp_ID   
    
  If @PCatID IS NULL  
   set @PCatID = '0';  
  else  
   set @PCatID = @PCatID + ',0'  
 End  


 if @PBusinSgmt is null  
 Begin 
 
  select   @PBusinSgmt = COALESCE(@PBusinSgmt + ',', '') + cast(Segment_ID as nvarchar(5))  from T0040_Business_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PBusinSgmt IS NULL  
   set @PBusinSgmt = '0';  
  else  
   set @PBusinSgmt = @PBusinSgmt + ',0'  
 End  

 if @PSubBranch is null  
 Begin 
 
  select   @PSubBranch = COALESCE(@PSubBranch + ',', '') + cast(SubBranch_ID as nvarchar(5))  from T0050_SubBranch WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PSubBranch IS NULL  
   set @PSubBranch = '0';  
  else  
   set @PSubBranch = @PSubBranch + ',0'  
 End  


  if @PEmpType is null  
 Begin 
 
  select   @PEmpType = COALESCE(@PEmpType + ',', '') + cast(Type_ID as nvarchar(5))  from T0040_TYPE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID   
    
  If @PEmpType IS NULL  
   set @PEmpType = '0';  
  else  
   set @PEmpType = @PEmpType + ',0'  
 End  


  if @PBand is null  
 Begin 
 
  select   @PBand = COALESCE(@PBand + ',', '') + cast(BandId as nvarchar(5))  from tblBandMaster WITH (NOLOCK) where Cmp_Id=@Cmp_ID   
    
  If @PBand IS NULL  
   set @PBand = '0';  
  else  
   set @PBand = @PBand + ',0'  
 End  

 
  if @PSalCycle is null  
 Begin 
 
  select   @PSalCycle = COALESCE(@PSalCycle + ',', '') + cast(Tran_Id as nvarchar(5))  from T0040_Salary_Cycle_Master WITH (NOLOCK) where Cmp_id=@Cmp_ID   
    
  If @PSalCycle IS NULL  
   set @PSalCycle = '0';  
  else  
   set @PSalCycle = @PSalCycle + ',0'  
 End  

	Declare @Emp_Cons Table
	(
		Emp_ID	numeric,
		Vertical_ID numeric(18,0),  
		SubVertical_ID numeric(18,0),
		Dept_ID numeric(18,0),
		TargetVal int,
		Achievement int
	)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons(Emp_ID)
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#')

			select sum(Actual_Target) as [Target],sum(Achievement) as Ach, emp_id into #temp from KPMS_T0110_TargetAchivement where Cmp_Id = @CMP_ID and goal_setting_ID=@GoalSheet group by emp_id,goal_setting_ID
			update E set e.Achievement = T.Ach,E.TargetVal = T.Target,e.emp_id = t.emp_id from @emp_cons E inner join #temp T on E.emp_id = t.Emp_id
			update @emp_cons set Achievement = CASE WHEN Achievement IS NULL THEN cast('-' as varchar(10)) else Achievement end,TargetVal = CASE WHEN TargetVal IS NULL THEN cast('-' as varchar(10)) else TargetVal end 

			select * from @Emp_Cons
		end
	else
		begin
			Insert Into @Emp_Cons(Emp_ID,Vertical_ID,SubVertical_ID,Dept_ID) --,TargetVal,Achievement)

			select I.Emp_Id,I.Vertical_ID,I.SubVertical_ID,I.Dept_ID from T0095_Increment I WITH (NOLOCK) inner join  
					( select max(Increment_effective_Date) as For_Date , Emp_ID From T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date			
					---inner join KPMS_T0110_TargetAchivement as ktt on ktt.emp_id = Qry.Emp_ID
			Where I.Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and EXISTS (select Data from dbo.Split(@PBranch_ID, ',') PB Where cast(PB.data as numeric)=Isnull(I.Branch_ID,0))
			and EXISTS (select Data from dbo.Split(@PVertical_ID, ',') V Where cast(v.data as numeric)=Isnull(I.Vertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PsubVertical_ID, ',') S Where cast(S.data as numeric)=Isnull(I.SubVertical_ID,0))
			and EXISTS (select Data from dbo.Split(@PDept_ID, ',') D Where cast(D.data as numeric)=Isnull(I.Dept_ID,0)) 
			and EXISTS (select Data from dbo.Split(@PCatID, ',') C Where cast(C.data as numeric)=Isnull(I.Cat_ID,0)) 			  
			and EXISTS (select Data from dbo.Split(@PBusinSgmt, ',') BS Where cast(BS.data as numeric)=Isnull(I.Segment_ID,0)) 	  
			and EXISTS (select Data from dbo.Split(@PSubBranch, ',') SB Where cast(SB.data as numeric)=Isnull(I.subBranch_ID,0))  
			and EXISTS (select Data from dbo.Split(@PBand, ',') BM Where cast(BM.data as numeric)=Isnull(I.Band_Id,0)) 			  
			and EXISTS (select Data from dbo.Split(@PEmpType, ',') ET Where cast(ET.data as numeric)=Isnull(I.Type_ID,0)) 		  
			and EXISTS (select Data from dbo.Split(@PSalCycle, ',') SC Where cast(SC.data as numeric)=Isnull(I.SalDate_id,0)) 	  

			select sum(Actual_Target) as [Target],sum(Achievement) as Ach, emp_id into #temp2 from KPMS_T0110_TargetAchivement where Cmp_Id = @CMP_ID and goal_setting_ID=@GoalSheet group by emp_id,goal_setting_ID
			update E set e.Achievement = T.Ach,E.TargetVal = T.Target,e.emp_id = t.emp_id from @emp_cons E inner join #temp2 T on E.emp_id = t.Emp_id
			update @emp_cons set Achievement = CASE WHEN Achievement IS NULL THEN cast('-' as varchar(10)) else Achievement end,TargetVal = CASE WHEN TargetVal IS NULL THEN cast('-' as varchar(10)) else TargetVal end --from @emp_cons E 

			--select * from @emp_cons
		end

	if @Type = 0
		BEGIN		
			SELECT  ISNULL(CONVERT(NVARCHAR,PD.FROM_DATE,103),'-') as FROM_DATE,
			ISNULL(CONVERT(NVARCHAR,PD.PRIVILEGE_ID),'-') as PRIVILEGE_ID,LO.CMP_ID,LO.LOGIN_ID
			,EMP.EMP_FULL_NAME,EMP.ALPHA_EMP_CODE,ISNULL(PM.PRIVILEGE_NAME,'-') as PRIVILEGE_NAME,
				CASE CONVERT(NVARCHAR,PM.PRIVILEGE_TYPE)
				WHEN '0' THEN 'ADMIN USER'
				WHEN '1' THEN 'ESS USER'
				ELSE '-'
				END as PRIVILEGE_TYPE
				,Emp.Branch_ID,Emp.Grd_ID,Emp.Desig_Id,Emp.Dept_ID,Emp.Alpha_Emp_Code,LO.Is_HR,LO.Email_ID,LO.Is_Accou,LO.Email_ID_Accou,EMP.EMP_ID
				,EMP.Vertical_ID,EMP.SubVertical_ID
				FROM T0090_EMP_PRIVILEGE_DETAILS PD WITH (NOLOCK)
				RIGHT OUTER JOIN T0011_LOGIN LO WITH (NOLOCK) ON LO.LOGIN_ID = PD.LOGIN_ID
				INNER JOIN T0080_EMP_MASTER EMP WITH (NOLOCK) ON EMP.EMP_ID = LO.EMP_ID
				LEFT OUTER JOIN T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) ON PM.PRIVILEGE_ID = PD.PRIVILEGE_ID 
				WHERE (TRANS_ID IS NULL OR TRANS_ID = 
				(SELECT TOP 1 TRANS_ID FROM T0090_EMP_PRIVILEGE_DETAILS SPD WITH (NOLOCK) WHERE SPD.LOGIN_ID = LO.LOGIN_ID ORDER BY FROM_DATE DESC ))
				AND LO.CMP_ID = @CMP_ID and Emp.Emp_Left = 'N' and Emp.emp_id in (select emp_id from @Emp_Cons)
				ORDER BY RIGHT(REPLICATE(N' ', 500) + EMP.ALPHA_EMP_CODE, 500) 

				select Emp_ID,TargetVal,Achievement from  @Emp_Cons
				
		END
	Else if @Type = 1
		BEGIN
			SELECT ISNULL(CONVERT(NVARCHAR,PD.FROM_DATE,103),'-') as FROM_DATE,ISNULL(CONVERT(NVARCHAR,PD.PRIVILEGE_ID),'-') as PRIVILEGE_ID,LO.CMP_ID,LO.LOGIN_ID,EMP.EMP_FULL_NAME,EMP.ALPHA_EMP_CODE,ISNULL(PM.PRIVILEGE_NAME,'-') as PRIVILEGE_NAME,
				CASE CONVERT(NVARCHAR,PM.PRIVILEGE_TYPE)
				WHEN '0' THEN 'ADMIN USER'
				WHEN '1' THEN 'ESS USER'
				ELSE '-'
				END as PRIVILEGE_TYPE
				,Emp.Branch_ID,Emp.Grd_ID,Emp.Desig_Id,Emp.Dept_ID,Emp.Alpha_Emp_Code,LO.Is_HR,LO.Email_ID,LO.Is_Accou,LO.Email_ID_Accou,EMP.EMP_ID
				,EMP.Vertical_ID,EMP.SubVertical_ID   --Added By Jaina 24-09-2015
				FROM T0090_EMP_PRIVILEGE_DETAILS PD WITH (NOLOCK)
				RIGHT OUTER JOIN T0011_LOGIN LO WITH (NOLOCK) ON LO.LOGIN_ID = PD.LOGIN_ID
				INNER JOIN T0080_EMP_MASTER EMP WITH (NOLOCK) ON EMP.EMP_ID = LO.EMP_ID
				LEFT OUTER JOIN T0020_PRIVILEGE_MASTER PM WITH (NOLOCK) ON PM.PRIVILEGE_ID = PD.PRIVILEGE_ID 
				WHERE LO.CMP_ID = @CMP_ID and Emp.Emp_Left = 'N' and Emp.emp_id in (select emp_id from @Emp_Cons)
				--ORDER BY EMP.ALPHA_EMP_CODE,FROM_DATE
				ORDER BY RIGHT(REPLICATE(N' ', 500) + EMP.ALPHA_EMP_CODE, 500) 
				
		END

		

RETURN