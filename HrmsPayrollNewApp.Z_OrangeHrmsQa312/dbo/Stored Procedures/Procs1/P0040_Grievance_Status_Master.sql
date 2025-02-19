

CREATE PROCEDURE [dbo].[P0040_Grievance_Status_Master]  
    @G_StatusId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@GrievStatusTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@GrievStatusCode varchar(max)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 11022022

  if @GrievStatusCode=''
  begin
	set @GrievStatusCode = null
  end


 If @tran_type  = 'I'  
  Begin  
  if exists (Select G_StatusID  from T0040_Griev_Status_Master WITH (NOLOCK) Where G_StatusID = @G_StatusId )   
    begin  
     set @G_StatusId = 0  
     Return  
    end  
	
		if exists (Select G_StatusID  from T0040_Griev_Status_Master WITH (NOLOCK) Where StatusTitle = @GrievStatusTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @G_StatusId = 0  
		   Return  
		  end  



    select @G_StatusId = Isnull(max(G_StatusID),0) + 1  From T0040_Griev_Status_Master  WITH (NOLOCK) 
    INSERT INTO T0040_Griev_Status_Master (G_StatusID,StatusTitle,StatusCode,StatusCDTM,Cmp_ID)  
             VALUES(@G_StatusId,@GrievStatusTitle,@GrievStatusCode,GETDATE(),@Cmp_ID)


  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select G_StatusID  from T0040_Griev_Status_Master WITH (NOLOCK) Where G_StatusID = @G_StatusId)  
    Begin  
     set @G_StatusId = 0  
     Return   
    End  


		if exists (Select G_StatusID  from T0040_Griev_Status_Master WITH (NOLOCK) Where  G_StatusID <> @G_StatusId and StatusTitle = @GrievStatusTitle and Cmp_ID=@Cmp_ID  )   
		  begin  
		   set @G_StatusId = 0  
		   Return  
		  end  


				 UPDATE T0040_Griev_Status_Master  
				 SET StatusTitle = @GrievStatusTitle
				 ,StatusCode=@GrievStatusCode 
				 ,StatusUDTM = getdate()
				 where G_StatusID = @G_StatusId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select G_StatusID  from T0040_Griev_Status_Master WITH (NOLOCK) Where G_StatusID = @G_StatusId)  
		BEGIN
		
			Set @G_StatusId = 0
			RETURN 
		End
	ELSE
		Begin

				--update T0040_Griev_Status_Master set
				--Is_Active=0,
				--StatusUDTM=getdate()
				--where G_StatusID = @G_StatusId  --For Soft Delete
			
				Delete From T0040_Griev_Status_Master Where G_StatusID = @G_StatusId --For Hard Delete
		
		
		End
   end  
 RETURN