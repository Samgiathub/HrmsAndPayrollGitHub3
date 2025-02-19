


CREATE PROCEDURE [dbo].[P0040_Grievance_Category_Master]  
    @G_CategoryId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@GrievCategoryTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@GrievCategoryCode varchar(max)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 14022022

  if @GrievCategoryCode=''
  begin
	set @GrievCategoryCode = null
  end


 If @tran_type  = 'I'  
  Begin  
  if exists (Select G_CategoryID  from T0040_Griev_Category_Master WITH (NOLOCK) Where G_CategoryID = @G_CategoryId )   
    begin  
     set @G_CategoryId = 0  
     Return  
    end  



		 if exists (Select G_CategoryID  from T0040_Griev_Category_Master WITH (NOLOCK) Where CategoryTitle = @GrievCategoryTitle AND Cmp_ID=@Cmp_ID )   
		 begin  
		  set @G_CategoryId = 0  
		  Return  
		 end  



    select @G_CategoryId = Isnull(max(G_CategoryID),0) + 1  From T0040_Griev_Category_Master  WITH (NOLOCK) 
    INSERT INTO T0040_Griev_Category_Master (G_CategoryID,CategoryTitle,CategoryCode,CategoryCDTM,Cmp_ID)  
             VALUES(@G_CategoryId,@GrievCategoryTitle,@GrievCategoryCode,GETDATE(),@Cmp_ID)
  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select G_CategoryID  from T0040_Griev_Category_Master WITH (NOLOCK) Where G_CategoryID = @G_CategoryId)  
    Begin  
     set @G_CategoryId = 0  
     Return   
    End  

				 if exists (Select G_CategoryID  from T0040_Griev_Category_Master WITH (NOLOCK) Where G_CategoryID <> @G_CategoryId and CategoryTitle = @GrievCategoryTitle AND Cmp_ID=@Cmp_ID )   
			     begin  
			      set @G_CategoryId = 0  
			      Return  
			     end  
				


				 UPDATE T0040_Griev_Category_Master  
				 SET CategoryTitle = @GrievCategoryTitle
				 ,CategoryCode=@GrievCategoryCode 
				 ,CategoryUDTM = getdate()
				 where G_CategoryID = @G_CategoryId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Exists(Select Griev_CatID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where Griev_CatID = @G_CategoryId)  
		BEGIN
		
			Set @G_CategoryId = 0
			RETURN 
		End
	ELSE
		Begin

				--update T0040_Griev_Category_Master set
				--Is_Active=0,
				--CategoryUDTM=getdate()
				--where G_CategoryID = @G_CategoryId  --For Soft Delete
			
				Delete From T0040_Griev_Category_Master Where G_CategoryID = @G_CategoryId --For Hard Delete
		
		
		End
   end  
 RETURN