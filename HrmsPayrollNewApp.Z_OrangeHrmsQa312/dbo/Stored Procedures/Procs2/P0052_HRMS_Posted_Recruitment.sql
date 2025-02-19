---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0052_HRMS_Posted_Recruitment]    
 @Rec_Post_Id    numeric(18,0) output    
,@cmp_id    numeric(18,0)    
,@Rec_Req_ID   numeric(18,0)    
,@Rec_Post_Code   varchar(50) output    
,@Rec_Post_date   datetime    
,@Rec_Start_date  datetime    
,@Rec_End_date   datetime     
,@Qual_Detail   nvarchar(1000)    
,@Experience_year  numeric(18,2)    
,@Location    varchar(200)    
,@Experience   nvarchar(1000)    
,@Email_id    varchar(50)    
,@Job_title    varchar(50)    
,@Posted_status   tinyint    
,@Login_id    numeric(18,0)    
,@S_Emp_id    numeric(18,0)    
,@Other_Detail nvarchar(1000)   
,@Position varchar(500)   
,@tran_type    char(1)    
,@Venue_Address nvarchar(250) --Mukti 09102015                
,@Publish_ToEmp int = 0 --Sneha 08072016  
,@Publish_FromDate datetime  = null --sneha 08072016  
,@Publish_ToDate   datetime  = null--sneha 08072016        
,@Consultant_ID int = null --Mukti(07072018)  
,@Exp_Min    numeric(18,2)=0   
AS    
------------------------------------------------------------------    
-------  Created by: Falak on 09-apr-2010 ------------------------    
------------------------------------------------------------------    
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON   
    
 /*if @cmp_id = 0     
  set @cmp_id  = null*/    
 if @Rec_Req_ID =0     
  set @Rec_Req_ID = null    
 if @Rec_End_Date = ''    
  set @Rec_End_Date = null    
 if @location = ''    
  set @location = null    
 if @Login_id=0  
 set @Login_id=null    
 if @S_Emp_id=0  
 set @S_Emp_id=null    
   
--added on 08072016------------  
if @Publish_ToEmp = NULL  
 set @Publish_ToEmp = 0  
  
if @Consultant_ID=0   
 set @Consultant_ID = NULL  
  
   set @Venue_Address = dbo.fnc_ReverseHTMLTags(@Venue_Address)  --added by Ronak 211021    
 if Upper(@tran_type) ='I'     
  begin    
      
    declare @Emp_Code as numeric      
    declare @str_Emp_Code as numeric  
      
   --if exists (Select Rec_Post_Id  from T0052_HRMS_Posted_Recruitment Where cmp_id=@CMP_ID AND Rec_Req_ID = @Rec_Req_ID and Rec_Start_date=@Rec_Start_date)    
   -- begin    
   --Select @Rec_Post_Id=Rec_Post_Id  from T0052_HRMS_Posted_Recruitment Where cmp_id=@CMP_ID AND Rec_Req_ID = @Rec_Req_ID and Rec_Start_date=@Rec_Start_date  
   --  RETURN     
   -- end    
    
 select @Rec_Post_Id = isnull(max(Rec_Post_Id),0) + 1 from T0052_HRMS_Posted_Recruitment WITH (NOLOCK)  
     
 select   @Rec_Post_Code=('JB' + cast(@cmp_id as varchar(20)) + ':' + cast(1000 + isnull(count(Rec_Post_Id),0) + 1 as varchar(20)) ) from T0052_HRMS_Posted_Recruitment WITH (NOLOCK) where cmp_id=@cmp_id  
  
   
 insert into T0052_HRMS_Posted_Recruitment(    
           Rec_Post_Id    
           ,cmp_id    
           ,Rec_Req_ID    
           ,Rec_Post_Code    
           ,Rec_Post_date    
           ,Rec_Start_date    
           ,Rec_End_date    
           ,Qual_Detail    
           ,Experience_year    
           ,Location    
           ,Experience    
           ,Email_id    
           ,Job_title    
           ,Login_id    
           ,S_Emp_id    
           ,Posted_status    
           ,System_Date  
           ,Other_Detail    
           ,Position  
           ,Venue_Address  
           ,Publish_ToEmp --sneha 08072016    
           ,Publish_FromDate --sneha 08072016    
           ,Publish_ToDate --sneha 08072016    
           ,Consultant_ID  
           ,Exp_Min  
          )     
               
        values(        
     @Rec_Post_Id    
           ,@cmp_id    
           ,@Rec_Req_ID    
           ,@Rec_Post_Code    
           ,@Rec_Post_date    
           ,@Rec_Start_date    
           ,@Rec_End_date    
           ,@Qual_Detail    
           ,@Experience_year    
           ,@Location    
           ,@Experience    
           ,@Email_id    
           ,@Job_title    
           ,@Login_id    
           ,@S_Emp_id    
           ,@Posted_status    
           ,getdate()    
           ,@Other_Detail    
           ,@Position  
           ,@Venue_Address  
           ,@Publish_ToEmp --sneha 08072016    
           ,@Publish_FromDate --sneha 08072016    
           ,@Publish_ToDate --sneha 08072016    
           ,@Consultant_ID  
           ,@Exp_Min  
          )    
    
  end     
 else if upper(@tran_type) ='U'     
  begin       
    Update T0052_HRMS_Posted_Recruitment     
    Set Rec_Start_Date=@Rec_Start_date    
      ,Rec_End_date=@Rec_End_date    
      ,Qual_Detail=@Qual_Detail    
      ,Experience_year=@Experience_year    
      ,Location=@Location    
      ,Experience=@Experience    
      ,Job_title =@Job_title    
      ,Email_id = @Email_id    
      ,Login_id=@Login_id    
      ,S_Emp_id = @S_Emp_id    
      ,Posted_status=@Posted_status    
      ,System_Date=getdate()    
      ,Other_Detail=@Other_Detail    
      ,Position=@Position  
      ,Venue_Address=@Venue_Address  
      ,Publish_ToEmp = @Publish_ToEmp--sneha 08072016    
      ,Publish_FromDate = @Publish_FromDate --sneha 08072016    
      ,Publish_ToDate = @Publish_ToDate--sneha 08072016    
      ,Consultant_ID = @Consultant_ID  
      ,Exp_Min=@Exp_Min  
     where Rec_Post_Id = @Rec_Post_Id      
  end     
 else if upper(@tran_type) ='D'    
  Begin    
 set @Rec_Post_Code = '1'  
 if not exists( select Rec_Post_ID from T0055_HRMS_Interview_Schedule WITH (NOLOCK) where Rec_Post_ID= @Rec_Post_Id)    
 begin  
  if not exists( select Rec_Post_ID from T0055_Resume_Master WITH (NOLOCK) where Rec_Post_ID= @Rec_Post_Id)     
   begin  
    delete from T0055_Interview_Process_Question_Detail WHERE Rec_Post_Id = @Rec_Post_Id  
    delete from  T0040_HRMS_General_Setting WHERE Rec_Post_Id = @Rec_Post_Id  
    delete from T0053_HRMS_Recruitment_Form where Rec_Post_Id = @Rec_Post_Id  
    delete from T0055_Interview_Process_Detail where Rec_Post_ID = @Rec_Post_Id  
    delete  from T0052_HRMS_Posted_Recruitment where Rec_Post_Id=@Rec_Post_Id     
   end  
  else  
   begin  
    SET @Rec_Post_Code =''  
   end  
     
  end  
 ELSE  
  BEGIN  
   SET @Rec_Post_Code= ''  
  END  
  end    
 RETURN    
    
    
    
    
    
    
    
  
  
  
  
  
  
  