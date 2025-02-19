
CREATE PROCEDURE [dbo].[P0080_Grievance_Application]  
    @GrieId  numeric(9) output  
   ,@Cmp_ID   numeric(9)  
   ,@TypeOfGrieID numeric(9) 
   ,@tran_type  varchar(1) 
   ,@DateofGrie varchar(20)
   ,@Griev_AgainstID numeric(9)=0 
   ,@Grievance_Desc nvarchar(max)
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
  
  --Created by Ronak Kumawat 01022022

  if @DateofGrie=''
  begin
	set @DateofGrie = null
  end

  if @Griev_AgainstID=0
  begin
	set @Griev_AgainstID = null
  end


 If @tran_type  = 'I'  
  Begin  
  if exists (Select GrievanceID  from T0080_Grie_App_Form WITH (NOLOCK) Where GrievanceID = @GrieId )   
    begin  
     set @GrieId = 0  
     Return  
    end  
    select @GrieId = Isnull(max(GrievanceID),0) + 1  From T0080_Grie_App_Form  WITH (NOLOCK) 
    INSERT INTO T0080_Grie_App_Form (GrievanceID,Type_of_Grie_id,Date_of_Grievance,Grie_Against_id,Grievance_Desc,Cmp_ID)  
             VALUES(@GrieId,@TypeOfGrieID,@DateofGrie,@Griev_AgainstID,@Grievance_Desc,@Cmp_ID)
  End  
 Else if @Tran_Type = 'U'  
  begin  
   IF Not Exists(Select GrievanceID  from T0080_Grie_App_Form WITH (NOLOCK) Where GrievanceID = @GrieId)  
    Begin  
     set @GrieId = 0  
     Return   
    End  

				 UPDATE T0080_Grie_App_Form  
				 SET Type_of_Grie_id = @TypeOfGrieID
				 ,Date_of_Grievance=@DateofGrie 
				 ,Grie_Against_id = @Griev_AgainstID
				 ,Grievance_Desc = @Grievance_Desc
				 where GrievanceID = @GrieId  
		
  end  
 Else if @Tran_Type = 'D'  
  begin  
	if Not Exists(Select GrievanceID  from T0080_Grie_App_Form WITH (NOLOCK) Where GrievanceID = @GrieId)  
		BEGIN
		
			Set @GrieId = 0
			RETURN 
		End
	ELSE
		Begin

				update T0080_Grie_App_Form set Is_Active=0 where GrievanceID = @GrieId  --For Soft Delete
			
				--Delete From T0080_Grie_App_Form Where GrievanceID = @GrieId --For Hard Delete
		
		
		End
   end  
 RETURN