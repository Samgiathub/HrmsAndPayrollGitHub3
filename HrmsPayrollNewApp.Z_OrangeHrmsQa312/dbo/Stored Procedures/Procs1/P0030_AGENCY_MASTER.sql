



---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0030_AGENCY_MASTER]
			 @Agency_Id numeric(18) output
			,@Cmp_ID numeric(18)
            ,@State_ID numeric(18)
            ,@Agency_Name  varchar(250)	
            ,@Agency_City  varchar(250)	
            ,@Agency_Address  varchar(250)	
            ,@Agency_Phone  varchar(250)	
            ,@Agency_Mobile  varchar(250)	
            ,@Comment  varchar(250)	
            ,@tran_type char
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	if Upper(@tran_type) ='I' 
		begin
		
			if exists (Select Agency_Id  from T0030_AGENCY_MASTER WITH (NOLOCK)  Where Upper(Agency_Name) = Upper(@Agency_Name) and Cmp_ID = @Cmp_ID) 
				begin
					set @Agency_Id=0
					RETURN 
				end
					select @Agency_Id = isnull(max(Agency_Id),0) + 1 from T0030_AGENCY_MASTER WITH (NOLOCK)
						
					insert into T0030_AGENCY_MASTER(Agency_Id,Cmp_ID,State_ID,Agency_Name,Agency_City,Agency_Address,Agency_Phone,Agency_Mobile,Comment) 
					values(@Agency_Id,@Cmp_ID,@State_ID,@Agency_Name,@Agency_City,@Agency_Address,@Agency_Phone,@Agency_Mobile,@Comment)

		end 
	else if upper(@tran_type) ='U' 
		begin
			if exists (Select Agency_Id  from T0030_AGENCY_MASTER WITH (NOLOCK) Where Upper(Agency_Name)= upper(@Agency_Name) and Agency_Id <> @Agency_Id
											and Cmp_ID = @Cmp_ID) 
				begin
					set @Agency_Id=0
					return 
				end					
					
				Update T0030_AGENCY_MASTER 
				Set Agency_Id=@Agency_Id,State_ID=@State_ID,Agency_Name=@Agency_Name,Agency_City=@Agency_City,Agency_Address=@Agency_Address,Agency_Phone=@Agency_Phone,Agency_Mobile=@Agency_Mobile,Comment=@Comment
				where Agency_Id = @Agency_Id and Cmp_ID = @Cmp_ID  
		end	
	else if upper(@tran_type) ='D'
		Begin
			delete  from T0030_AGENCY_MASTER where Agency_Id=@Agency_Id 
		end
			

	RETURN




