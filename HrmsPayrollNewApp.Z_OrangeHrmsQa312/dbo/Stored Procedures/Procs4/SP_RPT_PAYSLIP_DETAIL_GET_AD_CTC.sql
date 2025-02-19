

---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_DETAIL_GET_AD_CTC]
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
	,@constraint 	varchar(max)
	,@Sal_Type		numeric = 0
	,@Salary_Cycle_id numeric = 0    -- Added By Gadriwala Muslim 26072013   
	,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 26072013
	,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 26072013
    ,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 26072013
	,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	 
	,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

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
	
	--Added By Gadriwala on 26072013--------------
	if @Segment_Id = 0 
		set @Segment_Id = null
	IF @Vertical_Id= 0 
		set @Vertical_Id = null
	if @SubVertical_Id = 0 
	set @SubVertical_Id= Null
	-----------------------------------------------
	If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
		set @SubBranch_Id = null	
	
	CREATE TABLE #Emp_Cons 
	 (      
	   Emp_ID numeric ,     
	   Branch_ID numeric,
	   Increment_ID numeric    
	 )   
	 
	 EXEC SP_RPT_FILL_EMP_CONS  @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID ,@Emp_ID ,@constraint ,@Sal_Type ,@Salary_Cycle_id ,@Segment_Id ,@Vertical_Id ,@SubVertical_Id ,@SubBranch_Id 

	--Added by Nimesh 19 May 2015
	--Filtering Employee Record according to Salary Status
	IF (@Status = 'Hold' OR @Status = 'Done') BEGIN
		DELETE	FROM #Emp_Cons 
		WHERE	Emp_ID NOT IN ( 
								SELECT Emp_ID FROM T0200_MONTHLY_SALARY S WITH (NOLOCK)
								WHERE	Month(S.Month_End_Date)=Month(@To_Date) 
										AND Year(S.Month_End_Date)=Year(@To_Date) 
										AND S.Cmp_ID=@Cmp_ID 
										AND S.Salary_Status=@Status
							   )
	END
			
	--Declare #Emp_Cons Table
	--(
	--	Emp_ID	numeric
	--)
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
	--	end
	--else
	--	begin
			
			
	--		Insert Into #Emp_Cons

	--		select I.Emp_Id from T0095_Increment I inner join 
	--				( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment
	--				where Increment_Effective_date <= @To_Date
	--				and Cmp_ID = @Cmp_ID
	--				group by emp_ID  ) Qry on
	--				I.Emp_ID = Qry.Emp_ID	and I.Increment_effective_Date = Qry.For_Date	
							
	--		Where Cmp_ID = @Cmp_ID 
	--		and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))
	--		and Branch_ID = isnull(@Branch_ID ,Branch_ID)
	--		and Grd_ID = isnull(@Grd_ID ,Grd_ID)
	--		and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))
	--		and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))
	--		and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013       
	--		and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID) 
	--		and I.Emp_ID in 
	--			( select Emp_Id from
	--			(select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry
	--			where cmp_ID = @Cmp_ID   and  
	--			(( @From_Date  >= join_Date  and  @From_Date <= left_date ) 
	--			or ( @To_Date  >= join_Date  and @To_Date <= left_date )
	--			or Left_date is null and @To_Date >= Join_Date)
	--			or @To_Date >= left_date  and  @From_Date <= left_date ) 
			
	--	end
	 
	Declare @Sal_St_Date   Datetime    
	Declare @Sal_end_Date   Datetime  
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date 
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End    
       
	 if isnull(@Sal_St_Date,'') = ''    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
		begin    
		   set @From_Date  = @From_Date     
		   set @To_Date = @To_Date    
		end     
	 else  if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
		begin    
		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
		   set @From_Date = @Sal_St_Date
		   Set @To_Date = @Sal_end_Date   
		End
	 	 
	 CREATE table #Pay_slip 
		(
			Row_ID					numeric IDENTITY ,
			Emp_ID					numeric,
			Cmp_ID					numeric,
			AD_ID					numeric,
			Sal_Tran_ID				numeric,
			AD_Description			varchar(100),
			AD_Amount				numeric(18,2),
			AD_Actual_Amount		numeric(18,2),
			AD_Calculated_Amount	numeric(18,2),
			For_Date				Datetime,
			M_AD_Flag				char(1),
			Loan_ID					numeric,
			Def_ID					numeric 
		)	 
	
	
		
	if @Sal_Type = 0
		begin
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID
				--,Isnull(mad.m_AD_Amount,0) + Isnull(SETT_AMOUNT,0)
				,(Isnull(mad.m_AD_Amount,0) + Isnull(SETT_AMOUNT,0) + isnull(mad.M_AREAR_AMOUNT,0)+isnull(mad.M_AREAR_AMOUNT_Cutoff,0))   as m_AD_Amount  --Change by ronakk 06072023
				,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.To_date,mad.M_AD_Flag
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID inner JOIN
						T0050_AD_MASTER A WITH (NOLOCK) ON A.AD_ID=MAD.AD_ID and A.CMP_ID = MAD.Cmp_ID  ---Added by Jaina 07-04-2017
						LEFT OUTER JOIN --- Added Below query by Hardik 05/01/2021 for Cera
							(SELECT MSS.EMP_ID, SUM(MAD.M_AD_Amount) AS SETT_AMOUNT, MAD.AD_ID 
							FROM T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) INNER JOIN 
								T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MSS.S_Sal_Tran_ID = MAD.S_Sal_Tran_ID INNER JOIN
								#EMP_CONS EC ON MSS.EMP_ID = EC.EMP_ID
							WHERE MSS.CMP_ID=@Cmp_ID AND MSS.Effect_On_Salary=1 AND MSS.S_Eff_Date BETWEEN @From_Date AND @To_Date
							GROUP BY MSS.EMP_ID, MAD.AD_ID) SETT ON SETT.Emp_ID = MAD.Emp_ID And Sett.AD_ID = MAD.AD_ID
					WHERE MAD.Cmp_ID = @Cmp_Id  and Month(To_date) =Month(@To_Date) and Year(To_date) = Year(@To_Date) --For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 1 and M_AD_Flag ='I'	 and isnull(Sal_Type,0) =0	
						  and A.Hide_In_Reports = 0   --Added by Jaina 07-04-2017

		end
			
		--select * from #Pay_Slip
		Select MAD.*,AD_NAME,AD_SORT_NAME From #Pay_Slip  MAD  left outer  join T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID= AM.AD_ID 
		WHERE mad.Cmp_ID = @Cmp_Id	and Month(For_date) =Month(@To_Date) and Year(For_date) = Year(@To_Date) --For_date >=@From_Date and For_date <=@To_Date
			and MAD.AD_Amount > 0 or MAD.AD_Amount < 0 
		Order by mad.Emp_ID,Row_ID 
			
			
	 
	RETURN 




