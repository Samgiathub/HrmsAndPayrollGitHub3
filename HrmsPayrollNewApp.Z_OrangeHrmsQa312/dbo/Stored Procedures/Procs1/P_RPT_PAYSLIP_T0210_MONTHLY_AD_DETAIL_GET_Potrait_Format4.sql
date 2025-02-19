

-------------------------------------------
--Added jimit 24022016
--For BhgyaLakshmi(Kyrus) Showing All AD Detail and Inbuilt Ad When their Amount Is not 0

------------------------------------------
CREATE PROCEDURE [dbo].[P_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET_Potrait_Format4]        
 @Cmp_ID   numeric        
,@From_Date  datetime        
,@To_Date   datetime        
,@Branch_ID  numeric        
,@Cat_ID   numeric         
,@Grd_ID   numeric        
,@Type_ID   numeric        
,@Dept_ID   numeric        
,@Desig_ID   numeric        
,@Emp_ID   numeric        
,@constraint  varchar(MAX)        
,@Sal_Type  numeric =0        
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
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
  
 --Added By Gadriwala Muslim on 24072013
  if @Segment_Id = 0 
  set @Segment_Id = null
  IF @Vertical_Id= 0 
  set @Vertical_Id = null
  if @SubVertical_Id = 0 
  set @SubVertical_Id= Null
   If @SubBranch_Id = 0	 -- Added By Gadriwala Muslim 01082013
	set @SubBranch_Id = null	
	

Declare @With_Arear_Amount tinyint

Set @With_Arear_Amount = 0

--Hardik 03/06/2013 for With Arear Report for Golcha Group
If @Sal_Type = 3 
	Begin
		Set @With_Arear_Amount = 1
		Set @Sal_Type = 0
	End

CREATE table #Emp_Cons 
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
	
	--if @Constraint <> ''
	--	begin
	--		Insert Into #Emp_Cons
	--		Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
	--	end
	--else 
	--	Begin
	--		Insert Into #Emp_Cons      
	--		  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
	--		  cmp_id=@Cmp_ID 
	--		   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
	--	   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
	--	   and Grd_ID = isnull(@Grd_ID ,Grd_ID)      
	--	   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
	--	   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
	--	   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
	--		and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
	--		and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013       
	--	   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
	--		  and Increment_Effective_Date <= @To_Date 
	--		  and 
	--				  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
	--					or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
	--					or (Left_date is null and @To_Date >= Join_Date)      
	--					or (@To_Date >= left_date  and  @From_Date <= left_date )) 
	--					order by Emp_ID
						
	--			Delete From #Emp_Cons Where Increment_ID Not In
	--			(select TI.Increment_ID from t0095_increment TI inner join
	--			(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment
	--			Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
	--			on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
	--			Where Increment_effective_Date <= @to_date) 
	--	End	
        
 --Declare #Emp_Cons Table        
 --(        

 -- Emp_ID numeric        
 --)        
         
 --if @Constraint <> ''        
 -- begin        
 --  Insert Into #Emp_Cons        
 --  select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
 -- end        
 --else        
 -- begin        
           
           
 --  Insert Into #Emp_Cons        
        
 --  select I.Emp_Id from T0095_Increment I inner join         
 --    ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment        
 --    where Increment_Effective_date <= @To_Date        
 --    and Cmp_ID = @Cmp_ID        
 --    group by emp_ID  ) Qry on        
 --    I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date         
               
 --  Where Cmp_ID = @Cmp_ID         
 --  and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
 --  and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
 --  and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
 --  and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
 --  and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
 --  and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
 --   and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
 --  and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
 --  and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
 --   and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013     
 --  and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
 --  and I.Emp_ID in         
 --   ( select Emp_Id from        
 --   (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN) qry        
 --   where cmp_ID = @Cmp_ID   and          
 --   (( @From_Date  >= join_Date  and  @From_Date <= left_date )         
 --   or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
 --   or Left_date is null and @To_Date >= Join_Date)        
 --   or @To_Date >= left_date  and  @From_Date <= left_date )         
           
           
 -- end        

  Declare @Sal_St_Date   Datetime    
  Declare @Sal_end_Date   Datetime  
  declare @IS_ROUNDING AS NUMERIC(1,0)
  Declare @Round				NUMERIC  
  set @Round = 0
  
  declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0),
			@IS_ROUNDING = Isnull(AD_Rounding,1) -- Comment and added By rohit on 11022013
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0),
			@IS_ROUNDING = Isnull(AD_Rounding,1) -- Comment and added By rohit on 11022013
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
		End  
		
	if @Salary_Cycle_id > 0
		begin
			select @Sal_St_Date = Salary_st_date from T0040_Salary_Cycle_Master WITH (NOLOCK) where Tran_Id = @Salary_Cycle_id
		end  
       
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
 else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	begin    
	    -- Comment and added By rohit on 11022013
	   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	   --set @From_Date = @Sal_St_Date
	   --Set @To_Date = @Sal_end_Date   
	   if @manual_salary_Period =0 
			Begin
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period WITH (NOLOCK) where month= month(@From_Date) and YEAR=year(@From_Date)							   
			     Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date    
			End	   
		-- Ended By rohit on 11022013	
	End 
	
	
          
 CREATE table #Pay_slip         
  (        
   Emp_ID     numeric,        
   Cmp_ID     numeric,        
   AD_ID     numeric,        
   Sal_Tran_ID    numeric,        
   AD_Description   varchar(100),        
   AD_Amount    numeric(18,2),        
   AD_Actual_Amount  numeric(18,5),        
   AD_Calculated_Amount numeric(18,2),        
   For_Date    Datetime,        
   M_AD_Flag    char(1),        
   Loan_Id     numeric,        
   Def_ID     numeric ,
   M_Arrear_Days  numeric(18,2) default 0,
   YTD numeric(18,2),     --Ankit 10102013
   S_Sal_Tran_ID    numeric NULL	--Added By Ankit For Twise Settlement	--05122015
   
  )          
        
        
        
 if @Sal_Type =3        
  set  @Sal_Type =null        
 
 --Ankit 10102013--YTD Column Get Finacial Year Date--- 
    Declare @F_StartDate datetime
    Declare @F_EndDate Datetime

	SET @F_StartDate = DATEADD(dd,0, DATEDIFF(dd,0, DATEADD( mm, -(((12 + DATEPART(m, @To_Date)) - 4)%12), @To_Date ) - datePart(d,DATEADD( mm, -(((12 + DATEPART(m, @To_Date)) - 4)%12),@To_Date ))+1 ) )

	IF day(@Sal_St_Date) <> 1
		Begin
			set @F_StartDate =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@F_StartDate)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@F_StartDate) )as varchar(10)) as smalldatetime)    
		End
	
	SET @F_EndDate = DATEADD(SS,-1,DATEADD(mm,12,@F_StartDate))
  --Ankit 10102013--YTD Column Get Finacial Year Date--- 
           
         
 If @Sal_Type  =1         
  Begin        
 
   
 
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID)        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0)) + sum(isnull(M_AREAR_AMOUNT_cutoff,0)),S_Sal_Tran_ID
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
       and M_AD_NOT_EFFECT_SALARY = 0       
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >=0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_Date ,mad.M_AD_Flag  ,MAD.S_Sal_Tran_ID  
   
    
    
         Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID)
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.ReimAmount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.to_Date,mad.M_AD_Flag,0 ,S_Sal_Tran_ID       
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK)INNER  JOIN         
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
			   and (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1)      and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_Date, mad.M_AD_Flag, mad.Sal_Tran_ID  ,MAD.S_Sal_Tran_ID         
              
   -------COMMENT BY NILAY: 21082014------                
   --Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   --Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0)) +sum(isnull(M_AREAR_AMOUNT_cutoff,0))          
   --  From T0210_MONTHLY_AD_DETAIL  MAD INNER  JOIN         
   --  #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
   -- WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date          
   --    and M_AD_NOT_EFFECT_SALARY = 0          
   --    and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0        
   -- Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag        
  -------COMMENT BY NILAY: 21082014------                  
    
    
 ---YTD Column-- Ankit 10102013---
   
   Update #Pay_slip Set YTD = M_AD_Amount From
     (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
		From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
    WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
       and M_AD_NOT_EFFECT_SALARY = 0  
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage =0         
    Group by Mad.Emp_ID,mad.AD_ID) Qry
    Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
 
   Update #Pay_slip Set YTD = M_AD_Amount From
     (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
		From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
    WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
       and M_AD_NOT_EFFECT_SALARY = 0 
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0         
    Group by Mad.Emp_ID,mad.AD_ID) Qry
    Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID

    Update #Pay_slip Set YTD = M_AD_Amount From						----YTD For Reimbersment Allowance
     (Select Ad_Id, Mad.Emp_ID,sum(mad.ReimAmount) as M_AD_Amount 
		From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
    WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
       and M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1    and Sal_Tran_ID is not null  
       and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) 
    Group by Mad.Emp_ID,mad.AD_ID) Qry
    Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
    
 ---YTD Column-- Ankit 10102013---
    
    
  End        
  
 Else        

  Begin  
        	
	If @With_Arear_Amount = 0  
		Begin
	
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0)) + sum(isnull(M_AREAR_AMOUNT_cutoff,0))--,S_Sal_Tran_ID               
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
			   and M_AD_NOT_EFFECT_SALARY = 0       and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_Date, mad.M_AD_Flag, mad.Sal_Tran_ID   
						
	
			  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.ReimAmount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,0-- ,S_Sal_Tran_ID       
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id  and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
			   and (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1)      and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.to_Date, mad.M_AD_Flag, mad.Sal_Tran_ID   
			
			--Added by Nimesh 19 May, 2015
			--If the option is disabled from the Admin Settings "Show Reimbursment Amount in Payslip" then 
			--Reimbursment allowance should not be displayed.
			DECLARE @ReimbOption int = 0;
			Select @ReimbOption=Setting_Value FROM T0040_SETTING WITH (NOLOCK) Where Setting_Name='Show Reimbursement Amount in Salary Slip' AND Group_By='Reports' AND Cmp_ID=@Cmp_ID;
			IF (@ReimbOption > 0) BEGIN
				--Inserting Reimbursement records which is not claimed and not marked as AutoPaid
				INSERT INTO #PAY_SLIP(Emp_ID,Cmp_ID,ADM.AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,
										AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
				SELECT	EED.EMP_ID,EED.Cmp_ID,EED.AD_ID,MAD.Sal_Tran_ID,
						MAD.ReimAmount,
						SUM(MAD.M_AD_Actual_Per_Amount) As AD_Amount_Actual,SUM(MAD.M_AD_Calculated_Amount) As AD_Amount_Calculated,MAD.For_Date,EED.E_AD_FLAG,0
				FROM	(T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.CMP_ID=AD.CMP_ID AND EED.AD_ID=AD.AD_ID)
						INNER JOIN #Emp_Cons E ON E.Emp_ID=EED.Emp_ID
						LEFT OUTER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EED.Cmp_ID=MAD.Cmp_ID AND EED.AD_ID=MAD.AD_ID AND EED.EMP_ID=MAD.Emp_ID
				WHERE	EED.CMP_ID=@Cmp_ID AND EED.E_AD_AMOUNT <> 0 AND AD.Auto_Paid<>1 AND AD.Allowance_Type='R' AND 
						EED.AD_ID  NOT IN (SELECT AD_ID FROM #PAY_SLIP P WHERE P.Emp_ID=EED.Emp_ID)						
				GROUP BY EED.EMP_ID,EED.Cmp_ID,EED.AD_ID,MAD.Sal_Tran_ID,MAD.For_Date,EED.E_AD_FLAG,MAD.ReimAmount
				
				--Inserting Reimbursement records which is not claimed and marked as AutoPaid but not monthly.
				INSERT INTO #PAY_SLIP(Emp_ID,Cmp_ID,ADM.AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,
										AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
				SELECT	EED.EMP_ID,EED.Cmp_ID,EED.AD_ID,MAD.Sal_Tran_ID,
						MAD.ReimAmount,
						SUM(MAD.M_AD_Actual_Per_Amount) As AD_Amount_Actual,SUM(MAD.M_AD_Calculated_Amount) As AD_Amount_Calculated,MAD.For_Date,EED.E_AD_FLAG,0
				FROM	(T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON EED.CMP_ID=AD.CMP_ID AND EED.AD_ID=AD.AD_ID)
						INNER JOIN #Emp_Cons E ON E.Emp_ID=EED.Emp_ID
						LEFT OUTER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON EED.Cmp_ID=MAD.Cmp_ID AND EED.AD_ID=MAD.AD_ID AND EED.EMP_ID=MAD.Emp_ID
				WHERE	EED.CMP_ID=@Cmp_ID AND EED.E_AD_AMOUNT <> 0 AND (AD.Auto_Paid=1 AND IsNull(AD.AD_CAL_TYPE,'Monthly') <> 'Monthly') AND AD.Allowance_Type='R' AND 
						EED.AD_ID  NOT IN (SELECT AD_ID FROM #PAY_SLIP P WHERE P.Emp_ID=EED.Emp_ID)						
				GROUP BY EED.EMP_ID,EED.Cmp_ID,EED.AD_ID,MAD.Sal_Tran_ID,MAD.For_Date,EED.E_AD_FLAG,MAD.ReimAmount
				
			END
			
			---YTD Column-- Ankit 10102013---
		   Update #Pay_slip Set YTD = M_AD_Amount From
			 (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
				From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
				#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
			   and M_AD_NOT_EFFECT_SALARY = 0   and MAD.Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0         
			Group by Mad.Emp_ID,mad.AD_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
			
			
			 Update #Pay_slip Set YTD = M_AD_Amount From						----YTD For Reimbersment Allowance
			 (Select Ad_Id, Mad.Emp_ID,sum(mad.ReimAmount) as M_AD_Amount 
				From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
				#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
			   and M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1   and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) 
			Group by Mad.Emp_ID,mad.AD_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
        			
			
		End
	Else
		begin    
		
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.to_Date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0)) +sum(isnull(M_AREAR_AMOUNT_cutoff,0))
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id  and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
			   and M_AD_NOT_EFFECT_SALARY = 0         and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.to_Date, mad.M_AD_Flag, mad.Sal_Tran_ID       
			
			

		---YTD Column-- Ankit 10102013---
		   Update #Pay_slip Set YTD = M_AD_Amount From
			 (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
				From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
				#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.To_Date <=@To_Date
			   and M_AD_NOT_EFFECT_SALARY = 0   and MAD.Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0         
			Group by Mad.Emp_ID,mad.AD_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
		 
		 ----  Update #Pay_slip Set YTD = M_AD_Amount From
			---- (Select Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
			----	From T0210_MONTHLY_AD_DETAIL  MAD INNER JOIN
			----	#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			----WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
			----   and M_AD_NOT_EFFECT_SALARY = 0 and MAD.Sal_Tran_ID is not null  
			----   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage >0         
			----Group by Mad.Emp_ID,mad.AD_ID) Qry
			----Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
		 ---YTD Column-- Ankit 10102013---

					
			Declare @AD_Id as Numeric
			Declare @M_AD_Amount_Arear as Numeric(18,2)
			Declare @S_Emp_Id as Numeric
			
			Set @M_AD_Amount_Arear = 0

			declare Cur_Payslip   cursor for
				Select Emp_ID  From #Pay_slip Group By Emp_ID
			open Cur_Payslip
			fetch next from Cur_Payslip  into @S_Emp_Id
			while @@fetch_status = 0
				begin

					declare Cur_Allow   cursor for
						Select  MAD.AD_ID, Isnull(SUM(M_AD_Amount),0)  From t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
							T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
							T0050_AD_MASTER WITH (NOLOCK) on MAD.Ad_Id = T0050_AD_MASTER.Ad_ID
							and MAD.Cmp_ID = T0050_AD_MASTER.Cmp_Id
							and MAD.Emp_ID  = @S_Emp_Id
						where MAD.Cmp_ID = @Cmp_ID and month(MSS.S_Eff_Date) =  MONTH(@To_Date) and Year(MSS.S_Eff_Date) = YEAR(@To_Date)
							and isnull(mad.M_AD_NOT_EFFECT_SALARY,0) = 0    and Ad_Active = 1 
							and AD_Flag = 'D' And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID
					open cur_allow
					fetch next from cur_allow  into @AD_ID,@M_AD_Amount_Arear
					while @@fetch_status = 0
						begin
					
							--If exists (Select 1 From #Pay_slip Where Emp_ID = @S_Emp_Id And AD_ID = @AD_Id)
								Begin
									Update #Pay_slip Set AD_Amount = AD_Amount + ISNULL(@M_AD_Amount_Arear,0)
									Where Emp_ID = @S_Emp_Id And Cmp_ID = @Cmp_ID And AD_ID = @AD_Id
								End
							--Else
							--	Begin
							--	   Insert into #Pay_slip 
							--		(Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
							--		Select @S_Emp_Id, @Cmp_ID,@AD_Id,0,@M_AD_Amount_Arear,0,0,@From_Date,'D',0
							--	End	
					

							fetch next from cur_allow  into @AD_ID,@M_AD_Amount_Arear
						end
					close cur_Allow
					deallocate Cur_Allow

					fetch next from Cur_Payslip  into @S_Emp_Id
				end
			close Cur_Payslip
			deallocate Cur_Payslip
			
		End           
   --Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   --Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))             
   --  From T0210_MONTHLY_AD_DETAIL  MAD INNER  JOIN         
   --  #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
   -- WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date          
   --    and M_AD_NOT_EFFECT_SALARY = 0          and Sal_Tran_ID is not null  
   --    and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage >0         
   -- Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag ,mad.Sal_Tran_ID  
    
        
   end        

	
 if @Sal_Type =0         
  BEGIN  


        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I' , ms.Arear_Basic  +ms.basic_salary_arear_cutoff           
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)  And Is_FNF = 0 


	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'

	----Hasmukh  15102013------
	Update #Pay_Slip Set AD_Actual_Amount = MSY.Day_Salary from dbo.T0200_MONTHLY_SALARY MSY inner join dbo.T0095_Increment I 
				On MSY.increment_id = i.Increment_ID
			--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
			Inner Join #Pay_Slip P on I.Emp_Id = MSY.Emp_Id AND P.Sal_Tran_ID = MSY.Sal_Tran_ID	--Ankit 11092014
	Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary' and i.Wages_Type = 'Daily'
	  and  Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)--Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date  -- Added by rohit on 18102014 for Day Rate Showing Wrong daily Wages Employee
    -------Hasmukh 15102013--------
            	    
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'       
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)--Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
    AND Total_claim_Amount <> 0
    ----------Added by Sumit 18082015-----------------------------------------------------------------------------------------
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Amount',Sal_Tran_ID,replace(Travel_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'I',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID
	and Travel_Amount <> 0
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Advance Amount',Sal_Tran_ID,replace(travel_Advance_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'D',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	AND travel_Advance_Amount <> 0
	
	-- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
-----------Ended by Sumit 18082015----------------------------------- 
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   select ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I',0
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and ms.OT_Amount <> 0 --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
    
    
    -- UnCommented by Falak on 12-MAY-2011        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I' 
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(Other_Allow_Amount,0) >0    --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0        
      and ms.Other_Allow_Amount <> 0
 
	If @With_Arear_Amount = 0
		Begin        
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
			select  ms.Emp_ID,Cmp_ID,null,'Arrear Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I',0
			 From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
			 and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)
			 and ms.Settelement_Amount <> 0-- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date --and isnull(Settelement_Amount,0) >0        
		End
	Else
		Begin
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
			select  ms.Emp_ID,MS.Cmp_ID,null,'Arrear Gross Amount',0,SUM(S_Gross_Salary),null,0,S_Eff_Date ,'I',0
			 From T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			 and  Month(S_Eff_Date) =Month(@To_Date) and Year(S_Eff_Date) = Year(@To_Date)	-- S_Eff_Date >=@From_Date and S_Eff_Date <=@To_Date 
			 And MS.Emp_ID In 
				(select  ms.Emp_ID
				From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
				and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)) and S_Gross_Salary <> 0
			 Group by ms.Emp_ID,MS.Cmp_ID,S_Eff_Date
		End      
      
      
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I',0
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(Leave_Salary_Amount,0) >0       
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)  and ms.Advance_Amount <> 0       

--added By Mukti(start)25032015
  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	   select ms.Emp_ID,Cmp_ID,null,'Asset Installment Amount',Sal_Tran_ID,Asset_Installment,null,Gross_Salary,Month_end_Date ,'D'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and Asset_Installment <> 0
--added By Mukti(end)25032015 
  
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D' 
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and ms.Loan_Amount <> 0

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Interest',Sal_Tran_ID,Loan_Intrest_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)  and ms.Loan_Intrest_Amount <> 0  
    
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I',0
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(Bonus_Amount,0) >0	  
    
   --commented by Falak on 29-OCT-2010 as per told by nilay 
 /*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
           
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'Professional tax',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)     and ms.PT_Amount <> 0  
           
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)   and ms.LWF_Amount <> 0     
        
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and ms.Revenue_Amount <> 0      
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Other Dedu',Sal_Tran_ID,Other_Dedu_Amount,Other_Dedu_Amount,0,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and ms.Other_Dedu_Amount <> 0
    
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	select ms.Emp_ID,Cmp_ID,null,'Extra Absent Amount',Sal_Tran_ID,Extra_AB_Amount,Extra_AB_Amount,0,Month_end_Date ,'D'        
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and  Extra_AB_Amount <> 0   
	

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	select ms.Emp_ID,Cmp_ID,null,'Deficit Dedu Amount',Sal_Tran_ID,Deficit_Dedu_Amount,Deficit_Dedu_Amount,0,Month_end_Date ,'D'       
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)     and ms.Deficit_Dedu_Amount <> 0  
	
	 ----Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(GatePass_Amount,0) > 0  
	 ----Added by Gadriwala Muslim 06012015- End 
	   
   --Added by Mihir Trivedi on 16/08/2012--------
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
				select  ms.Emp_ID,Cmp_ID,null,'Week Off Working',Sal_Tran_ID,M_WO_OT_Amount,M_WO_OT_Amount,0,Month_end_Date ,'I',0
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(M_WO_OT_Amount,0) >0
					
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
				select  ms.Emp_ID,Cmp_ID,null,'Holiday Working',Sal_Tran_ID,M_HO_OT_Amount,M_HO_OT_Amount,0,Month_end_Date ,'I',0
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) and isnull(M_HO_OT_Amount,0) >0
    --End of Added by Mihir Trivedi on 16/08/2012--------  
    
    
    ---YTD Column-- Ankit 10102013---
		Update #Pay_slip Set YTD = Salary_Amount From
		 (Select Mad.Emp_ID,sum(mad.Salary_Amount) as Salary_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
		
		Update #Pay_slip Set YTD = Total_Claim_Amount From
		 (Select Mad.Emp_ID,sum(mad.Total_Claim_Amount) as Total_Claim_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Claim Amount'
	          
		Update #Pay_slip Set YTD = OT_Amount From
		 (Select Mad.Emp_ID,sum(mad.OT_Amount) as OT_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'OT Amount'
		
		Update #Pay_slip Set YTD = Other_Allow_Amount From
		 (Select Mad.Emp_ID,sum(mad.Other_Allow_Amount) as Other_Allow_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Arrears'
		
		Update #Pay_slip Set YTD = Other_Allow_Amount From
		 (Select Mad.Emp_ID,sum(mad.Other_Allow_Amount) as Other_Allow_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Arrear Amount'
		
		Update #Pay_slip Set YTD = Leave_salary_Amount From
		 (Select Mad.Emp_ID,sum(mad.Leave_salary_Amount) as Leave_salary_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Leave Encash Amount'
		
		Update #Pay_slip Set YTD = Advance_Amount From
		 (Select Mad.Emp_ID,sum(mad.Advance_Amount) as Advance_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Advance Amount'
		
		Update #Pay_slip Set YTD = Loan_Amount From
		 (Select Mad.Emp_ID,sum(mad.Loan_Amount) as Loan_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Loan Amount'
		
		Update #Pay_slip Set YTD = Loan_Intrest_Amount From
		 (Select Mad.Emp_ID,sum(mad.Loan_Intrest_Amount) as Loan_Intrest_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Loan Interest'
		
		Update #Pay_slip Set YTD = Bonus_Amount From
		 (Select Mad.Emp_ID,sum(mad.Bonus_Amount) as Bonus_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID

			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Bonus'
		
		Update #Pay_slip Set YTD = PT_Amount From
		 (Select Mad.Emp_ID,sum(mad.PT_Amount) as PT_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Professional tax'
		
		Update #Pay_slip Set YTD = LWF_Amount From
		 (Select Mad.Emp_ID,sum(mad.LWF_Amount) as LWF_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'LWF Amount'
		
		Update #Pay_slip Set YTD = Revenue_Amount From
		 (Select Mad.Emp_ID,sum(mad.Revenue_Amount) as Revenue_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Revenue Amount'
		
		Update #Pay_slip Set YTD = Other_Dedu_Amount From
		 (Select Mad.Emp_ID,sum(mad.Other_Dedu_Amount) as Other_Dedu_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Other Dedu'
		
		Update #Pay_slip Set YTD = Extra_AB_Amount From
		 (Select Mad.Emp_ID,sum(mad.Extra_AB_Amount) as Extra_AB_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Extra Absent Amount'
		
		Update #Pay_slip Set YTD = M_WO_OT_Amount From
		 (Select Mad.Emp_ID,sum(mad.M_WO_OT_Amount) as M_WO_OT_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Week Off Working'
		
		Update #Pay_slip Set YTD = M_HO_OT_Amount From
		 (Select Mad.Emp_ID,sum(mad.M_HO_OT_Amount) as M_HO_OT_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Holiday Working'
		
	
	---YTD Column-- Ankit 10102013---
     	--added By Mukti(start)25032015
		Update #Pay_slip Set YTD = Asset_Installment From
		 (Select Mad.Emp_ID,sum(mad.Asset_Installment) as Asset_Installment
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Asset Installment Amount'
		--added By Mukti(end)25032015
  end        
 else if @Sal_Type =1        
  begin        
	
	  
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID )        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,s_Month_end_Date ,'I',0    ,S_Sal_Tran_ID     
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date) --and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        



	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'

	----Hasmukh  15102013------
	Update #Pay_Slip Set AD_Actual_Amount = MSY.Day_Salary from dbo.T0200_MONTHLY_SALARY MSY inner join dbo.T0095_Increment I 
				On MSY.increment_id = i.Increment_ID
			--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
			Inner Join #Pay_Slip P on I.Emp_Id = MSY.Emp_Id AND P.Sal_Tran_ID = MSY.Sal_Tran_ID	--Ankit 11092014
	Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary' and i.Wages_Type = 'Daily'
	----Hasmukh  15102013------

	---YTD Column-- Ankit 10102013---
	 Update #Pay_slip Set YTD = Salary_Amount From
     (Select Mad.Emp_ID,sum(mad.Salary_Amount) as Salary_Amount
		From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
		Group by Mad.Emp_ID) Qry
		Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
	Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
	---YTD Column-- Ankit 10102013---
   
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID )  
    select ms.Emp_ID,Cmp_ID,null,'OT Amount',null,S_OT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'I' ,0,S_Sal_Tran_ID        
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
          
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID )  
    select ms.Emp_ID,Cmp_ID,null,'Holiday Working',null,S_WO_OT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'I' ,0 ,S_Sal_Tran_ID       
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
   
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days,S_Sal_Tran_ID )  
    select ms.Emp_ID,Cmp_ID,null,'Week Off Working',null,S_HO_OT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'I' ,0    ,S_Sal_Tran_ID    
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
          
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID )        
   select ms.Emp_ID,Cmp_ID,null,'Professional tax',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D' ,S_Sal_Tran_ID        
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID )        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D',S_Sal_Tran_ID         
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID )        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D' ,S_Sal_Tran_ID        
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
  end        
 else if @Sal_Type =2        
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,l_Basic_Salary,0,L_Month_end_Date ,'I'        
    From T0200_Monthly_Salary_Leave  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(L_Month_end_Date) =Month(@To_Date) and Year(L_Month_end_Date) = Year(@To_Date)--and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        

	----Added for Basic Rate should come from Increment.. Before it was taken from Salary Table..
	----Hardik 08/08/2012
	--Update #Pay_Slip Set AD_Actual_Amount = I.Basic_Salary from dbo.T0095_Increment I inner join 
	--		( select max(Increment_effective_Date) as For_Date,Emp_Id from dbo.T0095_Increment
	--		where Increment_Effective_date <= @To_Date
	--		and Cmp_ID = @Cmp_ID 
	--		group by emp_ID  ) Qry on
	--		I.Increment_effective_Date = Qry.For_Date And Qry.Emp_Id = I.Emp_ID
	--		Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
	--Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'

	----Hasmukh  15102013------
	Update #Pay_Slip Set AD_Actual_Amount = MSY.Day_Salary from dbo.T0200_MONTHLY_SALARY MSY inner join dbo.T0095_Increment I 
				On MSY.increment_id = i.Increment_ID
			--Inner Join #Pay_Slip P on I.Emp_Id = P.Emp_Id
			Inner Join #Pay_Slip P on I.Emp_Id = MSY.Emp_Id AND P.Sal_Tran_ID = MSY.Sal_Tran_ID	--Ankit 11092014
	Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary' and i.Wages_Type = 'Daily'
	----Hasmukh  15102013------

	---YTD Column-- Ankit 10102013---
	 Update #Pay_slip Set YTD = Salary_Amount From
     (Select Mad.Emp_ID,sum(mad.Salary_Amount) as Salary_Amount
		From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
		WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
		Group by Mad.Emp_ID) Qry
		Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
	Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Basic Salary'
	---YTD Column-- Ankit 10102013---
	
        
  /* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,L_PT_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,L_LWF_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,L_Revenue_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date*/        
  end        
 else        
  begin       
  
    
   
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Basic Salary',null,0,0,0,@To_Date,'I',1 From #Emp_Cons ec         
              
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
        
  --  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
  --  select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
  --   From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --   and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
     
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
      and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)/*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/ and isnull(Settelement_Amount,0) >0        
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) /* and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/ and isnull(Leave_Salary_Amount,0) >0        
        
        
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'        
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)/*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
     
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	 select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)/*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/ and isnull(Bonus_Amount,0) >0	       
     	
	--added By Mukti(start)25032015
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	   select ms.Emp_ID,Cmp_ID,null,'Asset Amount',Sal_Tran_ID,Asset_Installment,null,Gross_Salary,Month_end_Date ,'D'        
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)/*and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
  --added By Mukti(end)25032015
            
   /* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)        
    Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID          
    from T0200_Monthly_Salary ms Inner Join #Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp on ms.sal_Tran_Id = mlp.Sal_Tran_Id         
    inner join T0120_loan_approval la on mlp.loan_apr_ID = la.Loan_Apr_ID inner join         
    t0040_Loan_Master lm on la.loan_Id = lm.loan_Id        
    and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date */        
            
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Professional tax',null,0,null,0,@To_Date,'D',2 From #Emp_Cons         
        
  -- --Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(GatePass_Amount,0) > 0  
  -- --Added by Gadriwala Muslim 06012015- End     
    Update #Pay_slip        
    set AD_Amount = Salary_amount ,         
     AD_ACtual_Amount = Basic_Salary         
    From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID 
    --and  Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
    Where Def_ID = 1        
            
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount,         
     AD_ACtual_Amount = S_Basic_Salary         
    From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID 
    --and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date  
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)      
    Where Def_ID = 1        
                
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount,         
     AD_ACtual_Amount = L_Basic_Salary         
    From #Pay_slip P inner join T0200_Monthly_Salary_Leave  ms on p.emp_ID =ms.emp_ID 
    --and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date  ]
    and Month(L_Month_end_Date) =Month(@To_Date) and Year(L_Month_end_Date) = Year(@To_Date)       
    Where Def_ID = 1        
        
        
            
    Update #Pay_slip        
    set AD_Amount = PT_Amount ,         
     AD_Calculated_Amount = PT_Calculated_Amount         
    From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and         
     --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date       
      Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
    Where Def_ID = 2        
             
        
    Update #Pay_slip        
    set AD_Amount =isnull(AD_Amount,0) +  S_PT_Amount ,         
     AD_Calculated_Amount = S_PT_Calculated_Amount         
    From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and         
     --S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
     Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
    Where Def_ID = 2        
        
        
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'LWF Amount',null,0,null,0,@To_DAte,'D' ,3 From #Emp_Cons         
  
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Revenue Amount',null,0,null,0,@To_DAte,'D' ,4 From #Emp_Cons         
            
    
    ---YTD Column-- Ankit 10102013---
		Update #Pay_slip Set YTD = Settelement_Amount From
		 (Select Mad.Emp_ID,sum(mad.Settelement_Amount) as Settelement_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Settlement Amount'
		
		Update #Pay_slip Set YTD = Leave_salary_Amount From
		 (Select Mad.Emp_ID,sum(mad.Leave_salary_Amount) as Leave_salary_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Leave Encash Amount'
	          
		Update #Pay_slip Set YTD = OT_Amount From
		 (Select Mad.Emp_ID,sum(mad.OT_Amount) as OT_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'OT Amount'
						
		Update #Pay_slip Set YTD = Bonus_Amount From
		 (Select Mad.Emp_ID,sum(mad.Bonus_Amount) as Bonus_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Bonus'
		
		Update #Pay_slip Set YTD = Advance_Amount From
		 (Select Mad.Emp_ID,sum(mad.Advance_Amount) as Advance_Amount
			From T0200_MONTHLY_SALARY  MAD WITH (NOLOCK) INNER JOIN
			#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and (MAD.Month_St_Date Between @F_StartDate and @F_EndDate) and MAD.Month_End_Date<=@To_Date
			Group by Mad.Emp_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID 
		Where P.Cmp_ID = @Cmp_ID And AD_Description = 'Advance Amount'
	---YTD Column-- Ankit 10102013---
	
    
  END 


  DECLARE @Hide_Allowance_Rate_PaySlip AS TINYINT	--Ankit 01052015
  SET @Hide_Allowance_Rate_PaySlip = 0
  
  SELECT @Hide_Allowance_Rate_PaySlip = ISNULL(Setting_Value,0) 
  FROM T0040_SETTING WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND Setting_Name LIKE 'Hide Allowance Rate in Salary Slip'
  
  
 -- Changed By Ali 22112013  
 Select DISTINCT ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,
	E.Emp_First_Name,
	Case When @Hide_Allowance_Rate_PaySlip = 0 Then
		(AD_Name + ' (' + case when GA.AD_MODE = '%' then cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) as nvarchar(20)) else '' end  + isnull(GA.ad_mode,'AMT') + ') ')
	Else
		Ad_Name
	End As AD_Name ,
		--(AD_Name + ' (' + case when GA.AD_MODE = '%' then cast([dbo].[F_Remove_Zero_Decimal](AD_Actual_Amount) as nvarchar(20)) else '' end  + isnull(GA.ad_mode,'AMT') + ') ')as AD_Name ,
	 ADM.AD_LEVEL ,
	 MAD.Emp_ID, Mad.Cmp_ID,Mad.Ad_ID,Mad.Sal_Tran_ID,Mad.Ad_Description ,Mad.Ad_Amount
	 --,dbo.F_Remove_Zero_Decimal(Mad.Ad_Actual_Amount) as Ad_Actual_Amount
	  ,case when Upper(Adm.Ad_calculate_on)='FORMULA' then '0.00' else dbo.F_Remove_Zero_Decimal(Mad.Ad_Actual_Amount) end as Ad_Actual_Amount -- Added by rohit on 060120016 for Formula Rate Showing Zero
	 ,Mad.Ad_Calculated_Amount,Mad.For_Date,Mad.M_Ad_Flag,Mad.Loan_ID,Mad.Def_ID,Mad.M_Arrear_Days,Mad.YTD      
	  -- Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name ,AD_LEVEL ,MAD.*        
      --,  case when  GA.ad_mode = '%' then
	  --					Round(cast(((mad.AD_Actual_Amount * (select smad.AD_Actual_Amount from #Pay_slip smad where smad.Emp_ID = MAD.Emp_ID and smad.AD_Description = 'Basic Salary'))/100) as numeric(18,2)),0)
	  --				else
	  --					mad.AD_Actual_Amount 
	  --				end
	  --			 as AD_Amount_on_basic_for_per,
	  --, case when GA.ad_mode = '%' then [dbo].[F_Remove_Zero_Decimal](EED.E_AD_Amount) Else  mad.AD_Actual_Amount End	--Comment By Ankit 15092015
	   , case when Upper(Adm.Ad_calculate_on)='FORMULA' then '0.00' else CASE WHEN GA.ad_mode = '%' THEN 
			[dbo].[F_Remove_Zero_Decimal](CASE WHEN EEDR_Q.FOR_DATE > EED.FOR_DATE THEN EEDR_Q.E_AD_AMOUNT ELSE EED.E_AD_Amount END) 
		 ELSE  mad.AD_Actual_Amount End  end as AD_Amount_on_basic_for_per, -- Changed By rohit For Rate Showing Zero For Formula Allowance on 06012016
		BM.Branch_ID , Alpha_Emp_Code, MAD.S_Sal_Tran_Id
	  
   From #Pay_slip  MAD Left outer join         
     T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN         
  T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN         
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join         
   --( select I.Increment_ID, I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join         
   --  ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment        
   --  where Increment_Effective_date <= @To_Date        
   --  and Cmp_ID = @Cmp_ID        
   --  group by emp_ID  ) Qry on        
   --  I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q         
   -- on E.Emp_ID = I_Q.Emp_ID  inner join    
   (Select I.Increment_ID, I.Emp_Id , Grd_ID,Branch_ID,I.Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from dbo.T0095_INCREMENT I WITH (NOLOCK) Inner join
	(Select MAX(Increment_Id) as Inc_Id, II.Emp_ID From dbo.T0095_INCREMENT II WITH (NOLOCK) Inner Join
	(Select MAX(Increment_Effective_Date)  as For_Date ,I.Emp_Id from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join #Emp_Cons E on I.Emp_ID = E.Emp_Id Where Cmp_ID=@Cmp_ID and Increment_Effective_Date <=  @To_Date
	Group by I.Emp_ID) Qry on II.Emp_ID = Qry.Emp_ID And II.Increment_Effective_Date = Qry.For_Date
	Group by II.Emp_ID) Qry1 on I.Increment_ID = Qry1.Inc_Id and I.Emp_ID = Qry1.Emp_Id) I_Q    on E.Emp_ID = I_Q.Emp_ID  inner join 
    
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join         
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer join
	 T0120_gradewise_allowance GA WITH (NOLOCK) on I_Q.Grd_id = GA.Grd_ID and ADM.ad_id = GA.Ad_ID Left Outer Join
	 T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) on I_Q.Increment_ID = EED.INCREMENT_ID And MAD.AD_ID = EED.AD_ID And MAD.Emp_ID = EED.EMP_ID
     LEFT OUTER JOIN	----Ankit 15092015
	 ( SELECT EEDR.Emp_Id,EEDR.AD_ID ,EEDR.FOR_DATE,EEDR.E_AD_AMOUNT FROM T0110_EMP_EARN_DEDUCTION_REVISED EEDR WITH (NOLOCK) INNER JOIN
		 ( SELECT MAX(FOR_DATE) as For_Date , Emp_ID,AD_ID FROM T0110_EMP_EARN_DEDUCTION_REVISED WITH (NOLOCK)      
		   WHERE FOR_DATE <= @To_Date and Cmp_ID = @Cmp_ID GROUP BY emp_ID  ,AD_ID
		 ) Qry ON EEDR.Emp_ID = Qry.Emp_ID and EEDR.For_Date = Qry.For_Date AND EEDR.AD_ID = Qry.AD_ID
	 ) EEDR_Q ON MAD.AD_ID = EEDR_Q.AD_ID And MAD.Emp_ID = EEDR_Q.EMP_ID        
  WHERE E.Cmp_ID = @Cmp_Id  and  Month(MAD.For_Date) = Month(@To_date) and Year(Mad.For_date) = Year(@To_date) --MAD.For_date > =@From_Date and MAD.For_date <=@To_Date        
    --and (MAD.AD_Amount <> 0 OR (ADM.Allowance_Type='R' AND (MAD.AD_Amount <> 0 OR MAD.AD_Actual_Amount <>0)) ) 
    --and ISNULL(MAD.Head_Type,'') <> case when (ISNULL(MAD.Head_Type,'') = 'DF' and  mad.ad_amount = 0) then '' else 'DF' end
    order by Ad_name  desc  
        
      -- select case when (ISNULL(Head_Type,'') = 'DF' and  ad_amount = 0) then '' else 'DF' end as AA,* from #Pay_slip     
        
   Return         
  
  RETURN         

