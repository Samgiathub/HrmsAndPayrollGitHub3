  
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---  
CREATE PROCEDURE [dbo].[P0080_Grev_App_Details]    
    @Grev_App_ID  numeric(9) output    
   ,@Grev_App_Code varchar(50)   
   ,@Grev_App_Name	varchar(50)    
   ,@Grev_Type varchar(500)
   ,@Grev_App_Date	datetime  
   ,@Grev_Desc varchar(MAX)
   ,@Grev_Ename varchar(50)
   ,@Grev_Committee	numeric(9)  
   ,@Grev_Committee_Member	varchar(MAX)
   ,@Grev_Meeting_Date	datetime
   ,@ReviewOfGrev_App	varchar(MAX)
   ,@Cmp_ID   numeric(9)   
   ,@Tran_Type	Char(1) 
AS    
SET NOCOUNT ON   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED  
SET ARITHABORT ON  
      
   If @tran_type  = 'I' Or @tran_type = 'U'  
 BEGIN   
     
 -- If @Reason_Name = ''  
 --  BEGIN  
 --   Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Reason Name is not Properly Inserted',0,'Enter Proper Reason Name',GetDate(),'Reason Master','')        
 --   Return  
 --  END  
 --END  
   
 If @tran_type  = 'I'    
  Begin    
  --if exists (Select Res_Id  from dbo.T0040_Reason_Master WITH (NOLOCK) Where Upper(Reason_Name) = Upper(@Reason_Name) and [Type]=@Reason_Type)     
  --  begin    
  --   set @Reason_ID = 0    
  --   Return    
  --  end    
    select @Grev_App_ID = Isnull(max(Grev_App_ID),0) + 1  From dbo.T0080_Grev_App_Details  WITH (NOLOCK)   
    INSERT INTO dbo.T0080_Grev_App_Details (Grev_App_ID,Grev_App_Code,Grev_App_Name,Grev_Type,Grev_App_Date,Grev_Desc,Grev_Ename,Grev_Committee,Grev_Committee_Member,Grev_Meeting_Date,ReviewOfGrev_App)    
             VALUES(@Grev_App_ID,@Grev_App_Code,@Grev_App_Name,@Grev_Type,@Grev_App_Date,@Grev_Desc,@Grev_Ename,@Grev_Committee,@Grev_Committee_Member,@Grev_Meeting_Date,@ReviewOfGrev_App) 
      
      
  End    
 Else if @Tran_Type = 'U'    
  --begin    
  -- IF Exists(select Res_Id From dbo.T0040_Reason_Master WITH (NOLOCK) Where upper(Reason_Name) = upper(@Reason_Name) and Res_Id <> @Reason_ID and [Type] = @Reason_Type)    
  --  Begin    
  --   set @Reason_ID = 0    
  --   Return     
  --  End    
         
  --     IF @Is_Default = 1 -- Added By Niraj 01092021  
  --UPDATE dbo.T0040_Reason_Master SET Is_Default = 0  
  
       BEGIN     
   -- if Exists(SELECT 1 From T0080_Grev_App_Details WITH (NOLOCK) where Grev_App_ID = @Grev_App_ID AND Cmp_ID = @Cmp_ID)  

    UPDATE dbo.T0080_Grev_App_Details    
    SET
	    Grev_App_Code=@Grev_App_Code,
		Grev_App_Name=@Grev_Type,
		Grev_App_Date=@Grev_App_Date,
		Grev_Desc=@Grev_Desc,
		Grev_Ename=@Grev_Ename,
		Grev_Committee=@Grev_Committee,
		Grev_Committee_Member=@Grev_Committee_Member,
		Grev_Meeting_Date=@Grev_Meeting_Date,
		ReviewOfGrev_App=@ReviewOfGrev_App
    where Grev_App_ID = @Grev_App_ID   
      
   -- Update T0095_INCREMENT Set Reason_Name = @Reason_Name where Reason_ID = @Reason_ID   
   End  
  Else  
   Begin  
    UPDATE dbo.T0080_Grev_App_Details    
    SET
	    Grev_App_Code=@Grev_App_Code,
		Grev_App_Name=@Grev_Type,
		Grev_App_Date=@Grev_App_Date,
		Grev_Desc=@Grev_Desc,
		Grev_Ename=@Grev_Ename,
		Grev_Committee=@Grev_Committee,
		Grev_Committee_Member=@Grev_Committee_Member,
		Grev_Meeting_Date=@Grev_Meeting_Date,
		ReviewOfGrev_App=@ReviewOfGrev_App
    where Grev_App_ID = @Grev_App_ID   
      
   End  
  --Added by nilesh patel on 21012016 -End  
  end    
 Else if @Tran_Type = 'D'    
  begin    
 if Exists(SELECT 1 From T0080_Grev_App_Details WITH (NOLOCK) where Grev_App_ID = @Grev_App_ID )--AND Cmp_ID = @Cmp_ID)  
  BEGIN  
   --RAISERROR('@@Reason can''t be Deleted Reference Exist.@@',16,2)  
   Set @Grev_App_ID = 0  
   RETURN   
  End  
 ELSE  
  Begin  
   -- added by darshan 05/11/2020  
  -- declare @lReasonName varchar(500) = ''  
  -- select @lReasonName = Reason_Name from T0040_Reason_Master WITH (NOLOCK) Where Res_Id = @Reason_ID  
  -- if not exists (select 1 from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Reason = @lReasonName)  
   begin  
   -- added by darshan 05/11/2020  
    Delete From dbo.T0080_Grev_App_Details Where Grev_App_ID = @Grev_App_ID  
   -- added by darshan 05/11/2020  
   end  
   -- added by darshan 05/11/2020  
  End  
  end    
 RETURN