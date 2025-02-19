



CREATE PROCEDURE [dbo].[P0040_File_Status_Master]  
    @F_StatusId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@FileStatusTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@FileStatusCode varchar(max)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 11022022

  if @FileStatusCode=''
  begin
	set @FileStatusCode = null
  end


 If @tran_type  = 'I'  
  Begin  
  if exists (Select F_StatusID  from T0040_File_Status_Master WITH (NOLOCK) Where F_StatusID = @F_StatusId )   
    begin  
     set @F_StatusId = 0  
     Return  
    end  
	
		if exists (Select F_StatusID  from T0040_File_Status_Master WITH (NOLOCK) Where StatusTitle = @FileStatusTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @F_StatusId = 0  
		   Return  
		  end  



    select @F_StatusId = Isnull(max(F_StatusID),0) + 1  From T0040_File_Status_Master  WITH (NOLOCK) 
    INSERT INTO T0040_File_Status_Master (F_StatusID,StatusTitle,StatusCode,StatusCDTM,Cmp_ID)  
             VALUES(@F_StatusId,@FileStatusTitle,@FileStatusCode,GETDATE(),@Cmp_ID)


  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select F_StatusID  from T0040_File_Status_Master WITH (NOLOCK) Where F_StatusID = @F_StatusId)  
    Begin  
     set @F_StatusId = 0  
     Return   
    End  


		if exists (Select F_StatusID  from T0040_File_Status_Master WITH (NOLOCK) Where  F_StatusID <> @F_StatusId and StatusTitle = @FileStatusTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @F_StatusId = 0  
		   Return  
		  end  


				 UPDATE T0040_File_Status_Master  
				 SET StatusTitle = @FileStatusTitle
				 ,StatusCode=@FileStatusCode 
				 ,StatusUDTM = getdate()
				 where F_StatusID = @F_StatusId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select F_StatusID  from T0040_File_Status_Master WITH (NOLOCK) Where F_StatusID = @F_StatusId)  
		BEGIN
		
			Set @F_StatusId = 0
			RETURN 
		End
	ELSE
		Begin

				--update T0040_File_Status_Master set
				--Is_Active=0,
				--StatusUDTM=getdate()
				--where F_StatusID = @F_StatusId  --For Soft Delete
			
				Delete From T0040_File_Status_Master Where F_StatusID = @F_StatusId --For Hard Delete
		
		
		End
   end  
 RETURN
