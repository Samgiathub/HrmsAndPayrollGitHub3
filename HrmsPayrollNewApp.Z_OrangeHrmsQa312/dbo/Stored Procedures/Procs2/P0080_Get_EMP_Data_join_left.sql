-- =============================================            
-- Author:  <Yogesh Patel>            
-- Create date: <03-01-2024,,>            
-- Description: <For Wonder Home finance POST API,,>            
-- =============================================            
            
CREATE  PROCEDURE [dbo].[P0080_Get_EMP_Data_join_left]            
 -- Add the parameters for the stored procedure here            
  @Cmp_ID as varchar(max)=''       
             
  AS            
  BEGIN            
 -- set @Cmp_ID=('187,120')         
        
  select       
      
   em.Cmp_Id      
  ,em.emp_id  
  ,em.Emp_First_Name as firstName  
  ,em.Emp_Last_Name as lastName  
  ,em.Work_Email as emailAddress  
  ,dm.Desig_Name as designation            
  ,bm.Branch_Name as branchName  
  ,em.Emp_code as employeeCode            
  ,dp.Dept_Name as buisness  
  ,isnull(em.Mobile_No,0) as associatedPhoneNumber  
  ,(select em.Work_Email where em.Emp_Superior= em.Emp_Superior) as managerUser  
  ,em.Emp_Left as deactivation    
  
  --,'TPC'as CmpCode    
  ,Case When em.cmp_id=5 then 'WHFL' else 'TPC' end as CmpCode  
  
--  ,le.Left_Date as leftDate      
,em.System_Date_Join_left as leftDate      
  
  into #Emp_temp from T0080_Emp_master Em              
  left join  T0100_LEFT_EMP LE on em.Emp_ID=le.Emp_ID            
  inner join T0095_INCREMENT ic on IC.emp_id=em.emp_id            
  and ic.Increment_Effective_Date= (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=em.Emp_ID)            
  inner join T0040_DESIGNATION_MASTER DM  on ic.Desig_Id=dm.Desig_ID            
  inner join T0030_BRANCH_MASTER BM on bm.Branch_ID=ic.Branch_ID            
  left join T0040_DEPARTMENT_MASTER DP on dp.Dept_Id=ic.Dept_ID            
  left join T0011_LOGIN LG on lg.Emp_ID=em.Emp_Superior            
  where  --convert(varchar(50),em.Cmp_ID) in (@Cmp_ID) --and em.Cmp_ID!=0 and  
   em.cmp_id!=6 and  
   
  --convert(date,em.Date_Of_Join,103) between convert(date,getdate(),103) and convert(date,getdate(),103)            
  --or convert(date,le.Left_Date,103) between convert(date,getdate(),103) and convert(date,getdate(),103)
    convert(date,(select em.System_Date_Join_left where  isnull(em.Emp_Left_Date,'')=''),103) between convert(date,getdate(),103) and convert(date,getdate(),103)            
  or convert(date,(select em.System_Date_Join_left where em.Emp_Left_Date= le.Left_Date),103) between convert(date,getdate(),103) and convert(date,getdate(),103)
  
    
          
   --select * from #Emp_temp      
 -- return      
 --============================================Check New join==============================================================          
          
    SELECT *,'I' as 'Status'          
   into #New_Emp_data FROM   #Emp_temp A          
   WHERE  NOT EXISTS (SELECT 1           
          FROM   T0080_Get_EMP_Data_join_left B          
          WHERE  A.Emp_ID = B.Emp_ID ) and deactivation in ('N','Y')          
          
--============================================Check left emp==============================================================                 
          
   SELECT *,'U' as 'Status'          
   into #Old_Emp_data FROM   #Emp_temp A          
   WHERE   EXISTS (SELECT 1           
          FROM   T0080_Get_EMP_Data_join_left B          
          WHERE  A.Emp_ID = B.Emp_ID ) and deactivation='Y'          
--===============================================check left rejoin emp ===========================================================          
   SELECT *,'OU' as 'Status'          
   into #Old_Update_Emp_data FROM   #Emp_temp A          
   WHERE   EXISTS (SELECT 1           
          FROM   T0080_Get_EMP_Data_join_left B          
          WHERE  A.Emp_ID = B.Emp_ID and a.deactivation!=b.designation and b.deactivation='Y') and deactivation='N'          
          
              
          
  --==============================================FINAL RESPONSE=======================================================================================          
  -- SELECT   
  --ROW_NUMBER() OVER(PARTITION BY cmp_id ORDER BY employeeCode ASC) as Rno   
  --,firstName  
  --,lastname  
  --,emailaddress  
  --,designation  
  ----,Upper(branchName)as branchName  
  --,'REGISTERED AND HEAD OFFICE' as branchName  
  --,employeeCode  
  --,'DIRECT' as buisness  
  --,associatedPhoneNumber  
  ----,managerUser  
  --,'shubham.jain2@wonderhfl.com' as managerUser  
  --,Case When deactivation='Y' then 'Yes' else 'No' end as deactivation  
  --,cmpCode as companyCode  
  --,CONVERT(varchar,leftDate,103) as LWD  
  
  SELECT   
  ROW_NUMBER() OVER(PARTITION BY cmp_id ORDER BY employeeCode ASC) as Rno   
  ,firstName  
  ,lastName  
  ,emailAddress  
  ,designation  
  ,Upper(branchName)as branchName  
  ,employeeCode  
  ,'DIRECT' as buisness  
  ,associatedPhoneNumber  
  ,managerUser  
  ,Case When deactivation='Y' then 'Yes' else 'No' end as deactivation  
  ,cmpCode as companyCode  
  ,CONVERT(varchar,leftDate,103) as LWD  
  
   FROM   #Emp_temp A          
   WHERE  NOT EXISTS (SELECT 1           
          FROM   T0080_Get_EMP_Data_join_left B          
          WHERE  A.Emp_ID = B.Emp_ID AND A.deactivation=B.deactivation)         
--==============================================FINAL RESPONSE=======================================================================================          
          
  --=======================================insert new join emp===================================================================          
  --Insert Process              
   if (select Count(*) from #New_Emp_data) >0           
   begin          
   insert into T0080_Get_EMP_Data_join_left (cmpCode,Emp_id,firstname,lastname,emailaddress,designation,branchname,employeecode,buisness,associtedphoneNumber,manageruser,deactivation,leftdate,status,Created_Date,Modify_Date)          
   (select cmpCode,emp_id ,firstName,lastName,emailAddress,designation,branchName,employeeCode,buisness,isnull(associatedPhoneNumber,0) ,manageruser,deactivation,leftDate,status,Getdate(),Getdate() from #New_Emp_data)          
   end          
            
  --Update Process           
  --============================================update left emp==============================================================          
   if (select Count(*) from #Old_Emp_data) >0           
   begin           
          
   update  T0080_Get_EMP_Data_join_left          
   set           
   deactivation='Y' ,status='U',Modify_Date=getdate()  where Emp_id in (select Emp_id from #Old_Emp_data)          
   end          
   --===========================================update left rejoin emp===============================================================          
   if (select Count(*) from #Old_Update_Emp_data) >0           
   begin           
          
   update  T0080_Get_EMP_Data_join_left          
   set           
   deactivation='N' , status='OU',Modify_Date=getdate() where Emp_id in (select Emp_id from #Old_Update_Emp_data)          
   end          
  --==========================================================================================================          
          
            
          
          
          
          
  --select fisrtname,lastname,emailaddress,designation,branchName,employeeCode,buisness,associatedPhoneNumber,managerUser,deactivation from #Emp_temp            
  drop table #Emp_temp  ,#Old_Emp_data,#New_Emp_data          
  END 