



---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GRAPHICS_REPORT_YEARLY3]  
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
 ,@constraint  varchar(4000)  
 ,@Report_Call varchar(20)='Net Salary'  
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
     ( select max(Increment_effective_Date) as For_Date , Emp_ID from T0095_Increment WITH (NOLOCK) 
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
     
  Declare @Month numeric   
  Declare @Year numeric    
  if exists (select * from [tempdb].dbo.sysobjects where name like '#Yearly_Salary' )    
   begin  
    drop table #Yearly_Salary   
   end  
      
  CREATE table #Yearly_Salary   
   (  
    Row_ID   numeric IDENTITY (1,1) not null,  
    Cmp_ID   numeric ,  
    Emp_Id   numeric ,  
    Def_ID   Numeric ,  
    Lable_Name  varchar(100),  
    Month_1   numeric default 0,  
    Month_2   numeric default 0,  
    Month_3   numeric default 0,  
    Month_4   numeric default 0,  
    Month_5   numeric default 0,  
    Month_6   numeric default 0,  
    Month_7   numeric default 0,  
    Month_8   numeric default 0,  
    Month_9   numeric default 0,  
    Month_10  numeric default 0,  
    Month_11  numeric default 0,  
    Month_12  numeric default 0,  
    Total   numeric default 0,  
    AD_ID   numeric,   
    LOAN_ID   NUMERIC,  
    CLAIM_ID  NUMERIC  
   )  
   
   CREATE table #Yearly_Salary_Report   
   (  
       PF numeric(18,2),  
       Month_1  Varchar(50)         
   )   
     
  
  
   insert into #Yearly_Salary (Cmp_ID,Emp_ID,Def_ID,Lable_Name)  
   select @Cmp_ID,emp_ID,20,'PT' From @Emp_Cons   
   

     
  declare @Temp_Date datetime  
  Declare @count numeric   
  set @Temp_Date = @From_Date   
  set @count = 1   
  while @Temp_Date <=@To_Date   
   Begin  
     set @Month =month(@Temp_date)  
     set @Year = year(@Temp_Date)  
        
    if @count = 1   
     begin  
                            
      Update #Yearly_Salary    
      set Month_1 = PT_Amount
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
       
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
  
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
        
      Select sum(Month_1) as PF,'Jan' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
     end  
  
    else if @count = 2  
     begin  
        
                              
     Update #Yearly_Salary    
      set Month_2 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
        
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  

     insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_2) as PF,'Feb' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
        
  
     end   
    else if @count = 3  
     begin  
       
      Update #Yearly_Salary    
      set Month_3 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
       
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20        
        
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_3) as PF,'Mar' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
     end   
    else if @count = 4  
     begin  
                                    
      Update #Yearly_Salary    
      set Month_4 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
       
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
  
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_4) as NetAmount,'Apri' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
               
     end   
    else if @count = 5  
     begin  
                                                      
      Update #Yearly_Salary    
      set Month_5 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
      
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
  
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_5) as PF,'May' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
        
  
     end   
    else if @count = 6  
     begin  
                        
      Update #Yearly_Salary    
      set Month_6 = PT_Amount 
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
      
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
  
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_6) as PF,'June' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
  
     end   
    else if @count = 7  
     begin  
        
      Update #Yearly_Salary    
      set Month_7 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
      
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_7) as PF,'July' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
  
     end   
    else if @count = 8  
     begin  
      Update #Yearly_Salary    
      set Month_8 = PT_Amount 
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
       
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_8) as PF,'Aug' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
        
     end   
    else if @count = 9  
     begin  
                     
     Update #Yearly_Salary    
      set Month_9 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
       
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_9) as PF,'Sept' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
       
     end   
    else if @count = 10  
     begin        
                           
     Update #Yearly_Salary    
      set Month_10 = PT_Amount 
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
      
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20         
         
       
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_10) as PF,'Oct' from  #Yearly_Salary where Cmp_id=@Cmp_ID        
        
     end   
    else if @count = 11  
     begin  
        
                              
       
     Update #Yearly_Salary    
      set Month_11 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
    
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_11) as PF,'Nov' from  #Yearly_Salary where Cmp_id=@Cmp_ID   
         
       
        
     end   
    else if @count = 12  
     begin  
        
  
  
       Update #Yearly_Salary    
      set Month_12 = PT_Amount  
      From #Yearly_Salary  Ys  inner join T0200_Monthly_Salary ms on ys.emp_ID = ms.emp_ID   
        
      Where Month(Month_ST_Date) = @Month and Year(Month_ST_Date) = @Year  
       and Def_ID = 20  
         
      insert into #Yearly_Salary_Report(PF,Month_1)  
      Select sum(Month_12) as PF,'Dec' from  #Yearly_Salary where Cmp_id=@Cmp_ID  
         
       
        
     end        
                                     
    set @Temp_Date = dateadd(m,1,@Temp_date)  
    set @count = @count + 1    
   End  
   
   Select * from #Yearly_Salary_Report  
        
 RETURN




