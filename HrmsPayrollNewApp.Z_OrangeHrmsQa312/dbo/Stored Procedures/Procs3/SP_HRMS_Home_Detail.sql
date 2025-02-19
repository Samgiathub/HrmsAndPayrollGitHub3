

--==========================================================  
--ALTER Nilay 15-May-2010  
--Description :  Import resume date into Employee Master  
--Resume Details,Qualification,Experience,and Skill Details  
---10/3/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--=========================================================  
CREATE PROCEDURE [dbo].[SP_HRMS_Home_Detail]  
    
 @Cmp_ID  numeric    
 ,@Branch_ID  numeric=0  
 ,@Cat_ID  numeric  =0  
 ,@Grd_ID  numeric =0  
 ,@Type_ID  numeric  =0
 ,@Shift_Id numeric = 0  
 ,@Dept_ID  numeric  =0  
 ,@Desig_ID  numeric =0  
 ,@Resume_ID  numeric   
 ,@Constraint varchar(5000) = ''   
 ,@Status numeric(1,0)  
 ,@emp_new_id numeric = 0  output
 AS  

--change by Falak on 29-Jul-2010
-- Added new parameter @shift_Id
   SET NOCOUNT ON
   SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   SET ARITHABORT ON
    
     if @Branch_ID = 0    
    set @Branch_ID = null    
     if @Cat_ID = 0    
    set @Cat_ID = null    
     if @Type_ID = 0    
    set @Type_ID = null    
     if @Dept_ID = 0    
    set @Dept_ID = null    
     if @Grd_ID = 0    
    set @Grd_ID = null    
     if @Resume_ID = 0    
    set @Resume_ID = null        
     If @Desig_ID = 0    
     set @Desig_ID = null    
      
   
    Declare @Bank_ID   numeric(18,0)  
   Declare @Increment_ID  numeric(18,0)  
   Declare @Emp_code   numeric(18,0)  
   Declare @Initial  varchar(10)  
   Declare @Emp_First_Name varchar(100)  
   Declare @Emp_Second_Name varchar(100)  
   Declare @Emp_Last_Name varchar(100)  
   Declare @Date_Of_Join datetime  
   Declare @Date_Of_Birth  DATETIME   
   Declare @Marital_Status varchar(20)  
   Declare @Gender   varchar(20)  
   Declare @Loc_ID   numeric(18,0)  
   Declare @Street_1  varchar(250)  
   Declare @City   varchar(30)  
   Declare @State   varchar(20)  
   Declare @Zip_code  varchar(20)  
   Declare @Home_Tel_no varchar(30)  
   Declare @Mobile_No  varchar(30)  
   Declare @Work_Email  varchar(50)  
   Declare @Other_Email varchar(50)  
   Declare @Present_Street varchar(250)  
   Declare @Present_City   varchar(30)  
   Declare @Present_State  varchar(30)  
   Declare @Present_Post_Box varchar(20)  
   Declare @Basic_Salary numeric(18,2)  
      Declare @Emp_ID numeric(18,0)  
      set @Emp_ID = 0  
  
        Declare curEmployee cursor for  
   Select  Branch_ID,Grade_ID,Type_ID,Shift_Id,Dept_ID,Desig_ID,Initial,App_First_Name,isnull(App_Middle_Name,''),App_Last_Name,Date_Of_Join,Date_Of_Birth,Marital_Status,Gender,Present_Loc,Present_Street,Present_City,Present_State,Present_Post_Box    
     ,Home_Tel_no,Mobile_No,Primary_Email,Other_Email,Present_Street,Present_City,Present_State,Present_Post_Box,Basic_Salary  
    from T0090_app_master AM WITH (NOLOCK) where AM.Cmp_ID=@Cmp_ID  and Resume_ID=@Resume_ID     
      
         open curEmployee                        
    fetch next from curEmployee into @Branch_ID,@Grd_ID,@Type_ID,@Shift_Id,@Dept_ID,@Desig_ID,@Initial, @Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_Of_Join,@Date_Of_Birth,@Marital_Status,@Gender,@Loc_ID,@Street_1,@City,@State,@Zip_code,  
             @Home_Tel_no,@Mobile_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Basic_Salary  
   While @@Fetch_Status=0   
           Begin   
   -- change by falak empcode take as joining date
    set @emp_code = dbo.F_Get_Emp_Code(@Date_Of_Join,@Cmp_Id)
    --select @emp_code as emp_code           
    exec P0080_EMP_MASTER_RECRUIT @Emp_ID output,@Cmp_ID, @Branch_ID ,  0, @Grd_ID , @Dept_ID , @Desig_ID , @Type_ID ,@Shift_Id,  0,  0, @emp_code, @Initial , @Emp_First_Name , @Emp_Second_Name , @Emp_Last_Name ,  0, @Date_Of_Join , '',  '',  '',  '', @Date_Of_Birth ,   
@Marital_Status , @Gender ,  '',  '', @Loc_ID , @Street_1 , @City , @State , @Zip_code , @Home_Tel_no , @Mobile_No ,  '', @Work_Email , @Other_Email , @Present_Street , @Present_City , @Present_State , @Present_Post_Box,  0, @Basic_Salary ,  '0.jpg',  '',  '',  '',  '', 0,  '', '',  0,  0,  0,  0,  'Inse',  0,  '',  '',  '',  '',  '',  '',  '',  '0',  1,  1,  0,  0,  0,  0,  '00:00',  '',  0,  '',  0,  0,  '',  0,  0,  1  

	set @emp_new_id = @Emp_ID
    Update T0090_App_master                   set Status=@Status where Resume_ID=@Resume_ID   
       Update T0055_Resume_master                set Resume_Status=@Status where Resume_ID=@Resume_ID   
    Update T0090_HRMS_Recruitment_Final_Score set Status=@Status where Resume_ID=@Resume_ID   
    Update T0055_HRMS_Interview_Schedule set Status=@Status where Resume_ID=@Resume_ID   
      
     
    Declare @Row_ID as numeric(18,0)  
    Declare @Qual_ID as numeric(18,0)  
    Declare @Specialization as varchar(20)  
    Declare @Year as numeric(18,2)  
    Declare @Score as numeric  
    Declare @St_Date as DateTime  
    Declare @End_Date as DateTime  
      
     
       Declare curQual cursor for  
          Select Row_ID,Cmp_id,Qual_ID,Specialization,Year,Score,isnull(St_Date,''),isnull(End_Date,'') from   
            T0090_HRMS_Resume_Qualification WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Resume_ID=@Resume_ID  
         open curQual       
            fetch next from curQual into @Row_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date  
            While @@Fetch_Status=0   
              Begin   
                             
              exec P0090_EMP_QUALIFICATION_DETAIL 0,@Emp_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date,'','I'  
                           
           fetch next from curQual into @Row_ID,@Cmp_ID,@Qual_ID,@Specialization,@Year,@Score,@St_Date,@End_Date  
                   end  
                   close curQual                      
    deallocate curQual     
      
      
    Declare @Employer as varchar(50)  
    Declare @Desig_Name as varchar(50)  
    Declare @St_Date3 as Datetime  
    Declare @Ed_Date3 as Datetime  
      
       Declare curExp cursor for  
           Select Employer_Name,Desig_Name,St_Date,End_Date from T0090_HRMS_Resume_Experience  WITH (NOLOCK)
             where Cmp_ID=@Cmp_ID and Resume_ID=@Resume_ID  
         open curExp       
            fetch next from curExp into @Employer,@Desig_name,@St_Date3,@Ed_Date3  
            While @@Fetch_Status=0   
              Begin   
                             
              exec P0090_EMP_EXPERIENCE_DETAIL 0,@Emp_ID,@Cmp_ID,@Employer,@Desig_name,@St_Date3,@Ed_Date3,'I'   
                           
           fetch next from curExp into @Employer,@Desig_name,@St_Date3,@Ed_Date3  
                   end  
                   close curExp                      
    deallocate curExp    
      
      
    Declare @Skill_ID as Numeric(18,0)  
    Declare @Skill_Comments as varchar(50)  
    Declare @Skill_Experience as Numeric(18,0)  
      
      
       Declare curSkil cursor for  
           Select Skill_ID,Skill_Comments,Skill_Experience from T0090_HRMS_Resume_Skill WITH (NOLOCK) 
             where Cmp_ID=@Cmp_ID and Resume_ID=@Resume_ID  
         open curSkil       
            fetch next from curSkil into @Skill_ID,@Skill_Comments,@Skill_Experience  
            While @@Fetch_Status=0   
              Begin   
                             
      exec P0090_Emp_Skill_Detail 0,@Emp_ID,@Cmp_ID,@Skill_ID,@Skill_Comments,@Skill_Experience,'I'  
                           
           fetch next from curSkil into @Skill_ID,@Skill_Comments,@Skill_Experience  
                   end  
                   close curSkil                      
    deallocate curSkil    
      
       
   fetch next from curEmployee into @Branch_ID,@Grd_ID,@Type_ID,@shift_Id,@Dept_ID,@Desig_ID,@Initial, @Emp_First_Name,@Emp_Second_Name,@Emp_Last_Name,@Date_Of_Join,@Date_Of_Birth,@Marital_Status,@Gender,@Loc_ID,@Street_1,@City,@State,@Zip_code,@Home_Tel_no,@Mobile_No,@Work_Email,@Other_Email,@Present_Street,@Present_City,@Present_State,@Present_Post_Box,@Basic_Salary  
     End  
 close curEmployee                      
 deallocate curEmployee          
Return  
  
  
  

