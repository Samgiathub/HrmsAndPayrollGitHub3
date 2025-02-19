

CREATE PROCEDURE [dbo].[SP_Rpt_Warning_Details]
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
	,@Constraint	varchar(MAX) = ''
	,@Format    varchar(500) = ''  --Added by Jaina 13-07-2018
	,@L_type	varchar(500) =''  --Added by Jaina 13-07-2018
AS
	SET NOCOUNT ON 
	

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

			select I.Emp_Id from T0095_Increment I  WITH (NOLOCK) inner join 
					( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date
			Where Cmp_ID = @Cmp_ID 
			and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
			and Branch_ID = isnull(@Branch_ID ,Branch_ID)
			and Grd_ID = isnull(@Grd_ID ,Grd_ID)
			and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
			and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
			and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
			and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
			and I.Emp_ID in 
				( select Emp_Id from
				(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
				where cmp_ID = @Cmp_ID   and  
				(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
				or ( @To_Date  >= join_Date  and @To_Date <= left_date )
				or Left_date is null and @To_Date >= Join_Date)
				or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
		end
		
	-- Changed By Gadriwala 21012014 - E.Emp_Code to E.Alpha_Emp_Code
	
		--Added by Jaina 16-07-2018 Start
		Declare @CardWise varchar(max) = null
		Declare @LevelWise varchar(max) = null
		if @Format = 'Card Wise'
		BEGIN
			if @L_type = 'Yellow'
				set @CardWise = 'Yellow Card'
			else if @L_type = 'Red'
				set @CardWise = 'Red Card'
			else 
				set @CardWise = null	
		end
		
		IF @Format = 'Stage Wise'
		BEGIN
			if @L_type = '1'
				set @LevelWise ='Stage 1'
			else if @L_type = '2'
				set @LevelWise ='Stage 2'
			else if @L_type = '3'
				set @LevelWise ='Stage 3'
			else
				set @LevelWise = NULL
		end	
		--Added by Jaina 16-07-2018 End
		
		
	
		select I_Q.* , E.Alpha_Emp_Code,E.Emp_Full_Name as Emp_Full_Name,Wd.Warr_Date,CM.Cmp_Name,CM.Cmp_Address,WM.War_name,WD.Authorised_By,Wd.Issue_By,WD.Warr_Reason
					,Dept_Name,Desig_Name,Type_Name,Grd_Name,Branch_Name,Date_of_Join,Gender,Branch_Address,Comp_Name
					,@From_Date as From_Date,@To_Date as To_Date   --added by jimit 03102016
					,WC.Level_Name,WD.No_Of_Card,WD.Card_Color,WD.Action_Taken_Date,WD.Action_Detail
		from T0080_EMP_MASTER E  WITH (NOLOCK) inner join 
		     T0100_Warning_Detail WD  WITH (NOLOCK) on E.Emp_ID =WD.Emp_Id and @To_Date >= Warr_Date  and  @From_Date <= Warr_Date inner join --added by Gadriwala 12022014
		     T0010_Company_master CM  WITH (NOLOCK) on E.Cmp_ID =Cm.Cmp_ID inner join
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID from T0095_Increment I  WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK) 
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM   WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM   WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM   WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM   WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id INNER JOIN 
					T0040_warning_Master WM   WITH (NOLOCK) on Wd.War_ID = WM.War_ID inner join
					T0040_Warning_CardMapping WC   WITH (NOLOCK) ON WC.Level_Id = WM.Level_Id and WC.Cmp_id = E.Cmp_Id  inner JOIN  --Added by Jaina 13-07-2018
					T0030_BRANCH_MASTER BM   WITH (NOLOCK) ON I_Q.BRANCH_ID = BM.BRANCH_ID 	
		WHERE E.Cmp_ID = @Cmp_Id	
				And E.Emp_ID in (select Emp_ID From @Emp_Cons) 
				and WC.Card_Color = isnull(@CardWise,WC.Card_Color)  --Added by Jaina 16-07-2018
				and WC.Level_Name = ISNULL(@LevelWise, WC.Level_Name) --Added by Jaina 16-07-2018
				--order by E.Emp_ID asc
		
		
		
	RETURN




