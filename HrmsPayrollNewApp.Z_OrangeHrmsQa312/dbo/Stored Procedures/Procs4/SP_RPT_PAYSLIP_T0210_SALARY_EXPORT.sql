



---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_PAYSLIP_T0210_SALARY_EXPORT]           
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment  WITH (NOLOCK)          
     where Increment_Effective_date <= @To_Date            
     and Cmp_ID = @Cmp_ID            
     group by emp_ID  ) Qry on            
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date             
                   
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
    (select emp_id, cmp_ID, join_Date, isnull(left_Date, @To_date) as left_Date from T0110_EMP_LEFT_JOIN_TRAN WITH (NOLOCK)) qry            
    where cmp_ID = @Cmp_ID   and              
    (( @From_Date  >= join_Date  and  @From_Date <= left_date )             
    or ( @To_Date  >= join_Date  and @To_Date <= left_date )            
    or Left_date is null and @To_Date >= Join_Date)            
    or @To_Date >= left_date  and  @From_Date <= left_date )             
               
               
  end            
              
              
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
   Def_ID     numeric            
  )              
             
 if @Sal_Type =3            
  set  @Sal_Type =null            
              
             
 if @Sal_Type  =1             
  begin            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
  Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag            
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN        
     @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID             
    WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date              
       and M_AD_NOT_EFFECT_SALARY = 0              
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage =0            
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag            
              
                
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag            
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN             
     @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID             
    WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date              
       and M_AD_NOT_EFFECT_SALARY = 0              
       and isnull(Sal_Type,0) in (1,2) and M_AD_Percentage >0            
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag            
                   
  end            
 else            
  begin            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),sum(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag            
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN             
     @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID             
    WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date              
       and M_AD_NOT_EFFECT_SALARY = 0              
       and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage =0            
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag            
               
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   Select mad.Emp_Id,mad.Cmp_ID,mad.AD_ID,null,sum(mad.m_AD_Amount),max(mad.M_AD_Actual_Per_amount),sum(mad.M_AD_Calculated_amount),mad.For_Date,mad.M_AD_Flag            
     From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) INNER  JOIN             
     @EMP_CONS EC ON MAD.EMP_ID = EC.EMP_ID             
    WHERE MAD.Cmp_ID = @Cmp_Id and For_date >=@From_Date and For_date <=@To_Date              
       and M_AD_NOT_EFFECT_SALARY = 0              
       and isnull(Sal_Type,0) = isnull(@Sal_Type,Sal_Type) and M_AD_Percentage >0            
    Group by Mad.Emp_ID,mad.AD_ID ,mad.Cmp_ID  ,mad.For_Date ,mad.M_AD_Flag            
   end            
              
 if @Sal_Type =0             
  begin            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',Sal_Tran_ID,Salary_amount,Basic_Salary,0,Month_end_Date ,'I'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
            
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Claim Amount',Sal_Tran_ID,Total_claim_Amount,null,Gross_Salary,Month_end_Date ,'I'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date   
    
    
     Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
  select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'            
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
     and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0             
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
  select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'            
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
     and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0            
          
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
    select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'            
     From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
     and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0            
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
               
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Loan Amount',Sal_Tran_ID,Loan_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
               
               
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
                
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',Sal_Tran_ID,PT_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
               
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'LWF Amount',Sal_Tran_ID,LWF_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
            
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',Sal_Tran_ID,Revenue_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
                
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Other Dedu',Sal_Tran_ID,Other_Dedu_Amount,Other_Dedu_Amount,0,Month_end_Date ,'D'            
    From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
                
  end            
 else if @Sal_Type =1            
  begin            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,S_Salary_amount,S_Basic_Salary,0,s_Month_end_Date ,'I'            
    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
                
   select ms.Emp_ID,Cmp_ID,null,'PT Amount',null,S_PT_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'            
    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
               

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
  		 select ms.Emp_ID,Cmp_ID,null,'LWF Amount',null,S_LWF_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'            
			    From T0201_Monthly_Salary_Sett ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
				    and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
            

   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
			   select ms.Emp_ID,Cmp_ID,null,'Revenue Amount',null,S_Revenue_Amount,null,S_Gross_Salary,S_Month_end_Date ,'D'            
				    From T0201_Monthly_Salary_Sett  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
					    and S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
  end            

 else if @Sal_Type =2            
 
 begin            
   Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   			select ms.Emp_ID,Cmp_ID,null,'Basic Salary',null,L_Salary_amount,l_Basic_Salary,0,L_Month_end_Date ,'I'            
   					 From T0200_Monthly_Salary_Leave  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
   						 and L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date            
            
            
  end            
 else            
  begin            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)            
   		 select Emp_ID,@Cmp_ID,null,'Basic Salary',null,0,0,0,@To_Date,'I',1 From @Emp_Cons ec             
                  
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   		 select  ms.Emp_ID,Cmp_ID,null,'OT Amount',Sal_Tran_ID,OT_Amount,null,Gross_Salary,Month_end_Date ,'I'            
     			From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
     				and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   		 select  ms.Emp_ID,Cmp_ID,null,'Arrears',Sal_Tran_ID,Other_Allow_Amount,null,0,Month_end_Date ,'I'            
    			 From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    				 and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Other_Allow_Amount,0) >0            
    				 
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   		 select  ms.Emp_ID,Cmp_ID,null,'Settlement Amount',Sal_Tran_ID,Settelement_Amount,null,0,Month_end_Date ,'I'            
    			 From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    				 and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Settelement_Amount,0) >0            
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
  	  select  ms.Emp_ID,Cmp_ID,null,'Leave Encash Amount',Sal_Tran_ID,Leave_salary_Amount,null,0,Month_end_Date ,'I'            
   			  From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
    				 and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date and isnull(Leave_Salary_Amount,0) >0            
            
            
            
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag)            
   		 select ms.Emp_ID,Cmp_ID,null,'Advance Amount',Sal_Tran_ID,Advance_Amount,null,Gross_Salary,Month_end_Date ,'D'            
    			 From T0200_Monthly_Salary  ms WITH (NOLOCK) Inner Join @Emp_Cons ec on ms.Emp_ID =ec.emp_ID             
     				and Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
                 
             
                
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)            
     select Emp_ID,@Cmp_ID,null,'PT Amount',null,0,null,0,@To_Date,'D',2 From @Emp_Cons             
            
            
    Update #Pay_slip            
        set AD_Amount = Salary_amount ,             
            AD_ACtual_Amount = Basic_Salary             
        From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and             
            Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
        Where Def_ID = 1            
            
            
    Update #Pay_slip            
        set AD_Amount = isnull(AD_Amount,0) + S_Salary_Amount,             
            AD_ACtual_Amount = S_Basic_Salary             
        From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and             
            S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
        Where Def_ID = 1            
                    
            
    Update #Pay_slip            
       set AD_Amount = isnull(AD_Amount,0) + L_Salary_Amount,             
           AD_ACtual_Amount = L_Basic_Salary             
       From #Pay_slip P inner join T0200_Monthly_Salary_Leave  ms on p.emp_ID =ms.emp_ID and             
           L_Month_St_DAte >=@From_Date and L_Month_end_Date <=@To_Date            
       Where Def_ID = 1            
            
            
                
    Update #Pay_slip            
      set AD_Amount = PT_Amount ,             
         AD_Calculated_Amount = PT_Calculated_Amount             
      From #Pay_slip P inner join T0200_Monthly_Salary  ms on p.emp_ID =ms.emp_ID and             
      Month_St_DAte >=@From_Date and Month_end_Date <=@To_Date            
      Where Def_ID = 2            
                 
         
    Update #Pay_slip            
      set AD_Amount =isnull(AD_Amount,0) +  S_PT_Amount ,             
        AD_Calculated_Amount = S_PT_Calculated_Amount             
      From #Pay_slip P inner join T0201_Monthly_Salary_Sett  ms on p.emp_ID =ms.emp_ID and             
        S_Month_St_DAte >=@From_Date and S_Month_end_Date <=@To_Date            
      Where Def_ID = 2            
            
            
                
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)            
    select Emp_ID,@Cmp_ID,null,'LWF Amount',null,0,null,0,@To_DAte,'D' ,3 From @Emp_Cons             
      
    Insert into #Pay_slip (Emp_ID,Cmp_ID,AD_ID,AD_Description,Sal_Tran_ID,AD_Amount,AD_ACtual_Amount,AD_Calculated_Amount,For_Date,M_AD_Flag,Def_ID)            
    select Emp_ID,@Cmp_ID,null,'Revenue Amount',null,0,null,0,@To_DAte,'D' ,4 From @Emp_Cons             
                
              
  end             
             
/*Select Emp_full_Name,Grd_Name,Comp_Name,Branch_Address,EMP_CODE,Type_Name,Dept_Name,Desig_Name,AD_Name,AD_LEVEL ,MAD.*            
                
   From #Pay_slip  MAD Left outer join             
     T0050_AD_MASTER ADM ON MAD.AD_ID = ADM.AD_ID INNER JOIN             
  T0080_EMP_MASTER E on MAD.emp_ID = E.emp_ID INNER  JOIN             
   @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID inner join             
   ( select I.Emp_Id , Grd_ID,Branch_ID,Cat_ID,Desig_ID,Dept_ID,Type_ID,Increment_effective_Date from T0095_Increment I inner join             
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment            
     where Increment_Effective_date <= @To_Date            
     and Cmp_ID = @Cmp_ID            
     group by emp_ID  ) Qry on            
     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date  ) I_Q             
    on E.Emp_ID = I_Q.Emp_ID  inner join            
     T0040_GRADE_MASTER GM ON I_Q.Grd_ID = GM.Grd_ID LEFT OUTER JOIN            
     T0040_TYPE_MASTER ETM ON I_Q.Type_ID = ETM.Type_ID LEFT OUTER JOIN            
     T0040_DESIGNATION_MASTER DGM ON I_Q.Desig_Id = DGM.Desig_Id LEFT OUTER JOIN            
     T0040_DEPARTMENT_MASTER DM ON I_Q.Dept_Id = DM.Dept_Id Inner join             
     T0030_Branch_Master BM on I_Q.Branch_ID = BM.Branch_ID              
                 
  WHERE E.Cmp_ID = @Cmp_Id  and For_date >=@From_Date and For_date <=@To_Date            
    and MAD.AD_Amount > 0 or MAD.AD_Amount < 0  order by Ad_name  desc    */  


    Select Case When AD_Name Is Not Null Then AD_Name Else AD_Description End As AD_Name,   
			 Sum(MAD.AD_Amount) As AD_Amount  ,MAD.M_AD_Flag
		         From #Pay_slip MAD   
		 Left Outer Join T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID   
		 Inner Join T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID   
		 Inner Join @EMP_CONS EC ON E.EMP_ID = EC.EMP_ID   
		 Inner Join (Select I.Emp_Id, Grd_ID, Branch_ID, Cat_ID, Desig_ID, Dept_ID,   
				     Type_ID, Increment_effective_Date   
				     From T0095_Increment I   WITH (NOLOCK)
				     Inner Join (Select max(Increment_effective_Date) as For_Date, Emp_ID   
		             From T0095_Increment  WITH (NOLOCK) 
		             Where Increment_Effective_date <= @To_Date And Cmp_ID = @Cmp_ID   
		             Group by emp_ID) Qry on   
			     I.Emp_ID = Qry.Emp_ID and I.Increment_effective_Date = Qry.For_Date) I_Q on   
		 E.Emp_ID = I_Q.Emp_ID  
		 Inner Join T0040_GRADE_MASTER GM WITH (NOLOCK) ON I_Q.Grd_ID = GM.Grd_ID  
		 Left Outer Join T0040_TYPE_MASTER ETM WITH (NOLOCK) ON I_Q.Type_ID = ETM.Type_ID  
		 Left Outer Join T0040_DESIGNATION_MASTER DGM WITH (NOLOCK) ON I_Q.Desig_Id = DGM.Desig_Id  
		 Left Outer Join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) ON I_Q.Dept_Id = DM.Dept_Id  
		 Inner Join T0030_Branch_Master BM WITH (NOLOCK) on I_Q.Branch_ID = BM.Branch_ID  
		 Where E.Cmp_ID = @Cmp_Id And For_date >= @From_Date And For_date <= @To_Date And  
			 (MAD.AD_Amount > 0 Or MAD.AD_Amount < 0)  
			  Group By Case When AD_Name Is Not Null Then AD_Name Else AD_Description End  ,M_AD_Flag
			  Order by Sum(MAD.AD_Amount) Desc, Ad_name Asc  
  
	RETURN  
  



