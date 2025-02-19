

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_Frequently_AD_Import]
	 @Cmp_ID 		numeric
	,@From_Date 	datetime
	,@To_Date 		datetime
	,@Branch_ID 	numeric
	,@Cat_ID 		numeric 
	,@Grd_ID 		numeric
	,@Type_ID 		numeric
	,@Dept_ID 		numeric
	,@Desig_ID 		numeric
	,@Emp_ID 		numeric
	,@constraint 	varchar(MAX)
	,@AD_ID			numeric = 0
	,@PBranch_ID	varchar(MAX) = '0'
	,@Salary_Cycle_id numeric = NULL
    ,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 21082013
    ,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013
    ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 21082013	
    ,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 21082013	
	,@Show_Hidden_Allowance  bit = 1   --Added by Jaina 11-05-2017            
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON	
 
	set @Show_Hidden_Allowance = 0
	 
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

	IF @AD_ID = 0
		set @AD_ID = null
		
	IF @Salary_Cycle_id = 0	 -- Added By Gadriwala Muslim 21082013
	set @Salary_Cycle_id = null	
	If @Segment_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Segment_Id = null
	If @Vertical_Id = 0		 -- Added By Gadriwala Muslim 21082013
	set @Vertical_Id = null
	If @SubVertical_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubVertical_Id = null	
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 21082013
	set @SubBranch_Id = null	
	
	CREATE TABLE #Emp_Cons -- Ankit 06092014 for Same Date Increment
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	  EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,0,0 ,0,0,0,0,0,0,2,@PBranch_ID 
	
	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	Declare @Emp_AD_Total Table
	(
		
		Emp_Code varchar(100),
		Emp_Full_Name varchar(100),
		AD_MOnth numeric,
		AD_Year  numeric,
		AD_Name  varchar(50),
		M_AD_Amount numeric,
		Cmp_Name  Varchar(100),
		Cmp_Address	Varchar(max),
		Comp_Name VARCHAR(MAX),
		Branch_Address VARCHAR(max)
	)
	
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
	--			begin
	--				Insert Into #Emp_Cons

	--				select I.Emp_Id from T0095_Increment I inner join 
	--						( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
									
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				--and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Branch_ID in (select cast(ISNULL(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--                and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
	
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
	--		else
	--			begin
						
	--				Insert Into #Emp_Cons

	--				select I.Emp_Id from T0095_Increment I inner join 
	--						( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--						where Increment_Effective_date <= @To_Date
	--						and Cmp_ID = @Cmp_ID
	--						group by emp_ID  ) Qry on
	--						I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
									
	--				Where Cmp_ID = @Cmp_ID 
	--				and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--				and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--				and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--				and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--				and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--				and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--				and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--				and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 21082013
	--			    and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 21082013
	--                and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 21082013
	
	--				and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--				and I.Emp_ID in 
	--					( select Emp_Id from
	--					(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--					where cmp_ID = @Cmp_ID   and  
	--					(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--					or Left_date is null and @To_Date >= Join_Date)
	--					or @To_Date >= left_date  and  @From_Date <= left_date ) 
	--			end
			
			
	--	end
		 

	insert into @Emp_AD_Total(Emp_Code,Emp_Full_Name,AD_Month,AD_Year,AD_Name,M_AD_Amount,Cmp_Name,Cmp_Address,Comp_Name,Branch_Address)
	Select E.Alpha_Emp_Code,Emp_Full_Name,Month(MAD.For_Date) as AD_Month, Year(MAD.For_Date) as AD_Year,AD_Name,MAD.M_AD_Amount + ISNULL(MAD.M_AREAR_AMOUNT,0)
			,cm.Cmp_Name,cm.Cmp_Address,BM.Comp_Name,BM.Branch_Address
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join 
			  T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
		T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN 
			#Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join 
			( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join 
					( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)
					where Increment_Effective_date <= @To_Date
					and Cmp_ID = @Cmp_ID
					group by emp_ID  ) Qry on
					I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID	 ) I_Q 
				on E.Emp_ID = I_Q.Emp_ID  inner join
					T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN
					T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN
					T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN
					T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join 
					T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  Inner join
					T0010_company_Master cm WITH (NOLOCK) on MAD.Cmp_ID = cm.cmp_ID 
					
		WHERE E.Cmp_ID = @Cmp_Id	 and For_date >=@From_Date and For_date <=@To_Date
				and  mad.AD_ID = isnull(@AD_ID,Mad.AD_ID) And ADM.AD_NOT_EFFECT_SALARY=1  and M_Ad_Amount <> 0
				AND (CASE WHEN @SHOW_HIDDEN_ALLOWANCE = 0  AND  ADM.HIDE_IN_REPORTS = 1 THEN 0 ELSE 1 END )=1  --CHANGE BY JAINA 15-05-2017

				select * from @Emp_AD_Total order by Emp_Code ,AD_Month
	
	RETURN 




