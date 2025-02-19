

---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET_View_Slip]        
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
        
 Declare @Emp_Cons Table        
 (        
  Emp_ID numeric        
 )        
         
 if @Constraint <> ''        
  begin        
   Insert Into @Emp_Cons        
   select  cast(data  as numeric) from dbo.Split (@Constraint,'#')         
  end        
 else        
  begin        
           
           
   Insert Into @Emp_Cons        
        
   select I.Emp_Id from T0095_Increment I WITH (NOLOCK) inner join         
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment WITH (NOLOCK)       
     where Increment_Effective_date <= @To_Date        
     and Cmp_ID = @Cmp_ID        
     group by emp_ID  ) Qry on        
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID         
               
   Where Cmp_ID = @Cmp_ID         
   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))        
   and Branch_ID = isnull(@Branch_ID ,Branch_ID)        
   and Grd_ID = isnull(@Grd_ID ,Grd_ID)        
   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))        
   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))        
   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0))
    and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 24072013
   and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 24072013
   and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 24072013
    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013     
   and I.Emp_ID = isnull(@Emp_ID ,I.Emp_ID)         
   and I.Emp_ID in         
    ( select Emp_Id from        
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry        
    where cmp_ID = @Cmp_ID   and          
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )         
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )        
    or Left_date is null and @To_Date >= Join_Date)        
    or @To_Date >= left_date  and  @From_Date <= left_date )       
           
           
  end        
  
  
  
 -- Declare @Sal_St_Date   Datetime    
 -- Declare @Sal_end_Date   Datetime  
  
 -- declare @manual_salary_Period as numeric(18,0) -- Comment and added By rohit on 11022013 
  
	--If @Branch_ID is null
	--	Begin 
	--		select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
	--		  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID    
	--		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Cmp_ID = @Cmp_ID)    
	--	End
	--Else
	--	Begin
	--		select @Sal_St_Date  =Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013
	--		  from T0040_GENERAL_SETTING where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID    
	--		  and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING where For_Date <=@From_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)    
	--	End  
		
	--if @Salary_Cycle_id > 0
	--	begin
	--		select @Sal_St_Date = Salary_st_date from T0040_Salary_Cycle_Master where Tran_Id = @Salary_Cycle_id
	--	end  
       
 --if isnull(@Sal_St_Date,'') = ''    
	--begin    
	--   set @From_Date  = @From_Date     
	--   set @To_Date = @To_Date    
	--end     
 --else if day(@Sal_St_Date) =1 --and month(@Sal_St_Date)=1    
	--begin    
	--   set @From_Date  = @From_Date     
	--   set @To_Date = @To_Date    
	--end     
 --else if @Sal_St_Date <> ''  and day(@Sal_St_Date) > 1   
	--begin    
	--    -- Comment and added By rohit on 11022013
	--   --set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	--   --set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	--   --set @From_Date = @Sal_St_Date
	--   --Set @To_Date = @Sal_end_Date   
	--   if @manual_salary_Period =0 
	--		Begin
	--		   set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)    
	--		   set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))
	--		   Set @From_Date = @Sal_St_Date
	--		   Set @To_Date = @Sal_End_Date  
	--		 end
	--	else
	--		begin
	--			select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)							   
	--		     Set @From_Date = @Sal_St_Date
	--		   Set @To_Date = @Sal_End_Date    
	--		End	   
	--	-- Ended By rohit on 11022013	
	--End 
          
 Create table #Pay_slip         
  (        
   Emp_ID     numeric,        
   Cmp_ID     numeric,        
   AD_ID     numeric,        
   Sal_Tran_ID    numeric,        
   AD_Description   varchar(100),        
   AD_Amount    numeric(18,3),        
   AD_Actual_Amount  numeric(18,5),        -- Changed by Gadriwala Muslim 19032015
   AD_Calculated_Amount numeric(18,3),        
   For_Date    Datetime,        
   M_AD_Flag    char(1),        
   Loan_Id     numeric,        
   Def_ID     numeric ,
   M_Arrear_Days  numeric      
  )          
        
        
       
 if @Sal_Type =3        
  set  @Sal_Type =null        
          
         
 If @Sal_Type  =1         
  Begin        
 
		Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
			   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
				 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
				 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
				WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date          
				   and M_AD_NOT_EFFECT_SALARY = 0        and Sal_Tran_ID is not null  
				   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) 
				Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_Date, mad.M_AD_Flag, mad.Sal_Tran_ID     
	                     
	   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.ReimAmount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))           
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
		 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
		WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) -- For_date >=@From_Date and For_date <=@To_Date          
		   and   (M_AD_NOT_EFFECT_SALARY = 1 and  ISNULL(MAD.ReimShow,0) = 1)          
		   and isnull(Sal_Type,0) in (1,2)     
		Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_Date ,mad.M_AD_Flag        
               
  End        
  
 Else        

  Begin        

	If @With_Arear_Amount = 0  
		Begin
		
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date          
			   and M_AD_NOT_EFFECT_SALARY = 0          and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_Date, mad.M_AD_Flag, mad.Sal_Tran_ID       
			
			 Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.ReimAmount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))           
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
		 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
		WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) -- For_date >=@From_Date and For_date <=@To_Date          
		   and   (M_AD_NOT_EFFECT_SALARY = 1 and  ISNULL(MAD.ReimShow,0) = 1)         
		   and isnull(Sal_Type,0) in (1,2)     
		Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_Date ,mad.M_AD_Flag     
		End
	Else
		begin    
		
		   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
		   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag,sum(isnull(M_AREAR_AMOUNT,0))        
			 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
			 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
			WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date          
			   and M_AD_NOT_EFFECT_SALARY = 0     and Sal_Tran_ID is not null  
			   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
			Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.To_Date, mad.M_AD_Flag, mad.Sal_Tran_ID   

		 Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.ReimAmount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_Date,mad.M_AD_Flag ,sum(isnull(M_AREAR_AMOUNT,0))           
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
		 @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
		WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) = Month(@To_Date) and YEAR(To_date) = YEAR(@To_Date) -- For_date >=@From_Date and For_date <=@To_Date          
		   and   (M_AD_NOT_EFFECT_SALARY = 1 and  ISNULL(MAD.ReimShow,0) = 1)     
		   and isnull(Sal_Type,0) in (1,2)     
		Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_Date ,mad.M_AD_Flag     

					
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
							and isnull(T0050_AD_MASTER.Ad_Not_Effect_Salary,0) = 0 and Ad_Active = 1 
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
   --  @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID         
   -- WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date          
   --    and M_AD_NOT_EFFECT_SALARY = 0          and Sal_Tran_ID is not null  
   --    and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage >0         
   -- Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag ,mad.Sal_Tran_ID  
    
        
   end        

	
 if @Sal_Type =0         
  begin  
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I' , ms.Arear_Basic      
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    --and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date And Is_FNF = 0    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
    and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  And Is_FNF = 0         
 
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


        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
   and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)    
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   select ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I',0        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date        -- Changed By Gadriwala 12052014(Help of Hardik bhai)
   and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)
    
    -- UnCommented by Falak on 12-MAY-2011        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0       -- Changed By Gadriwala 12052014(Help of Hardik bhai) 
     and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Other_Allow_Amount,0) >0 
 
	If @With_Arear_Amount = 0
		Begin        
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
			select  ms.Emp_ID,Cmp_ID,null,'Arrear Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I',0        
			 From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
			-- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0     -- Changed By Gadriwala 12052014(Help of Hardik bhai)
			    and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Settelement_Amount,0) >0   
		End
	Else
		Begin
		
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
			select  ms.Emp_ID,MS.Cmp_ID,null,'Arrear Gross Amount',0,SUM(S_Gross_Salary),null,0,S_Eff_Date ,'I',0        
			 From T0201_MONTHLY_SALARY_SETT ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
			 and S_Eff_Date >=@From_Date and S_Eff_Date <=@To_Date 
			 And MS.Emp_ID In 
				(select  ms.Emp_ID
				From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
				--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date -- Changed By Gadriwala 12052014(Help of Hardik bhai)
				and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date))
			 Group by ms.Emp_ID,MS.Cmp_ID,S_Eff_Date
		End      
      
      
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   --  and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0    -- Changed By Gadriwala 12052014(Help of Hardik bhai)    
       and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Leave_Salary_Amount,0) >0 
     
      ----------Added by Sumit 18082015-----------------------------------------------------------------------------------------
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Amount',Sal_Tran_ID,replace(Travel_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'I',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	 and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Travel_Amount,0) >0 
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Advance Amount',Sal_Tran_ID,replace(travel_Advance_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'D',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	 and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(travel_Advance_Amount,0) >0 
	-- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
-----------Ended by Sumit 18082015-----------------------------------  
       
       
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date        -- Changed By Gadriwala 12052014(Help of Hardik bhai)
      and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)
          
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
   and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Interest',Sal_Tran_ID,Loan_Intrest_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
	and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)
	
--Mukti07042015(start) 
 Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Asset Installment Amount',Sal_Tran_ID,Asset_Installment,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
   and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)
--Mukti07042015(end)   
    
--added By Mukti(start)15062017
  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	   select ms.Emp_ID,Cmp_ID,null,'Uniform Installment Amount',Sal_Tran_ID,Uniform_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'D'       
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
	
  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Uniform Refund Amount',Sal_Tran_ID,Uniform_Refund_Amount,null,Gross_Salary,Month_end_Date ,'I'       
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
--added By Mukti(end)15062017

    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	  -- Changed By Gadriwala 12052014(Help of Hardik bhai)
					and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Bonus_Amount,0) >0	 
    
   --commented by Falak on 29-OCT-2010 as per told by nilay 
 /*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date */
     
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Late Deduction Amt',Sal_Tran_ID,ms.Late_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'D'       
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)      
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'Professional tax',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date -- Changed By Gadriwala 12052014(Help of Hardik bhai) 
     and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)
           
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    --and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)    
      and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date   -- Changed By Gadriwala 12052014(Help of Hardik bhai)     
    and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Other Dedu',Sal_Tran_ID,Other_Dedu_Amount,Other_Dedu_Amount,0,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date  -- Changed By Gadriwala 12052014(Help of Hardik bhai)
   and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  
    
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	select ms.Emp_ID,Cmp_ID,null,'Extra Absent Amount',Sal_Tran_ID,Extra_AB_Amount,Extra_AB_Amount,0,Month_end_Date ,'D'        
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date   -- Changed By Gadriwala 12052014(Help of Hardik bhai)     
	and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  
   --Added by Mihir Trivedi on 16/08/2012--------
   
   
   
  --  --Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(GatePass_Amount,0) > 0  
	 ----Added by Gadriwala Muslim 06012015- End
	 
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
				select  ms.Emp_ID,Cmp_ID,null,'Week Off Working',Sal_Tran_ID,M_WO_OT_Amount,M_WO_OT_Amount,0,Month_end_Date ,'I',0
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(M_WO_OT_Amount,0) >0 -- Changed By Gadriwala 12052014(Help of Hardik bhai)
					and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(M_WO_OT_Amount,0) >0
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)
				select  ms.Emp_ID,Cmp_ID,null,'Holiday Working',Sal_Tran_ID,M_HO_OT_Amount,M_HO_OT_Amount,0,Month_end_Date ,'I',0
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(M_HO_OT_Amount,0) >0 -- Changed By Gadriwala 12052014(Help of Hardik bhai)
					and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(M_WO_OT_Amount,0) >0
					
    --End of Added by Mihir Trivedi on 16/08/2012--------        
  end        
 else if @Sal_Type =1        
  begin        
  
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,s_Month_end_Date ,'I',0        
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date     -- Changed By Gadriwala 12052014(Help of Hardik bhai)   
	and Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date)
	
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

        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'Professional tax',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'        
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date     -- Changed By Gadriwala 12052014(Help of Hardik bhai)    
     and Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date)
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'        
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date        -- Changed By Gadriwala 12052014(Help of Hardik bhai)
  and Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date)
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'        
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date   -- Changed By Gadriwala 12052014(Help of Hardik bhai)    
   and Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date) 
  end        
 else if @Sal_Type =2        
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,l_Basic_Salary,0,L_Month_end_Date ,'I'        
    From T0200_Monthly_Salary_Leave  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and L_Month_end_Date >=@From_Date and L_Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai) 
   and Month(L_Month_end_Date) = Month(@To_Date) and YEAR(L_Month_end_Date) = YEAR(@To_Date)   

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

        
  /* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,L_PT_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_end_Date >=@From_Date and L_Month_end_Date <=@To_Date        
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,L_LWF_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_end_Date >=@From_Date and L_Month_end_Date <=@To_Date        
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,L_Revenue_Amount,null,L_Gross_Salary,L_Month_end_Date ,'D'        
    From T0200_Monthly_Salary_Leave  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and L_Month_end_Date >=@From_Date and L_Month_end_Date <=@To_Date*/        
  end        
 else        
  begin       
  
    
   
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Basic Salary',null,0,0,0,@To_Date,'I',1 From @Emp_Cons ec         
              
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
    and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)       
        
  --  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
  --  select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
  --   From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --   and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
     
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    -- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0     -- Changed By Gadriwala 12052014(Help of Hardik bhai) 
     and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)  and isnull(Settelement_Amount,0) >0 
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --   and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0       -- Changed By Gadriwala 12052014(Help of Hardik bhai) 
      and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)  and isnull(Leave_Salary_Amount,0) >0  
    
       ----------Added by Sumit 18082015-----------------------------------------------------------------------------------------
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Amount',Sal_Tran_ID,replace(Travel_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'I',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	 and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(Travel_Amount,0) >0 
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,M_Arrear_Days)        
	select ms.Emp_ID,Cmp_ID,null,'Travel Advance Amount',Sal_Tran_ID,replace(travel_Advance_Amount,'-',''),null,Gross_Salary,Month_end_Date ,'D',0
	From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
	 and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(travel_Advance_Amount,0) >0 
	-- and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
-----------Ended by Sumit 18082015-----------------------------------  
       
    
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'        
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date  -- Changed By Gadriwala 12052014(Help of Hardik bhai)
		  and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)
		  
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
	 select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
	--	and Month_end_Date >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	       -- Changed By Gadriwala 12052014(Help of Hardik bhai)
        and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date) and isnull(Bonus_Amount,0) >0
             
   /* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)        
    Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID          
    from T0200_Monthly_Salary ms Inner Join @Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp on ms.sal_Tran_Id = mlp.Sal_Tran_Id         
    inner join T0120_loan_approval la on mlp.loan_apr_ID = la.Loan_Apr_ID inner join         
    t0040_Loan_Master lm on la.loan_Id = lm.loan_Id        
    and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date */        
        
   
	     
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Professional tax',null,0,null,0,@To_Date,'D',2 From @Emp_Cons         
        
  --       --Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(GatePass_Amount,0) > 0   
				
	 ----Added by Gadriwala Muslim 06012015- End 
    Update #Pay_slip        
    set AD_Amount = Salary_amount ,         
     AD_ACtual_Amount = Basic_Salary         
    From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and         
  --   Month_end_Date >=@From_Date and Month_end_Date <=@To_Date    -- Changed By Gadriwala 12052014(Help of Hardik bhai)
     Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)    
    Where Def_ID = 1        
        
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount,         
     AD_ACtual_Amount = S_Basic_Salary         
    From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and         
  --   S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date   -- Changed By Gadriwala 12052014(Help of Hardik bhai)
    Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date)         
    Where Def_ID = 1        
                
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount,         
     AD_ACtual_Amount = L_Basic_Salary
    From #Pay_slip P inner join T0200_Monthly_Salary_Leave  ms on p.emp_ID =ms.emp_ID and         
   --  L_Month_end_Date >=@From_Date and L_Month_end_Date <=@To_Date     -- Changed By Gadriwala 12052014(Help of Hardik bhai)
     Month(L_Month_end_Date) = Month(@To_Date) and YEAR(L_Month_end_Date) = YEAR(@To_Date)      
    Where Def_ID = 1        
     
        
        
    Update #Pay_slip        
    set AD_Amount = PT_Amount ,         
     AD_Calculated_Amount = PT_Calculated_Amount         
    From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and         
   --  Month_end_Date >=@From_Date and Month_end_Date <=@To_Date  -- Changed By Gadriwala 12052014(Help of Hardik bhai)
     Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_Date) = YEAR(@To_Date)      
    Where Def_ID = 2        
             
       
    Update #Pay_slip        
    set AD_Amount =isnull(AD_Amount,0) +  S_PT_Amount ,         
     AD_Calculated_Amount = S_PT_Calculated_Amount     
    From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and         
   --  S_Month_end_Date >=@From_Date and S_Month_end_Date <=@To_Date   -- Changed By Gadriwala 12052014(Help of Hardik bhai)     
     Month(S_Month_end_Date) = Month(@To_Date) and YEAR(S_Month_end_Date) = YEAR(@To_Date) 
    Where Def_ID = 2        
        
        
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'LWF Amount',null,0,null,0,@To_DAte,'D' ,3 From @Emp_Cons         
  
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Revenue Amount',null,0,null,0,@To_DAte,'D' ,4 From @Emp_Cons         
            
          
  END         
  
 
 
 Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,
 --(AD_Name + ' (' + case when AD_MODE = '%' then cast(AD_Actual_Amount as nvarchar(20)) else '' end  + isnull(ADM.ad_mode,'Rs.') + ') ')as AD_Name ,--commented By Mukti 09122015
 (AD_Name + ' (' + case when GA.AD_MODE = '%' then cast(convert(decimal(10, 2),AD_Actual_Amount) as nvarchar(10)) else '' end  + isnull(GA.ad_mode,'Rs.') + ') ')as AD_Name , --Mukti 09122015
 ADM.AD_LEVEL ,MAD.Emp_ID,MAD.Cmp_ID, MAD.AD_ID,MAD.Sal_Tran_ID,MAD.AD_Description,MAD.AD_Amount, dbo.F_Remove_Zero_Decimal(MAD.AD_Actual_Amount) as AD_Actual_Amount,MAD.AD_Calculated_Amount ,MAD.For_Date,MAD.M_AD_Flag,MAD.Loan_Id,MAD.Def_ID, MAD.M_Arrear_Days  
-- Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name ,AD_LEVEL ,MAD.*        
      ,case when  ADM.ad_mode = '%' then
						Round(cast(((mad.AD_Actual_Amount * (select smad.AD_Actual_Amount from #Pay_slip smad where smad.Emp_ID = MAD.Emp_ID and smad.AD_Description = 'Basic Salary'))/100) as numeric(18,2)),0)
					else
						mad.AD_Actual_Amount 
					end
				 as AD_Amount_on_basic_for_per,BM.Branch_ID , Alpha_Emp_Code
   From #Pay_slip  MAD Left outer join         
     T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN         
  T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN         
   @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join         
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join         
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
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID LEFT OUTER JOIN           
	 T0120_GRADEWISE_ALLOWANCE GA WITH (NOLOCK) ON GA.AD_ID = ADM.AD_ID AND I_Q.Grd_ID = GA.Grd_ID --Mukti 09122015         
																										-- Changed By Gadriwala 12052014(Help of Hardik bhai)
  WHERE E.Cmp_ID = @Cmp_Id  and  Month(For_date) = Month(@To_Date) and YEAR(For_date) = YEAR(@To_Date) --For_date >=@From_Date and For_date <=@To_Date        
    --and MAD.AD_Amount > 0 or MAD.AD_Amount < 0 
    and MAD.ad_Amount <> 0 --added jimit 20072015
     order by Ad_name  desc  
             
           
             
 RETURN         

