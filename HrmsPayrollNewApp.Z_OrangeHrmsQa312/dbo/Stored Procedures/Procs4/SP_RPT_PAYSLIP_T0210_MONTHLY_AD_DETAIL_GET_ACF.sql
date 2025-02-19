
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_T0210_MONTHLY_AD_DETAIL_GET_ACF]        
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
 --  and ISNULL(Segment_ID,0) = ISNULL(@Segment_Id,Isnull(Segment_ID,0))	 -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(Vertical_ID,0) = ISNULL(@Vertical_Id,isnull(Vertical_ID,0))	 -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(SubVertical_ID,0) = ISNULL(@SubVertical_ID,isnull(SubVertical_ID,0)) -- Added By Gadriwala Muslim 26072013
 --  and ISNULL(subBranch_ID,0) = ISNULL(@SubBranch_Id,isnull(subBranch_ID,0)) -- Added By Gadriwala Muslim 01082013          
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
   Def_ID     numeric,     
   S_Sal_Tran_ID    numeric NULL   
  )          
        
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
        
         
 if @Sal_Type =3        
  set  @Sal_Type =null        
          
         
 if @Sal_Type  =1         
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID)        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,S_Sal_Tran_ID       
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) =Month(@To_Date) and Year(To_date) = Year(@To_Date)--For_date >=@From_Date and For_date <=@To_Date          
       and M_AD_NOT_EFFECT_SALARY = 0          
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage =0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag  ,S_Sal_Tran_ID        
          
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID)        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag ,S_Sal_Tran_ID         
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) =Month(@To_Date) and Year(To_date) = Year(@To_Date) --For_date >=@From_Date and For_date <=@To_Date          
       and M_AD_NOT_EFFECT_SALARY = 0          
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag ,S_Sal_Tran_ID         
               
  end        
 else        
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,S_Sal_Tran_ID        
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) =Month(@To_Date) and Year(To_date) = Year(@To_Date) --For_date >=@From_Date and For_date <=@To_Date          
       and M_AD_NOT_EFFECT_SALARY = 0        and Sal_Tran_ID is not null  
       and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage =0        
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag  ,S_Sal_Tran_ID      
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag,S_Sal_Tran_ID          
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
     #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
    WHERE MAD.Cmp_ID = @Cmp_Id and Month(To_date) =Month(@To_Date) and Year(To_date) = Year(@To_Date)--For_date >=@From_Date and For_date <=@To_Date          
       and M_AD_NOT_EFFECT_SALARY = 0          and Sal_Tran_ID is not null  
       and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage >0         
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.To_date ,mad.M_AD_Flag  ,S_Sal_Tran_ID
	
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,mad.Sal_Tran_ID,sum(mad.ReimAmount + mad.M_AD_Actual_Per_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.To_date,mad.M_AD_Flag-- ,S_Sal_Tran_ID       
		 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN         
		 #Emp_Cons EC ON MAD.EMP_ID = EC.EMP_ID         
		WHERE MAD.Cmp_ID = @Cmp_Id  and Month(To_Date) =Month(@To_Date) and Year(To_Date) = Year(@To_Date)          
		   and (M_AD_NOT_EFFECT_SALARY = 1 and MAD.reimShow= 1)      and Sal_Tran_ID is not null  
		   and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) --and M_AD_Percentage =0        
		Group by Mad.Emp_ID,mad.AD_ID, mad.Cmp_ID, mad.to_Date, mad.M_AD_Flag, mad.Sal_Tran_ID          
   end        
          
 if @Sal_Type =0         
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
      and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)  
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
      and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
         
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date   
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)   

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Weekoff OT Amount',Sal_Tran_ID,M_WO_OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date      
   and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)   


   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Holiday OT Amount',Sal_Tran_ID,M_HO_OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date      
and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) 
    
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0   
   and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)  and isnull(Other_Allow_Amount,0) >0      
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0        
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Settelement_Amount,0) >0  
      
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0        
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Leave_Salary_Amount,0) >0     
     
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
   
--added By Mukti(start)25032015
  Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
	   select ms.Emp_ID,Cmp_ID,null,'Asset Installment Amount',Sal_Tran_ID,Asset_Installment,null,Gross_Salary,Month_end_Date ,'D'        
		From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
--added By Mukti(end)25032015 
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date    
  and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
  
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Loan Interest',Sal_Tran_ID,Loan_Intrest_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date    
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
    
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
				--	and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	 
				    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Bonus_Amount,0) >0
    
    --commented by Falak on 29-OCT-2010 as per told by nilay
     /*Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'TDS Amount',Sal_Tran_ID,M_IT_Tax,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date */
           
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
            
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
   and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
           
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)   
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date    
  and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)    
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Other Dedu',Sal_Tran_ID,Other_Dedu_Amount,Other_Dedu_Amount,0,Month_end_Date ,'D'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
 --   and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date        
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)       
     
  --   --Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date)  and isnull(GatePass_Amount,0) > 0   
	 ----Added by Gadriwala Muslim 06012015- End 
	 
	 --added by jimit 28062017
	Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Late Deduction Amt',Sal_Tran_ID,ms.Late_Dedu_Amount,null,Gross_Salary,Month_end_Date ,'D'
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    and Month(Month_End_Date) = Month(@To_Date) and Year(Month_End_Date) = Year(@To_Date) 
	---ended
  end        
 else if @Sal_Type =1        
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,s_Month_end_Date ,'I' ,S_Sal_Tran_ID         
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date   
   and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)     
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
            
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D',S_Sal_Tran_ID          
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date  
   and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)      
           
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D' ,S_Sal_Tran_ID         
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
      and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,S_Sal_Tran_ID  )        
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D' ,S_Sal_Tran_ID         
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    --and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date        
    and Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
  end        
 else if @Sal_Type =2        
  begin        
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,l_Basic_Salary,0,L_Month_end_Date ,'I'        
    From T0200_Monthly_Salary_Leave  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    --and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date        
    and Month(L_Month_end_Date) =Month(@To_Date) and Year(L_Month_end_Date) = Year(@To_Date)
        
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
    -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date    
    and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)    

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Weekoff OT Amount',Sal_Tran_ID,M_WO_OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --  and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date      
	and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
	
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
   select ms.Emp_ID,Cmp_ID,null,'Holiday OT Amount',Sal_Tran_ID,M_HO_OT_Amount,null,Gross_Salary,Month_end_Date ,'I'        
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
   -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date      
   and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)

        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0  
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Other_Allow_Amount,0) >0  
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
    -- and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0        
       and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Settelement_Amount,0) >0  
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
  --   and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0        
        and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Leave_Salary_Amount,0) >0 
        
        
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
     
     --added By Mukti(start)26032015 
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
    select ms.Emp_ID,Cmp_ID,null,'Asset Installment Amount',Sal_Tran_ID,Asset_Installment,null,Gross_Salary,Month_end_Date ,'D'        
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
     --and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date 
     and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
     --added By Mukti(end)26032015
     
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)
				select  ms.Emp_ID,Cmp_ID,null,'Bonus',Sal_Tran_ID,Bonus_Amount,null,0,Month_end_Date ,'I'
					From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID 
					--and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Bonus_Amount,0) >0	       
					  and Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date) and isnull(Bonus_Amount,0) >0
					  
   /* Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Loan_ID)        
    Select ms.Emp_ID ,ms.Cmp_ID,null,Loan_Name,ms.Sal_Tran_ID,Loan_Pay_Amount,null,Gross_Salary,Month_end_Date ,'D',La.loan_ID          
    from T0200_Monthly_Salary ms Inner Join #Emp_Cons ec on ms.Emp_ID = ec.emp_ID inner join T0210_monthly_loan_payment  mlp on ms.sal_Tran_Id = mlp.Sal_Tran_Id         
    inner join T0120_loan_approval la on mlp.loan_apr_ID = la.Loan_Apr_ID inner join         
    t0040_Loan_Master lm on la.loan_Id = lm.loan_Id        
    and Loan_payment_Date >=@From_Date and Loan_payment_Date <=@To_Date */        
            
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
     select Emp_ID,@Cmp_ID,null,'PT Amount',null,0,null,0,@To_Date,'D',2 From #Emp_Cons         
        
  ----Added by Gadriwala Muslim 06012015- Start
		--Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)        
		--	select ms.Emp_ID,Cmp_ID,null,'Gate Pass Amount( ' + cast(GatePass_Deduct_Days as varchar(10)) + ' )' ,Sal_Tran_ID,GatePass_Amount,GatePass_Amount,0,Month_end_Date ,'D'        
		--	    From T0200_Monthly_Salary  ms Inner Join #Emp_Cons ec on ms.Emp_ID =ec.emp_ID         
		--		and Month(Month_end_Date) = Month(@To_Date) and YEAR(Month_end_date) = YEAR(@To_Date) and isnull(GatePass_Amount,0) > 0   
  ----Added by Gadriwala Muslim 06012015- End 
	   
    Update #Pay_slip        
    set AD_Amount = Salary_amount ,         
     AD_ACtual_Amount = Basic_Salary         
    From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and         
     --Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date       
      Month(Month_end_Date) =Month(@To_Date) and Year(Month_end_Date) = Year(@To_Date)
    Where Def_ID = 1        
        
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount,         
     AD_ACtual_Amount = S_Basic_Salary         
    From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and         
   --  S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date   
   Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)     
    Where Def_ID = 1        
                
        
    Update #Pay_slip        
    set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount,         
     AD_ACtual_Amount = L_Basic_Salary         
    From #Pay_slip P inner join T0200_Monthly_Salary_Leave  ms on p.emp_ID =ms.emp_ID and         
    -- L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date    
     Month(L_Month_end_Date) =Month(@To_Date) and Year(L_Month_end_Date) = Year(@To_Date)    
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
   --  S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date       
    Month(S_Month_end_Date) =Month(@To_Date) and Year(S_Month_end_Date) = Year(@To_Date)
    Where Def_ID = 2        
        
        
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'LWF Amount',null,0,null,0,@To_DAte,'D' ,3 From #Emp_Cons         
  
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)        
    select Emp_ID,@Cmp_ID,null,'Revenue Amount',null,0,null,0,@To_DAte,'D' ,4 From #Emp_Cons         
            
          
  end         
  

         
 Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name, AD_Name ,AD_LEVEL ,
 MAD.Emp_ID,MAD.Cmp_ID,MAd.AD_ID,MAD.Sal_Tran_ID,Mad.AD_Description,MAd.AD_Amount,dbo.F_Remove_Zero_Decimal(Mad.AD_Actual_Amount) as AD_Actual_Amount,MAd.AD_Calculated_Amount,
 Mad.For_Date,Mad.M_AD_Flag,Mad.Loan_Id,Mad.Def_ID        
 --(AD_Name + ' (' + isnull(ADM.ad_mode,'Rs.') + ') ')as
   , ( dbo.F_Remove_Zero_Decimal(MAD.Ad_Actual_Amount) + ' ' + isnull(ADM.ad_mode,'Rs.')) as Ad_New ,
   s_Sal_Tran_Id   
   From #Pay_slip  MAD Left outer join         
     T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN         
  T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID INNER  JOIN         
   #Emp_Cons EC ON E.EMP_ID = EC.EMP_ID inner join         
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I WITH (NOLOCK) inner join         
     ( select max(Increment_ID) as Increment_ID , Emp_ID from T0095_Increment  WITH (NOLOCK)      
     where Increment_Effective_date <= @To_Date        
     and Cmp_ID = @Cmp_ID        
     group by emp_ID  ) Qry on        
     I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID  ) I_Q         
    on E.Emp_ID = I_Q.Emp_ID  inner join        
     T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN        
     T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN        
     T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN        
     T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id Inner join         
     T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID          
             
  WHERE E.Cmp_ID = @Cmp_Id  and Month(For_date) =Month(@To_Date) and Year(For_date) = Year(@To_Date) --For_date >=@From_Date and For_date <=@To_Date        
    and ((MAD.AD_Amount > 0 or MAD.AD_Amount < 0 ) 
		or ADM.Show_In_Pay_Slip = 1 ) --Added by Jaina 10-04-2018
     order by Ad_name  desc  
             
           
             
 RETURN 
