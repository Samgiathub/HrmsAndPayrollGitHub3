
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_EMP_TERMINATE_RECORD_GET]
	 @Cmp_ID		numeric
	,@From_Date		datetime
	,@To_Date		datetime 
	--,@Branch_ID		numeric   = 0
	--,@Cat_ID		numeric  = 0
	--,@Grd_ID		numeric = 0
	--,@Type_ID		numeric  = 0
	--,@Dept_ID		numeric  = 0
	--,@Desig_ID		numeric = 0
	,@Branch_ID		varchar(max) = ''
	,@Cat_ID		varchar(max) = ''
	,@Grd_ID		varchar(max) = ''
	,@Type_ID		varchar(max) = ''
	,@Dept_ID		varchar(max) = ''
	,@Desig_ID		varchar(max) = ''
	,@Emp_ID		numeric  = 0
	,@Constraint	varchar(MAX) = ''
	,@New_Join_emp	numeric = 0 
	,@Left_Emp		Numeric = 0
	,@Vertical_Id varchar(max)=''  --Added By Jaina 5-10-2015
	,@SubVertical_Id varchar(max)='' --Added By Jaina 5-10-2015
	
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if @Branch_ID = '' or @Branch_ID = '0'
		set @Branch_ID = null
	if @Cat_ID = '' or @Cat_ID = '0'
		set @Cat_ID = null
		 
	if @Type_ID = '' or @Type_ID = '0'
		set @Type_ID = null
	if @Dept_ID = '' or @Dept_ID = '0'
		set @Dept_ID = null
	if @Grd_ID = '' or @Grd_ID = '0'
		set @Grd_ID = null
	if @Emp_ID = 0 
		set @Emp_ID = null
		
	If @Desig_ID = '' or @Desig_ID = '0'
		set @Desig_ID = null
	
	--added jimit 27112015
	If @Vertical_Id = '' or @Vertical_Id = '0'
		set @Vertical_Id = null
	
	If @SubVertical_Id = '' or @SubVertical_Id = '0'
		set @SubVertical_Id = null		
	
	if @Branch_ID is null
	Begin	
		select   @Branch_ID = COALESCE(@Branch_ID + '#', '') + cast(Branch_ID as nvarchar(5))  from T0030_BRANCH_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		set @Branch_ID = @Branch_ID + '#0'		
	End
	if @Cat_ID is null
	Begin	
		select   @Cat_ID = COALESCE(@Cat_ID + '#', '') + cast(Cat_ID as nvarchar(5))  from T0030_CATEGORY_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		if @Cat_ID is null
			set @Cat_ID = '0';
		else
			set @Cat_ID = @Cat_ID + '#0'
	End
	
	if @Type_ID is null
	Begin	
		select   @Type_ID = COALESCE(@Type_ID + '#', '') + cast(Type_ID as nvarchar(5))  from T0040_TYPE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		if @Type_ID is null
			set @Type_ID = '0';
		else
			set @Type_ID = @Type_ID + '#0'
	End
	IF @Dept_ID is null
	Begin
		select   @Dept_ID = COALESCE(@Dept_ID + '#', '') + cast(Dept_ID as nvarchar(5))  from T0040_DEPARTMENT_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 		
		
		if @Dept_ID is null
			set @Dept_ID = '0';
		else
			set @Dept_ID = @Dept_ID + '#0'
	End
	
	if @Grd_ID is null
	Begin	
		select   @Grd_ID = COALESCE(@Grd_ID + '#', '') + cast(Grd_ID as nvarchar(5))  from T0040_GRADE_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		if @Grd_ID is null
			set @Grd_ID = '0';
		else
			set @Grd_ID = @Grd_ID + '#0'
	End
	
		
	
	if @Desig_ID is null
	Begin	
		select   @Desig_ID = COALESCE(@Desig_ID + '#', '') + cast(Desig_ID as nvarchar(5))  from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		if @Desig_ID is null
			set @Desig_ID = '0';
		else
			set @Desig_ID = @Desig_ID + '#0'
	End
	
	if @Vertical_ID is null
	Begin	
		select   @Vertical_ID = COALESCE(@Vertical_ID + '#', '') + cast(Vertical_ID as nvarchar(5))  from T0040_Vertical_Segment WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @Vertical_ID IS NULL
			set @Vertical_ID = '0';
		else
			set @Vertical_ID = @Vertical_ID + '#0'		
	End
	if @subVertical_ID is null
	Begin	
		select   @subVertical_ID = COALESCE(@subVertical_ID + '#', '') + cast(subVertical_ID as nvarchar(5))  from T0050_SubVertical WITH (NOLOCK) where Cmp_ID=@Cmp_ID 
		
		If @subVertical_ID IS NULL
			set @subVertical_ID = '0';
		else
			set @subVertical_ID = @subVertical_ID + '#0'
	End
	
	
	
	--ended
		
	
				select I_Q.* ,E.Emp_Full_Name , E.Emp_Code,E.Alpha_Emp_Code,E.Emp_First_Name,Left_Date,BM.Comp_Name,BM.Branch_Address,Left_Reason
								,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,@From_Date as From_Date ,@To_Date as To_Date
								,Cmp_Name,Cmp_Address,Present_Street,Present_State,Present_City,Present_Post_Box,l.left_reason
					from T0080_EMP_MASTER E WITH (NOLOCK) left outer join T0100_Left_Emp l WITH (NOLOCK) on E.Emp_ID =  l.Emp_ID inner join
						( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I WITH (NOLOCK) inner join 
								( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)	-- Ankit 10092014 for Same Date Increment
								where Increment_Effective_date <= @To_Date
								and Cmp_ID = @Cmp_ID
								-- Add By Paras 07-03-2013
								-- Comment by nilesh on 25092014 --Start
								--and Branch_ID = ISNULL(@Branch_ID,Branch_ID) 
								--and Grd_ID = ISNULL(@Grd_ID,Grd_ID)
								--and ISNULL(Dept_ID,0)= ISNULL(@Dept_ID,ISNULL(Dept_ID,0))
								--and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			                    -- and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			                    --and ISNULL(Cat_ID,0)= ISNULL(@Cat_ID,ISNULL(Cat_ID,0))
			                    -- Comment by nilesh on 25092014 --End
			                    -- Added by nilesh on 25092014 --Start
			                 --   and ISNULL(Cat_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Cat_ID,ISNULL(Cat_ID,0)),'#') ) 
				                --and ISNULL(Branch_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Branch_ID,ISNULL(Branch_ID,0)),'#') ) 
				                --and ISNULL(Grd_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Grd_ID,ISNULL(Grd_ID,0)),'#') ) 
				                --and ISNULL(Dept_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Dept_ID,ISNULL(Dept_ID,0)),'#') )
				                --and ISNULL(Type_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Type_ID,ISNULL(Type_ID,0)),'#') )  
				                --and ISNULL(Desig_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Desig_ID,ISNULL(Desig_ID,0)),'#') ) 
				                ---- Added by nilesh on 25092014 --End
				                --and ISNULL(Vertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@Vertical_Id,ISNULL(Vertical_Id,0)),'#') )   --Added By Jaina 5-10-2015
				                --and ISNULL(SubVertical_ID,0) in(SELECT  CAST(DATA  AS Numeric) FROM dbo.Split (ISNULL(@SubVertical_Id,ISNULL(SubVertical_ID,0)),'#') )  --Added By Jaina 5-10-2015
				                		                
			                    -- Add By Paras 07-03-2013			                   
								group by emp_ID  ) Qry on
								I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	
								
								where 
								 --added jimit 27112015
			                     EXISTS (select Data from dbo.Split(@Cat_ID, '#') C Where cast(C.data as numeric)=Isnull(Cat_ID,0))
								and EXISTS (select Data from dbo.Split(@Branch_ID, '#') B Where cast(B.data as numeric)=Isnull(Branch_ID,0))
								and EXISTS (select Data from dbo.Split(@Grd_ID, '#') G Where cast(G.data as numeric)=Isnull(Grd_ID,0))
								and EXISTS (select Data from dbo.Split(@Dept_ID, '#') D Where cast(D.data as numeric)=Isnull(Dept_ID,0)) 
								and EXISTS (select Data from dbo.Split(@Type_ID, '#') T Where cast(T.data as numeric)=Isnull([Type_ID],0))
								and EXISTS (select Data from dbo.Split(@Desig_ID, '#') e Where cast(e.data as numeric)=Isnull(Desig_ID,0))
								and EXISTS (select Data from dbo.Split(@Vertical_ID, '#') V Where cast(V.data as numeric)=Isnull(Vertical_ID,0))
								and EXISTS (select Data from dbo.Split(@subVertical_ID, '#') S Where cast(S.data as numeric)=Isnull(SubVertical_ID,0))
			                    --ended
			                    							
								 ) I_Q	-- Ankit 10092014 for Same Date Increment
							on E.Emp_ID = I_Q.Emp_ID  inner join
								T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
								T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
								T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
								T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
								T0030_BRANCH_MASTER BM WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID  Inner join 
								T0010_COMPANY_MASTER CM WITH (NOLOCK) ON E.CMP_ID = CM.CMP_ID
					WHERE E.Cmp_ID = @Cmp_Id And E.emp_ID in 
						(select Emp_ID from t0100_left_emp WITH (NOLOCK) where Left_Date >= @From_Date and Left_Date <= @To_Date and  Is_Terminate=1) 
					
					Order by Case When IsNumeric(e.Alpha_Emp_Code) = 1 then Right(Replicate('0',21) + e.Alpha_Emp_Code, 20)
			When IsNumeric(e.Alpha_Emp_Code) = 0 then Left(e.Alpha_Emp_Code + Replicate('',21), 20)
				Else e.Alpha_Emp_Code
			End
					--ORDER BY RIGHT(REPLICATE(N' ', 500) + E.ALPHA_EMP_CODE, 500) 		
		
		
	RETURN




