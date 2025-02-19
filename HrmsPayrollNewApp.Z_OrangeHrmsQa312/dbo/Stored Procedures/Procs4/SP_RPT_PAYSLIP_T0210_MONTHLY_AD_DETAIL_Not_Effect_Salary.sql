
---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_Not_Effect_Salary]        
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
,@constraint  varchar(max)        
,@Sal_Type  numeric =0        
,@Salary_Cycle_id numeric = 0
,@Segment_Id  numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@Vertical_Id numeric = 0		 -- Added By Gadriwala Muslim 24072013
,@SubVertical_Id numeric = 0	 -- Added By Gadriwala Muslim 24072013
,@SubBranch_Id numeric = 0		 -- Added By Gadriwala Muslim 01082013	
,@Status varchar(20) = ''		 -- Added by Nimesh 19 May 2015 (To Filter Salary by Status)	
 ,@Payment_mode varchar(20) = '' --Added by ronakk 20082022
   ,@Salary_Status  varchar(100) = '' --Added by ronakk 20102022
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
  
  declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 
  
	If @Branch_ID is null
		Begin 
			select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
			  from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID    
			  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
		End
	Else
		Begin
			select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
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
			   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@To_date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@To_date) )as varchar(10)) as smalldatetime)    
			   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
			   Set @From_Date = @Sal_St_Date
			   Set @To_Date = @Sal_End_Date  
			 end
		else
			begin
				select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period WITH (NOLOCK) where month= month(@To_date) and YEAR=year(@To_date)							   
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
   AD_Actual_Amount  numeric(18,2),        
   AD_Calculated_Amount numeric(18,2),      
   For_Date    Datetime,        
   M_AD_Flag    char(1),        
   Loan_Id     numeric,        
   Def_ID     numeric ,
   M_Arrear_Days  numeric,
   YTD numeric(18,2)     --Ankit 10102013
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
 
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))           
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN   
     t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join 
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)   --For_date >=@From_Date and For_date <=@To_Date          
       and MAD.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1      
       and isnull(Sal_Type,0) in (1,2) and MAD.M_AD_Percentage =0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag        
                     
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))           
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN  
     t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join        
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)   --For_date >=@From_Date and For_date <=@To_Date          
      and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1             
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag        
    
    
    
 ---YTD Column-- Ankit 10102013---
   Update #Pay_slip Set YTD = M_AD_Amount From
     (Select MAD.Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
		From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
		t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join        
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
    WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
   and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1             
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage =0         
    Group by Mad.Emp_ID,mad.AD_ID) Qry
    Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
 
   Update #Pay_slip Set YTD = M_AD_Amount From
     (Select MAD.Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
		From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
		t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join   
		#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
    WHERE MAD.Cmp_ID = @Cmp_Id and MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
       and MAD.M_AD_NOT_EFFECT_SALARY = 0 and AM.effect_net_salary=1             
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0         
    Group by Mad.Emp_ID,mad.AD_ID) Qry
    Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
 ---YTD Column-- Ankit 10102013---
    
    
  End        
  
 Else        

  Begin        

	If @With_Arear_Amount = 0  
		BEGIN
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join        
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id --and For_date >=@From_Date and For_date <=@To_Date          
				And Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)   
			   and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1             
			   and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_date, mad.M_AD_Flag, mad.Sal_Tran_ID   
			
			 
			  
			  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.ReimAmount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join        
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)   -- For_date >=@From_Date and For_date <=@To_Date          
			   and ((mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1 )   or MAD.reimShow= 1)     
			    and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_date, mad.M_AD_Flag, mad.Sal_Tran_ID   
			
			---YTD Column-- Ankit 10102013---
		   Update #Pay_slip Set YTD = M_AD_Amount From
			 (Select MAD.Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
				From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
				t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join        
				#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and  MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
			   and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1     
			   and MAD.Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0         
			Group by Mad.Emp_ID,mad.AD_ID) Qry
			Inner join #Pay_slip p on Qry.Emp_ID = p.Emp_ID and Qry.AD_ID = p.AD_ID
			    
		End
	Else
		begin    
		
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
			 t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join                
			 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)   -- For_date >=@From_Date and For_date <=@To_Date          
			   and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1     
			   and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID,mad.To_date, mad.M_AD_Flag, mad.Sal_Tran_ID       

		---YTD Column-- Ankit 10102013---
		   Update #Pay_slip Set YTD = M_AD_Amount From
			 (Select MAD.Ad_Id, Mad.Emp_ID,sum(mad.m_AD_Amount) as M_AD_Amount 
				From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER JOIN
				t0050_ad_master AM WITH (NOLOCK) on MAD.cmp_id = AM.cmp_id and MAD.Ad_id = AM.Ad_id inner join                
				#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)    --MAD.For_Date >=@F_StartDate and MAD.For_date <=@To_Date
			   and mad.M_AD_NOT_EFFECT_SALARY = 1 and AM.effect_net_salary=1     
			   and MAD.Sal_Tran_ID is not null  
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
							and mad.M_AD_NOT_EFFECT_SALARY = 1 and T0050_AD_MASTER.effect_net_salary=1   
							and Ad_Active = 1 
							--and AD_Flag = 'D' --Comment B'cos Sett Amount display in Arear amount column - AIA - Ankit  13072016
							And Sal_Type = 1
						Group By MAD.AD_ID,MSS.Emp_ID
					open cur_allow
					fetch next from cur_allow  into @AD_ID,@M_AD_Amount_Arear
					while @@fetch_status = 0
						begin
									IF @With_Arear_Amount = 0 -- Ankit 03062016
										BEGIN
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
										END
									ELSE IF @With_Arear_Amount = 1 -- added by Ankit 03062016
										BEGIN
											Update #Pay_slip 
											Set M_Arrear_Days = ISNULL(M_Arrear_Days ,0 ) + ISNULL(@M_AD_Amount_Arear,0) 
												,AD_Amount = AD_Amount
											Where Emp_ID = @S_Emp_Id And Cmp_ID = @Cmp_ID And AD_ID = @AD_Id
										END

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
 -- Changed By Ali 22112013  
 Select ISNULL(EmpName_Alias_Salary,Emp_Full_Name) as Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,(AD_Name + ' (' + case when GA.AD_MODE = '%' then cast(AD_Actual_Amount as nvarchar(20)) else '' end  + isnull(GA.ad_mode,'AMT') + ') ')as AD_Name ,ADM.AD_LEVEL ,MAD.*        
-- Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name ,AD_LEVEL ,MAD.*        
      --,  case when  GA.ad_mode = '%' then
	  --					Round(cast(((mad.AD_Actual_Amount * (select smad.AD_Actual_Amount from #Pay_slip smad where smad.Emp_ID = MAD.Emp_ID and smad.AD_Description = 'Basic Salary'))/100) as numeric(18,2)),0)
	  --				else
	  --					mad.AD_Actual_Amount 
	  --				end
	  --			 as AD_Amount_on_basic_for_per,
	  
	   , case when GA.ad_mode = '%' then  EED.E_AD_Amount
		Else  mad.AD_Actual_Amount End
	   as AD_Amount_on_basic_for_per,BM.Branch_ID , Alpha_Emp_Code,isnull(MADI.comments,'') as Comments
	   ,ADM.Gujarati_Alias as Gujarati_Alias
   From #Pay_slip  MAD Left outer join         
     T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN         
  T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN         
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join         
   ( select I.Increment_ID, I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join         
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)       
     where Increment_Effective_date <= @To_Date        
     and Cmp_ID = @Cmp_ID        
     group by emp_ID  ) Qry on        
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q         
    on E.Emp_ID = I_Q.Emp_ID  inner join        
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join         
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID Left outer join
	 T0120_gradewise_allowance GA WITH (NOLOCK) on I_Q.Grd_id = GA.Grd_ID and ADM.ad_id = GA.Ad_ID Left Outer Join
	 T0100_EMP_EARN_DEDUCTION EED WITH (NOLOCK) on I_Q.Increment_ID = EED.INCREMENT_ID And MAD.AD_ID = EED.AD_ID And MAD.Emp_ID = EED.EMP_ID
	 left join T0190_MONTHLY_AD_DETAIL_IMPORT MADI WITH (NOLOCK) on MAD.cmp_id = MADI.Cmp_id and MAD.Ad_id = MADI.Ad_id and MAD.Emp_id = MADI.Emp_id and month(MAD.For_Date) = MADI.month and year(MAD.For_Date) = MADI.Year and MAD.AD_Amount = MADI.Amount
             
  WHERE E.Cmp_ID = @Cmp_Id  and MAD.For_date >=@From_Date and MAD.For_date <=@To_Date        
    and MAD.AD_Amount > 0 or MAD.AD_Amount < 0  order by Ad_name  desc  
             
             
           select * from #Pay_slip
        
RETURN         
        
        
        

