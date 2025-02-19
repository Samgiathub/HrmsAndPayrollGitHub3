
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_DEPENDANT_DETAIL_IMPORT]	
	  @Row_ID numeric(18) output
	 ,@Cmp_ID numeric(18,0)
	 ,@Alpha_Emp_Code varchar(100)	
     ,@Name varchar(100)
	 ,@RelationShip varchar(20)
	 ,@BirthDate datetime
	 ,@D_Age numeric(18,1)
	 ,@Address varchar(1000)
	 ,@Share numeric(18,2)
	 ,@Is_Resi  numeric(1,0) 
	 ,@NomineeFor Varchar(30) = ''	    
	 ,@tran_type varchar(1)	 
	 ,@Row_No	numeric
	 ,@Log_Status numeric output
	 ,@GUID varchar(2000) = '' --Added by nilesh patel on 20062016
	 
 AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 
DECLARE @Emp_id numeric
select @Emp_id= emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id


IF @BirthDate = ''  
  SET @BirthDate  = NULL 

Set @Log_Status = 0

if isnull(@Emp_id,0) = 0 
	Begin
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Employee Does not Exists',0,'Employee Does not Exists.',GetDate(),'Employee Nominees',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
  
if not exists(SELECT 1 FROM T0040_Relationship_Master WITH (NOLOCK) where Cmp_Id = @cmp_id and Relationship = RTRIM(LTRIM(@RelationShip)))
	BEGIN
		Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Relationship Details Does not Exists',0,'Enter Valid Details of Relationship.',GetDate(),'Employee Nominees',@GUID)
		set @Log_Status = 1
		return @Log_Status
	End
	
Declare @Age numeric(18,2)
	set @Age= datediff(year,@BirthDate,getdate())
Declare @Share_Temp numeric(18,2)
	set @Share_Temp=0

IF @tran_type ='I'

	IF @Share <= 100
	
		BEGIN
			If exists(select Row_ID from T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK) where Emp_ID = @Emp_ID And Name=@Name And RelationShip=@RelationShip And BirthDate = @BirthDate AND Share=@Share)
				BEGIN 
					Set @Row_ID = 0
					return
				END

				--Added BY Jimit 14032019
				IF @BirthDate > GETDATE()
					BEGIN
							INSERT INTO dbo.T0080_Import_Log VALUES (0,@Cmp_Id,@Alpha_Emp_Code,'Future Birth Date is not Allowed.',0,'Enter Valid Birth Date',GETDATE(),'Employee Master',@GUID) 
							
							RETURN
					END				
				--ENDED

				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_DEPENDANT_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_DEPENDANT_DETAIL
				                      (Emp_ID, Row_ID, Cmp_ID, Name, RelationShip, BirthDate,D_Age,Address,Share,Is_Resi,NomineeFor)
				VALUES (@Emp_ID,@Row_ID,@Cmp_ID,@Name,@RelationShip,@BirthDate,@Age,@Address,@Share ,@Is_Resi,@NomineeFor)
		END 
		
	ELSE
	
		Begin
				Insert Into dbo.T0080_Import_Log Values (@Row_No,@Cmp_Id,@Alpha_Emp_Code,'Total Share Must be less than or equal to 100% ',0,'Total share must be 100%, not more than that.',GetDate(),'Employee Nominees',@GUID)
				set @Log_Status = 1
				return @Log_Status
		end
		
RETURN




