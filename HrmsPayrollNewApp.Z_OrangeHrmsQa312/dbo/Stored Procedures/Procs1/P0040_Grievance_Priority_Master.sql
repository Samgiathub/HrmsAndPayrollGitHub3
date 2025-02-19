

CREATE PROCEDURE [dbo].[P0040_Grievance_Priority_Master]  
    @G_PriorityId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@GrievPriorityTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@GrievPriorityCode varchar(max)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 11022022

  if @GrievPriorityCode=''
  begin
	set @GrievPriorityCode = null
  end


 If @tran_type  = 'I'  
  Begin  
  if exists (Select G_PriorityID  from T0040_Griev_Priority_Master WITH (NOLOCK) Where G_PriorityID = @G_PriorityId )   
    begin  
     set @G_PriorityId = 0  
     Return  
    end  


			if exists (Select G_PriorityID  from T0040_Griev_Priority_Master WITH (NOLOCK) Where PriorityTitle = @GrievPriorityTitle and Cmp_ID=@Cmp_ID )   
			begin  
			 set @G_PriorityId = 0  
			 Return  
			end  


    select @G_PriorityId = Isnull(max(G_PriorityID),0) + 1  From T0040_Griev_Priority_Master  WITH (NOLOCK) 
    INSERT INTO T0040_Griev_Priority_Master (G_PriorityID,PriorityTitle,PriorityCode,PriorityCDTM,Cmp_ID)  
             VALUES(@G_PriorityId,@GrievPriorityTitle,@GrievPriorityCode,GETDATE(),@Cmp_ID)
  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select G_PriorityID  from T0040_Griev_Priority_Master WITH (NOLOCK) Where G_PriorityID = @G_PriorityId)  
    Begin  
     set @G_PriorityId = 0  
     Return   
    End  
				
			if exists (Select G_PriorityID  from T0040_Griev_Priority_Master WITH (NOLOCK) Where G_PriorityID <> @G_PriorityId  and  PriorityTitle = @GrievPriorityTitle and Cmp_ID=@Cmp_ID )   
			begin  
			 set @G_PriorityId = 0  
			 Return  
			end  

		

				 UPDATE T0040_Griev_Priority_Master  
				 SET PriorityTitle = @GrievPriorityTitle
				 ,PriorityCode=@GrievPriorityCode 
				 ,PriorityUDTM = getdate()
				 where G_PriorityID = @G_PriorityId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Exists(Select Griev_PriorityID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where Griev_PriorityID = @G_PriorityId)  
		BEGIN
		
			Set @G_PriorityId = 0
			RETURN 
		End
	ELSE
		Begin

				--update T0040_Griev_Priority_Master set
				--Is_Active=0,
				--PriorityUDTM=getdate()
				--where G_PriorityID = @G_PriorityId  --For Soft Delete
			
				Delete From T0040_Griev_Priority_Master Where G_PriorityID = @G_PriorityId --For Hard Delete
		
		
		End
   end  
 RETURN