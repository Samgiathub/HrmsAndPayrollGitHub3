
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0100_LEAVE_APPLICATION]    
   @Leave_Application_ID numeric output    
  ,@Cmp_ID numeric    
  ,@Emp_ID  numeric    
  ,@S_Emp_ID  numeric    
  ,@Application_Date datetime    
  ,@Application_Code varchar(20) output    
  ,@Application_Status char(1)    
  ,@Application_Comments varchar(250)    
  ,@Login_ID numeric     
  ,@System_Date datetime    
  ,@tran_type varchar(1)   
  ,@is_backdated_application tinyint = 0
  ,@is_Responsibility_pass tinyint = 0
  ,@Responsible_Emp_id numeric(18,0) = 0
  ,@M_Cancel_WO_HO		TINYINT = 0 --Ankit 05082016
  ,@Apply_From_AttReg tinyint = 0 --Mukti(06092017)
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


  if @S_Emp_ID = 0     
   set @S_Emp_ID =NULL    
       
if @tran_type ='I'     
   begin    
  
  declare @Emp_Code as numeric    
  declare @str_Emp_Code as varchar(20)    
   
   if @Apply_From_AttReg = 1 --Mukti(06092017)
		set @M_Cancel_WO_HO = 1  
		 
 /* if exists(select @Leave_Application_ID from dbo.T0100_LEAVE_APPLICATION Where Emp_ID = @Emp_ID and Application_Date = @Application_Date and Cmp_id = @cmp_Id )    
     begin    
     set @Leave_Application_ID = 0      
      return    
     end      */      
	
       
    
    select @Leave_Application_ID = isnull(max(Leave_Application_ID),0) +1 from dbo.T0100_LEAVE_APPLICATION WITH (NOLOCK)    
       
     --Temporary Comment for error  
    /*select @Emp_Code = EMP_CODE From T0080_EMP_MASTER WHERE EMP_ID  = @EMP_ID    
          
    SELECT @str_Emp_Code =DATA  FROM dbo.F_Format('0000',@Emp_Code)     
       
    
       
    select @Application_Code =   cast(isnull(max(substring(Application_Code,8,len(Application_Code))),0) + 1 as varchar)      
      from dbo.T0100_LEAVE_APPLICATION  where Emp_ID = @Emp_ID    
          
    If charindex(':',@Application_Code) > 0     
     Select @Application_Code = right(@Application_Code,len(@Application_Code) - charindex(':',@Application_Code))    
        
      
    if @Application_Code is not null    
     begin    
      while len(@Application_Code) <> 4    
       begin    
        set @Application_Code = '0' + @Application_Code    
       end    
      set @Application_Code = 'LV'+ @str_Emp_Code +':'+ @Application_Code    
  
     end    
    else    
     SET @Application_Code = 'LV' + @str_Emp_Code + ':' + '0001'    
 */  
 
 set @Application_Code = cast(@Leave_Application_ID as Varchar(20))  
      INSERT INTO dbo.T0100_LEAVE_APPLICATION    
                            (Leave_Application_ID, Cmp_ID, Emp_ID, S_Emp_ID, Application_Date, Application_Code, Application_Status, Application_Comments, Login_ID,     
                            System_Date,is_backdated_application,is_Responsibility_pass,Responsible_Emp_id,M_Cancel_WO_HO,Apply_From_AttReg)    
      VALUES     (@Leave_Application_ID,@Cmp_ID,@Emp_ID,@S_Emp_ID,@Application_Date,@Application_Code,@Application_Status,@Application_Comments,@Login_ID,@System_Date,@is_backdated_application,@is_Responsibility_pass,@Responsible_Emp_id,@M_Cancel_WO_HO,@Apply_From_AttReg)    
   end     
 else if @tran_type ='U'     
    begin    
		
		if @Application_Status = 'F'    
		begin    
			 UPDATE    dbo.T0100_LEAVE_APPLICATION    
			 SET     Application_Status = @Application_Status,    
				  System_Date = @System_Date    
								  where Leave_Application_ID = @Leave_Application_ID    
		        
		end    
        
    else    
       
		UPDATE		dbo.T0100_LEAVE_APPLICATION    
		SET         Cmp_ID = @Cmp_ID, Emp_ID = @Emp_ID,S_Emp_ID = @S_Emp_ID,    
					Application_Date = @Application_Date, Application_Status = @Application_Status,Application_Comments = @Application_Comments,     
					Login_ID = @Login_ID, System_Date = @System_Date    
					, is_backdated_application = @is_backdated_application
					,is_Responsibility_pass = @is_Responsibility_pass,Responsible_Emp_id = @Responsible_Emp_id
					,M_Cancel_WO_HO = @M_Cancel_WO_HO
		where		Leave_Application_ID = @Leave_Application_ID    
         
    end    
    
 else if @tran_type ='D'    
  Begin     
    DELETE FROM dbo.T0110_LEAVE_APPLICATION_DETAIL where  Leave_Application_ID = @Leave_Application_ID     
    DELETE FROM dbo.T0100_LEAVE_APPLICATION where Leave_Application_ID = @Leave_Application_ID    
  End    
 RETURN    
    
  
  

