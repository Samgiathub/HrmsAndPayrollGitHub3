
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_DETAIL_GET_Small]
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
    ,@Salary_Cycle_id numeric = 0  
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
	--	    and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013            
 
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
  declare @manual_salary_Period as numeric(18,0)  
  
  --------------------- Changed By Ali 13122013 Start ---------------------------------------  
  set @manual_salary_Period = 0  
  declare @is_salary_cycle_emp_wise as tinyint   
  set @is_salary_cycle_emp_wise = 0    
  select @is_salary_cycle_emp_wise = isnull(Setting_Value,0) from T0040_SETTING WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Setting_Name = 'Salary Cycle Employee Wise'    
    
   if @is_salary_cycle_emp_wise = 1    
   BEGIN  
     
     if isnull(@Salary_Cycle_id,0) = 0
		begin
		  set @Salary_Cycle_id  = 0         
		  SELECT @Salary_Cycle_id = salDate_id from T0095_Emp_Salary_Cycle WITH (NOLOCK) where  emp_id in (SELECT Emp_id from #Emp_Cons) AND effective_date in    
		  (SELECT max(effective_date) as effective_date from T0095_Emp_Salary_Cycle WITH (NOLOCK)    
		  where emp_id in (SELECT Emp_id from #Emp_Cons) AND effective_date <=  @To_Date    
		  GROUP by emp_id)          
		 end
  SELECT @Sal_St_Date = SALARY_ST_DATE FROM t0040_salary_cycle_master WITH (NOLOCK) where tran_id = @Salary_Cycle_id   
   END  
   ELSE  
   BEGIN  
   If @Branch_ID is null    
   Begin     
      select Top 1 @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013    
   from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID        
   and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Cmp_ID = @Cmp_ID)        
   End    
  Else    
  Begin    
      select @Sal_St_Date  = Sal_st_Date ,@manual_salary_Period= isnull(manual_salary_Period ,0) -- Comment and added By rohit on 11022013    
   from T0040_GENERAL_SETTING WITH (NOLOCK) where cmp_ID = @cmp_ID and Branch_ID = @Branch_ID        
   and For_Date = ( select max(For_Date) from T0040_GENERAL_SETTING WITH (NOLOCK) where For_Date <=@To_Date and Branch_ID = @Branch_ID and Cmp_ID = @Cmp_ID)        
   End       
   END  
        
       
        
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
   if @manual_salary_Period = 0     
   Begin       
      set @Sal_St_Date =  cast(cast(day(@Sal_St_Date)as varchar(5)) + '-' + cast(datename(mm,dateadd(m,-1,@From_Date)) as varchar(10)) + '-' +  cast(year(dateadd(m,-1,@From_Date) )as varchar(10)) as smalldatetime)        
        set @Sal_End_Date = dateadd(d,-1,dateadd(m,1,@Sal_St_Date))     
        Set @From_Date = @Sal_St_Date    
        Set @To_Date = @Sal_End_Date     
    end    
  else    
   begin       
		select @Sal_St_Date=from_date,@Sal_End_Date=end_date from salary_period where month= month(@From_Date) and YEAR=year(@From_Date)                  
		Set @From_Date = @Sal_St_Date    
        Set @To_Date = @Sal_End_Date        

   End     
 End     
 --------------------- Changed By Ali 13122013 End ---------------------------------------  
		 
	 Create table #Pay_slip 
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
			Def_ID					numeric,
			S_Sal_Tran_Id			Numeric null
		)	 
	
	
		
	if @Sal_Type = 0
		begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I',1
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					 and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) 
					 	
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.To_Date,mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id  and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date) --and For_date >=@From_Date and To_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='I'	 and isnull(Sal_Type,0) =0	

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Claim Amt',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) 

				/*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'OT Amt',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date*/
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(Other_Allow_Amount,0) >0

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Settlement',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(Settelement_Amount,0) >0

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Lv Encash Amt',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(Leave_Salary_Amount,0) >0
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amt',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(Other_Dedu_Amount,0) >0
				--commented by Falak on 29-OCT-2010 as per told by nilay
				/*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amt',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0		*/
					
					Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(Bonus_Amount,0) >0

			/*	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Gross Salary',Sal_Tran_ID,Gross_Salary,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			*/		
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.sal_Tran_ID,mad.m_AD_Amount,mad.M_AD_Actual_Per_amount,mad.M_AD_Calculated_amount,mad.To_date,mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and  month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date) --For_date >=@From_Date and To_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_AD_Flag ='D' and isnull(Sal_Type,0) =0
						  
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Advance',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)
							
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)
				Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID  
				from T0200_Monthly_Salary ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp WITH (NOLOCK) on ms.sal_Tran_Id = mlp.Sal_Tran_Id 
				inner join T0120_loan_approval la WITH (NOLOCK) on mlp.loan_apr_ID = la.Loan_Apr_ID inner join 
				t0040_Loan_Master lm WITH (NOLOCK) on la.loan_Id = lm.loan_Id
				--and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date 
				and month(Loan_payment_Date) = Month(@To_Date)  and Year(Loan_payment_Date) =Year(@To_Date) --Mukti 10122015
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
					
				select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
				and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'LWF Amt',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
						and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Revenue Amt',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date)
			
				--select  ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(25)) + ' )' ,Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
				--	From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--	and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(GatePass_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(25)) + ' )' ,Sal_Tran_ID,GatePass_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and month(Month_End_Date) = Month(@To_Date)  and Year(Month_End_Date) =Year(@To_Date) and isnull(GatePass_Amount,0) >0	
			/*
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Total Deduction',Sal_Tran_ID,Total_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
			*/
			
			---added by jimit 28072017
			Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		   select ms.Emp_ID,Cmp_ID,null,'Late Deduction Amt',Sal_Tran_ID,ms.Late_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'D'
			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
			and Month(Month_End_Date) =Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date)
			--ended
			
			
			
		end
	else if @Sal_Type = 1
		begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,S_Month_end_Date ,'I',S_Sal_Tran_Id
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
					and month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date)  --and For_date >=@From_Date and For_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) in (1,2) and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_date ,mad.M_AD_Flag,S_Sal_Tran_Id

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id  and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date)  --and For_date >=@From_Date and To_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) in (1,2)and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_Date ,mad.M_AD_Flag,S_Sal_Tran_Id

				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
					
				select ms.Emp_ID,Cmp_ID,null,'PT Amt',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D',S_Sal_Tran_Id
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
					  and month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				select ms.Emp_ID,Cmp_ID,null,'LWF Amt',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D',S_Sal_Tran_Id
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
					  and month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				select ms.Emp_ID,Cmp_ID,null,'Revenue Amt',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D',S_Sal_Tran_Id
					From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date	
					and month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amt',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
				and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Other_Dedu_Amount,0) >0	
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Amount as varchar(25)) + ' )' ,Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(GatePass_Amount,0) >0	
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(GatePass_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amt',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(M_IT_Tax,0) >0
					
					Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0		
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Bonus_Amount,0) >0		
		
					
		end
	else if @Sal_Type = 2
		begin
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,L_Basic_Salary,0,L_Month_end_Date ,'I'
					From T0200_Monthly_Salary_Leave  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date
					and month(L_Month_St_DAte) = Month(@To_Date)  and Year(L_Month_end_Date) =Year(@To_Date) 
					
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id  and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date) --and For_date >=@From_Date and To_date <=@To_Date	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) = 3 and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_Date ,mad.M_AD_Flag,S_Sal_Tran_Id

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date)
						  and M_AD_NOT_EFFECT_SALARY = 0 and isnull(Sal_Type,0) = 3 and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_Date ,mad.M_AD_Flag,S_Sal_Tran_Id
					
	
		end	
	else 
		begin
		
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'Basic Salary',null,0,0,0,@To_Date,'I',1 From #Emp_Cons ec 
						
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id  and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date)	 
						  and M_AD_NOT_EFFECT_SALARY = 0  and M_Ad_Percentage =0
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_Date ,mad.M_AD_Flag,S_Sal_Tran_Id

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_Id)
				Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),max(mad.To_Date),mad.M_AD_Flag,S_Sal_Tran_Id
					 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN 
						#Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID 
					WHERE MAD.Cmp_ID = @Cmp_Id and month(To_date) = Month(@To_Date)  and Year(To_date) =Year(@To_Date)	 
						  and M_AD_NOT_EFFECT_SALARY = 0 and M_Ad_Percentage >0	
					Group by mad.emp_ID,mad.cmp_Id,mad.AD_ID ,mad.To_Date ,mad.M_AD_Flag,S_Sal_Tran_Id


				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'OT Amt',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date)
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Other_Allow_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Settlement',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0
				--	and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Settelement_Amount,0) >0
				and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Settelement_Amount,0) >0

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Lv Encash Amt',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0
					  and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Leave_Salary_Amount,0) >0

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select ms.Emp_ID,Cmp_ID,null,'Advance',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					  and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date)
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)
				Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID  
				from T0200_Monthly_Salary ms  WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp WITH (NOLOCK) on ms.sal_Tran_Id = mlp.Sal_Tran_Id 
				inner join T0120_loan_approval la WITH (NOLOCK) on mlp.loan_apr_ID = la.Loan_Apr_ID inner join 
				t0040_Loan_Master lm WITH (NOLOCK) on la.loan_Id = lm.loan_Id
				--and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date
				and month(Loan_payment_Date) = Month(@To_Date)  and Year(Loan_payment_Date) =Year(@To_Date) --Mukti 10122015
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
					select Emp_ID,@Cmp_ID,null,'PT Amt',null,0,null,0,@To_Date,'D',2 From #Emp_Cons 
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Other Amt',Sal_Tran_ID,Other_Dedu_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Dedu_Amount,0) >0	
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Other_Dedu_Amount,0) >0	
					
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'TDS Amt',Sal_Tran_ID,M_IT_Tax,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(M_IT_Tax,0) >0	
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(M_IT_Tax,0) >0
					
					Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	
										and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(Bonus_Amount,0) >0	


				Update #Pay_slip
				set AD_Amount = Salary_amount , 
					AD_ACtual_Amount = Basic_Salary 
				From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and 
					--Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					 month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date)
				Where Def_ID = 1


				Update #Pay_slip
				set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount, 
					AD_ACtual_Amount = S_Basic_Salary 
				From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and 
					--S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
					month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)
				Where Def_ID = 1
								

				Update #Pay_slip
				set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount, 
					AD_ACtual_Amount = L_Basic_Salary 
				From #Pay_slip P inner join T0200_Monthly_Salary_Leave  ms on p.emp_ID =ms.emp_ID and 
				--	L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date
				month(L_Month_end_Date) = Month(@To_Date)  and Year(L_Month_end_Date) =Year(@To_Date)
				Where Def_ID = 1


				
				Update #Pay_slip
				set AD_Amount = PT_Amount , 
					AD_Calculated_Amount = PT_Calculated_Amount 
				From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and 
					--Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date
					month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date)
				Where Def_ID = 2
					

				Update #Pay_slip
				set AD_Amount =isnull(AD_Amount,0) +  S_PT_Amount , 
					AD_Calculated_Amount = S_PT_Calculated_Amount 
				From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and 
					--S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date
					month(S_Month_end_Date) = Month(@To_Date)  and Year(S_Month_end_Date) =Year(@To_Date)
				Where Def_ID = 2


				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'LWF Amt',null,0,null,0,@To_DAte,'D' ,3 From #Emp_Cons 

				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)
				select Emp_ID,@Cmp_ID,null,'Revenue Amt',null,0,null,0,@To_DAte,'D' ,4 From #Emp_Cons 
				
				Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(25)) + ' )' ,Sal_Tran_ID,GatePass_Amount,null,0,Month_end_Date ,'D'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(GatePass_Amount,0) >0	
					and month(Month_end_Date) = Month(@To_Date)  and Year(Month_end_Date) =Year(@To_Date) and isnull(GatePass_Amount,0) >0	
				
		
		end
		
		--print  @Sal_St_Date
		--print @From_Date
		--print @To_Date
		
		--select * from #Pay_Slip
		Select MAD.*,AD_NAME,AD_SORT_NAME From #Pay_Slip  MAD  left outer  join T0050_AD_MASTER AM WITH (NOLOCK) ON MAD.AD_ID= AM.AD_ID 
		WHERE mad.Cmp_ID = @Cmp_Id	 and month(For_Date) = Month(@To_Date)  and Year(For_Date) =Year(@To_Date)-- For_date >=@From_Date and For_date <=@To_Date
			and ((MAD.AD_Amount > 0 or MAD.AD_Amount < 0 )
				OR AM.Show_In_Pay_Slip =1)  --Added by Jaina 10-04-2018
		Order by mad.Emp_ID,Row_ID 
			
			
	 
	RETURN 




