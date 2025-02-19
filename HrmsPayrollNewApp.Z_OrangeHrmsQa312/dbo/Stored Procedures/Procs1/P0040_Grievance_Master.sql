
CREATE PROCEDURE [dbo].[P0040_Grievance_Master]  
    @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@GrievTitle nvarchar(max)
   ,@tran_type  varchar(1) 
   ,@GrievCode varchar(max)
   
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 07022022

  if @GrievCode=''
  begin
	set @GrievCode = null
  end

 


 If @tran_type  = 'I'  
  Begin  
  if exists (Select GrievanceTypeID  from T0040_Grievance_Type_Master WITH (NOLOCK) Where GrievanceTypeID = @GrieId )   
    begin  
     set @GrieId = 0  
     Return  
    end  

	 if exists (Select GrievanceTypeID  from T0040_Grievance_Type_Master WITH (NOLOCK) Where GrievanceTypeTitle = @GrievTitle and Cmp_ID=@Cmp_ID )   
    begin  
     set @GrieId = 0  
     Return  
    end  




    select @GrieId = Isnull(max(GrievanceTypeID),0) + 1  From T0040_Grievance_Type_Master  WITH (NOLOCK) 
    INSERT INTO T0040_Grievance_Type_Master (GrievanceTypeID,GrievanceTypeTitle,GrievanceTypeCode,GrievanceTypeCDTM,Cmp_ID)  
             VALUES(@GrieId,@GrievTitle,@GrievCode,GETDATE(),@Cmp_ID)
  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GrievanceTypeID  from T0040_Grievance_Type_Master WITH (NOLOCK) Where GrievanceTypeID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

	if exists (Select GrievanceTypeID  from T0040_Grievance_Type_Master WITH (NOLOCK) Where GrievanceTypeID <> @GrieId and GrievanceTypeTitle = @GrievTitle and Cmp_ID=@Cmp_ID )   
    begin  
     set @GrieId = 0  
     Return  
    end  



				 UPDATE T0040_Grievance_Type_Master  
				 SET GrievanceTypeTitle = @GrievTitle
				 ,GrievanceTypeCode=@GrievCode 
				 ,GrievanceTypeUDTM = getdate()
				 where GrievanceTypeID = @GrieId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Exists(Select Griev_TypeID  from T0080_Griev_Application_Allocation WITH (NOLOCK) Where Griev_TypeID = @GrieId)  
		BEGIN
		
			Set @GrieId = 0
			RETURN 
		End
	ELSE
		Begin

				--update T0040_Grievance_Type_Master set
				--Is_Active=0,
				--GrievanceTypeUDTM=getdate()
				--where GrievanceTypeID = @GrieId  --For Soft Delete
			
				Delete From T0040_Grievance_Type_Master Where GrievanceTypeID = @GrieId --For Hard Delete
		
		
		End
   end  
 RETURN