
CREATE PROCEDURE [dbo].[P0090_EMP_EMERGENCY_CONTACT_DETAIL_IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@Name varchar(100)
	 ,@RelationShip varchar(20)
	 ,@HomeTelNo varchar(10)
	 ,@HomeMobileNo Varchar(10) 	    
	 ,@WorkTelNo Varchar(10) 	    
	 ,@tran_type varchar(1)	 
	 ,@Row_No	numeric
	 ,@Log_Status numeric output
	 ,@GUID varchar(2000) = '' 
	 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 
 --Created By ronakk 25052022

DECLARE @Emp_id numeric
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id



Set @Log_Status = 0

if isnull(@Emp_id,0) = 0 
	Begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Does not Exists',0,'Employee Does not Exists.',GetDate(),'Emergency Contact',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
  
if not exists(SELECT 1 FROM T0040_Relationship_Master WITH (NOLOCK) where Cmp_Id = @cmp_id and Relationship = RTRIM(LTRIM(@RelationShip)))
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Relationship Details Does not Exists',0,'Enter Valid Details of Relationship.',GetDate(),'Emergency Contact',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
	
--Add by ronakk 27052022
if @WorkTelNo <>''
Begin
	if ISNUMERIC(@HomeTelNo)=0
	Begin
		    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Please enter Home Phone Properly.',0,'Please enter Home Phone Properly.',GetDate(),'Emergency Contact',@GUID)
			set @Log_Status = 1
			return @Log_Status
	End
End

--Add by ronakk 27052022
if @WorkTelNo <>''
Begin
		if ISNUMERIC(@HomeMobileNo)=0
		Begin
			    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Please enter Mobile Properly.',0,'Please enter Mobile Properly.',GetDate(),'Emergency Contact',@GUID)
				set @Log_Status = 1
				return @Log_Status
		End
End

--Add by ronakk 27052022
if @WorkTelNo <>''
Begin
         if ISNUMERIC(@WorkTelNo)=0
	     Begin
	     	    Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Please enter Work Phone Properly.',0,'Please enter Work Phone Properly.',GetDate(),'Emergency Contact',@GUID)
	     		set @Log_Status = 1
	     		return @Log_Status
	     End
End




IF @tran_type ='I'


			If exists(select Row_ID from T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And RelationShip=@RelationShip  )--And Home_Mobile_No = @HomeMobileNo
				BEGIN 
					Set @Row_ID = 0
					return
				END

				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_EMERGENCY_CONTACT_DETAIL
				                      (Emp_ID, Row_ID, Cmp_ID, Name, RelationShip,Home_Tel_No,Home_Mobile_No,Work_Tel_No)
				VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@RelationShip,@HomeTelNo,@HomeMobileNo,@WorkTelNo)
	
RETURN




