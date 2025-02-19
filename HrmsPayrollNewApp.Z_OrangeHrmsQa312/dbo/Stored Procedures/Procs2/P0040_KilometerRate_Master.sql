-- =============================================
-- Author:		Divyaraj Kiri
-- Create date: 16/02/2024
-- Description:	Insert,Update and Delete of T0040_KilometerRate_Master Table
-- =============================================
CREATE PROCEDURE P0040_KilometerRate_Master 
	@KR_Id numeric(18) OUTPUT ,
	@Cmp_ID numeric(18) ,
	@Effective_Date datetime ,
	@Emp_Category nvarchar(50) ,
	@Vehicle_Type nvarchar(50) ,
	@RatePer_Km numeric(16, 2) ,
	@Created_By int ,
	@tran_type  varchar(1)   
AS
BEGIN

 If @tran_type  = 'I'    
  Begin    
  
	If Exists (Select KR_Id  from T0040_KilometerRate_Master WITH (NOLOCK) Where Cmp_Id=@Cmp_Id and 
	Convert(varchar,Effective_Date,112) = Convert(varchar,@Effective_Date,112) AND
	Emp_Category = @Emp_Category AND Vehicle_Type = @Vehicle_Type and RatePer_Km = @RatePer_Km)	
	begin
		set @KR_Id = 0
	end

   Insert Into T0040_KilometerRate_Master(Cmp_ID,Effective_Date,Emp_Category,Vehicle_Type,RatePer_Km,Created_By,Created_Date)  
   Values (@Cmp_ID,@Effective_Date,@Emp_Category,@Vehicle_Type,@RatePer_Km,@Created_By,SYSDATETIME())  
  
   set @KR_Id = Scope_Identity()    
  
 End  
  
Else if @tran_type ='U'  
 begin   
   If Not Exists (Select KR_Id  from T0040_KilometerRate_Master WITH (NOLOCK) Where KR_Id = @KR_Id )    
   Begin   
	Set @KR_Id = 0  
   Return  
   End  
     Update T0040_KilometerRate_Master
     SET		
		Cmp_ID = @Cmp_ID ,
		Effective_Date = @Effective_Date  ,
		Emp_Category =  @Emp_Category  ,
		Vehicle_Type = @Vehicle_Type  ,
		RatePer_Km = @RatePer_Km ,
		Created_By = @Created_By  ,	 
		Created_Date = SYSDATETIME()
     Where KR_Id = @KR_Id
 End  
  
Else If @tran_type = 'D'  
 begin  
  If Exists (Select KR_Id  from T0040_KilometerRate_Master WITH (NOLOCK) Where KR_Id = @KR_Id)  
  Begin  
    Delete From T0040_KilometerRate_Master Where KR_Id =@KR_Id
   Return  
  End        
  
   End 
END
