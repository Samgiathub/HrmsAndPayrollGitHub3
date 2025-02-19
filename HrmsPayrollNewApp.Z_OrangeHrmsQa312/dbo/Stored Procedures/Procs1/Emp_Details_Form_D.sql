     --exec Emp_Details_Form_D @Company_Id=119,@From_Date='2021-01-01 00:00:00',@To_Date='2021-08-11 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='26003#26277#22370',@Report_Type='ESIC'
CREATE PROCEDURE [dbo].[Emp_Details_Form_D]         
  @Company_Id NUMERIC            
 ,@From_Date  DATETIME        
 ,@To_Date   DATETIME        
 ,@Branch_ID  VarChar         
 ,@Cat_ID   VarChar      
 ,@Grade_ID   VarChar        
 ,@Type_ID   VarChar        
 ,@Dept_ID   VarChar        
 ,@Desig_ID   VarChar        
 ,@Emp_ID   VarChar        
 ,@Constraint VARCHAR(MAX)        
 ,@Report_Type varchar(50)      
-- ,@is_Column  tinyint = 0        
      
AS      
begin    
SET NOCOUNT ON         
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED        
SET ARITHABORT ON       
      
  IF @Branch_ID = '0' or @Branch_ID = ''      
  SET @Branch_ID = NULL      
      
 IF @Cat_ID = '0' or  @Cat_ID = ''      
  SET @Cat_ID = NULL      
         
 IF @Type_ID = '0' or @Type_ID = ''      
  SET @Type_ID = NULL      
 IF @Dept_ID = '0' or @Dept_ID = ''      
  SET @Dept_ID = NULL      
 IF @Grade_ID = '0' or @Grade_ID = ''      
  SET @Grade_ID = NULL      
      
       
 IF @Desig_ID = '0' or @Desig_ID = ''      
  SET @Desig_ID = NULL      
       
 IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015      
  SET @Branch_ID = NULL      
 IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015      
  SET @Constraint = NULL      
       
       
  CREATE table #Emp_Cons       
 (            
  Emp_ID NUMERIC ,           
  Branch_ID NUMERIC,      
  Increment_ID NUMERIC      
 )       
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter      
    
   IF @Constraint <> ''      
  Begin        
   INSERT INTO #Emp_Cons      
   SELECT cast(data  as numeric),0,0 FROM dbo.Split(@Constraint,'#') T        
  End      
  delete from #Emp_Cons  where Branch_ID = 0 
  IF @Constraint <> ''            
   BEGIN      
           select ROW_NUMBER()over (order by Em.Emp_ID) as [Sr.No.in_Employee/Workman/Work_Register],Em.Emp_code as [Emp_Code],Em.Emp_Full_Name as [Name]
		   ,'' as [Relay_set_of_Work],
			   --(MS.Present_Days) as [Summary_No.Of_Days],
		   sum(MS.Present_Days) as [Summary_No.Of_Days], 
		   '' as [Remarks_No._Hours],'' as [Signature_of_register_Keeper]    
		   from T0080_EMP_MASTER EM    
		   inner join #Emp_Cons Ec on ec.Emp_ID=Em.Emp_ID    
		   inner join T0200_MONTHLY_SALARY MS on Em.Emp_ID=MS.Emp_ID    
           inner join T0095_INCREMENT I on I.Emp_ID = EM.emp_id      
           where   Em.Date_Of_Join<= cast(@from_date as varchar(50)) 
		   and  Em.Cmp_ID=@Company_Id 
		   --Em.Date_Of_Join   between '' + cast(@from_date as varchar(50)) + ''  and  '' + cast(@To_date as varchar(50)) + ''    
        
        group by Em.Emp_code,Em.Emp_ID,em.Emp_Full_Name    
   End     
--declare @To_date as datetime --=  getdate()      
--declare @Company_id as int --=  119      
          
 else    
 BEGIN      
 --T0080_EMP_MASTER    
 --T0200_MONTHLY_SALARY    
    select ROW_NUMBER() over (order by Em.Emp_ID) as [Sr.No.in_Employee/Workman/Work_Register],Em.Emp_code as [Emp_code],Em.Emp_Full_Name as [Emp_Full_Name],'' as [Relay_set_of_Work],
	--(MS.Present_Days) as [Summary_No.Of_Days], 
	sum(MS.Present_Days) as [Summary_No.Of_Days],     
   '' as [Remarks_No._Hours],'' as [Signature_of_register_Keeper]    
   from T0080_EMP_MASTER EM    
   inner join T0200_MONTHLY_SALARY MS on Em.Emp_ID=MS.Emp_ID    
            inner join T0095_INCREMENT I on I.Emp_ID = EM.emp_id      
           where  Em.Date_Of_Join<= cast(@from_date as varchar(50)) and  Em.Cmp_ID=@Company_Id    
		   --ms.Month_St_Date= cast(@from_date as varchar(50))  and ms.Month_End_Date= cast(@To_date as varchar(50))     
		   --Em.Date_Of_Join   between '' + cast(@from_date as varchar(50)) + '' and  '' + cast(@To_date as varchar(50)) + ''    
    
         group by Em.Emp_code,Em.Emp_ID,em.Emp_Full_Name    
          
 END        
      
    end