
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_Reason_Master]  
    @Reason_ID  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@Reason_Name varchar(300)  
   ,@tran_type  varchar(1) 
   ,@Is_Reason tinyint =0  
   ,@Reason_Type varchar(10) = 'R'  --Added by GAdriwala Muslim  12062014
   ,@Gate_Pass_Type varchar(10) = '' --Added by GAdriwala Muslim  12062014
   ,@Is_Mandatory tinyint = 0  --Added by Jaina 01-09-2017
   ,@Is_Default bit = 0 -- Added By Niraj 01092021
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
    
   If @tran_type  = 'I' Or @tran_type = 'U'
	BEGIN 
		 
		If @Reason_Name = ''
			BEGIN
				Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,0,'Reason Name is not Properly Inserted',0,'Enter Proper Reason Name',GetDate(),'Reason Master','')						
				Return
			END
	END
 
 If @tran_type  = 'I'  
  Begin  
  if exists (Select Res_Id  from dbo.T0040_Reason_Master WITH (NOLOCK) Where Upper(Reason_Name) = Upper(@Reason_Name) and [Type]=@Reason_Type)   
    begin  
     set @Reason_ID = 0  
     Return  
    end  
    select @Reason_ID = Isnull(max(Res_Id),0) + 1  From dbo.T0040_Reason_Master  WITH (NOLOCK) 
    INSERT INTO dbo.T0040_Reason_Master (Res_Id,Reason_Name,Isactive,Type,Gate_Pass_Type,Is_Mandatory,Is_Default)  
             VALUES(@Reason_ID,@Reason_Name,@Is_Reason,@Reason_Type,@Gate_Pass_Type,@Is_Mandatory,@Is_Default) --Added by Niraj as on 01092021
    
    
  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Exists(select Res_Id From dbo.T0040_Reason_Master WITH (NOLOCK) Where upper(Reason_Name) = upper(@Reason_Name) and Res_Id <> @Reason_ID and [Type] = @Reason_Type)  
    Begin  
     set @Reason_ID = 0  
     Return   
    End  
       
       IF @Is_Default = 1 -- Added By Niraj 01092021
		UPDATE dbo.T0040_Reason_Master SET Is_Default = 0

         --Added by nilesh patel on 21012016 -Start
        if Exists(SELECT 1 From T0095_INCREMENT WITH (NOLOCK) where Reason_ID = @Reason_ID AND Cmp_ID = @Cmp_ID)
			BEGIN
				UPDATE dbo.T0040_Reason_Master  
				SET Reason_Name = @Reason_Name
				,Type = @Reason_Type
				 ,Isactive=@Is_Reason
				 ,Gate_Pass_Type = @Gate_Pass_Type  --Added by Gadriwala Muslim  29122014
				 ,Is_Mandatory = @Is_Mandatory  --Added by Jaina 01-09-2017
				 ,Is_Default = @Is_Default -- Added By Niraj 01092021
				where Res_Id = @Reason_ID  
				
				Update T0095_INCREMENT Set Reason_Name = @Reason_Name where Reason_ID = @Reason_ID 
			End
		Else
			Begin
				 UPDATE dbo.T0040_Reason_Master  
				 SET Reason_Name = @Reason_Name
				 ,Isactive=@Is_Reason 
				 ,Type = @Reason_Type  --Added by GAdriwala Muslim  12062014
				 ,Gate_Pass_Type = @Gate_Pass_Type  --Added by Gadriwala Muslim  29122014
				 ,Is_Mandatory = @Is_Mandatory  --Added by Jaina 01-09-2017
				 ,Is_Default = @Is_Default -- Added By Niraj 01092021
				 where Res_Id = @Reason_ID  
			End
		--Added by nilesh patel on 21012016 -End
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Exists(SELECT 1 From T0095_INCREMENT WITH (NOLOCK) where Reason_ID = @Reason_ID AND Cmp_ID = @Cmp_ID)
		BEGIN
			--RAISERROR('@@Reason can''t be Deleted Reference Exist.@@',16,2)
			Set @Reason_ID = 0
			RETURN 
		End
	ELSE
		Begin
			-- added by darshan 05/11/2020
			declare @lReasonName varchar(500) = ''
			select @lReasonName = Reason_Name from T0040_Reason_Master WITH (NOLOCK) Where Res_Id = @Reason_ID
			if not exists (select 1 from T0150_EMP_INOUT_RECORD WITH (NOLOCK) where Reason = @lReasonName)
			begin
			-- added by darshan 05/11/2020
				Delete From dbo.T0040_Reason_Master Where Res_Id = @Reason_ID
			-- added by darshan 05/11/2020
			end
			-- added by darshan 05/11/2020
		End
  end  
 RETURN