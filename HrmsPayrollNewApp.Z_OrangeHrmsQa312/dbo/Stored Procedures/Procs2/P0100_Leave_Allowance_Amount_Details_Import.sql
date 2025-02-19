CREATE PROCEDURE [dbo].[P0100_Leave_Allowance_Amount_Details_Import]    
 @Cmp_ID			NUMERIC ,    
 @Emp_Code			Varchar(40) ,    
 @Effective_Date	Datetime,    
 @Leave_Name		VARCHAR(50),    
 @Amount			NUMERIC (18,2),
 @GUID				Varchar(2000) = '' --Added by Nilesh patel on 14062016
  
AS    
 SET NOCOUNT ON     
 
 DECLARE @Emp_ID		NUMERIC     
 DECLARE @Leave_Id			NUMERIC
 DECLARE @Tran_ID		NUMERIC
 
 
 
 IF @Emp_Code = '' OR @Effective_Date=''
  RETURN
     
 SET @Leave_Id = 0
 Set @Emp_ID = 0
 
 SELECT @Emp_ID = Emp_ID FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and Alpha_Emp_Code =@Emp_Code
 SELECT @Leave_Id=LEAVE_ID FROM t0040_LEAVE_MASTER WITH (NOLOCK) WHERE LEAVE_Name =@LEAVE_NAME And cmp_Id=@Cmp_Id 
 
 If @Emp_ID= null
	Set @Emp_ID = 0
	
 if @Leave_Id = null
	Set @Leave_Id = 0
 
 if @Emp_Id =0
	begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Employee Doesn''t exists',@EMP_CODE ,'Enter proper Employee Code',GetDate(),'Leave Allowance',@GUID)			
		return			
	end	

 if @Leave_Id = 0
	begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Leave Name Doesn''t exists',@EMP_CODE ,'Please Eneter Correct Leave Name',GetDate(),'Leave Allowance',@GUID)			
		return			
	end	
	
 if @Effective_Date IS NULL
	begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Invalid Effective Date',@EMP_CODE ,'Please Enter Correct Effective Date',GetDate(),'Leave Allowance',@GUID)			
		return			
	end	
	
  if @Amount < 0 
	Begin
		Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_CODE ,'Enter Correct Leave Amount',@EMP_CODE ,'Please Enter Correct Leave Amount',GetDate(),'Leave Allowance',@GUID)			
		return
	End
	
 SELECT @Leave_Id = Leave_Id FROM T0040_leave_master WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND UPPER(Leave_Name) =UPPER(@Leave_Name)    
     
 IF @Emp_ID = 0 OR @Leave_Id = 0     
  RETURN
    
 IF EXISTS(SELECT Emp_ID FROM T0100_Leave_Allowance_Amount_Details WITH (NOLOCK) WHERE EMP_ID =@EMP_ID AND Leave_Id =@Leave_Id AND Effective_Date=@Effective_Date)               
   BEGIN    
		DELETE from T0100_Leave_Allowance_Amount_Details WHERE EMP_ID =@EMP_ID AND Leave_Id =@Leave_Id AND Effective_Date=@Effective_Date
	
			SELECT @Tran_ID =ISNULL(MAX(tran_ID),0) +1 FROM T0100_Leave_Allowance_Amount_Details WITH (NOLOCK)    
			 INSERT INTO T0100_Leave_Allowance_Amount_Details    
                          (Tran_ID, Cmp_ID,Emp_ID, Leave_ID, Effective_Date, Amount,Sys_Date)    
		     VALUES     (@Tran_ID, @Cmp_ID,@Emp_ID, @Leave_ID, @Effective_Date, @Amount, GetDate())     
  
   END    
 ELSE    
   BEGIN    
		SELECT @Tran_ID =ISNULL(MAX(tran_ID),0) +1 FROM T0100_Leave_Allowance_Amount_Details WITH (NOLOCK)   
			 INSERT INTO T0100_Leave_Allowance_Amount_Details    
                          (Tran_ID, Cmp_ID,Emp_ID, Leave_ID, Effective_Date, Amount,Sys_Date)    
		     VALUES     (@Tran_ID, @Cmp_ID,@Emp_ID, @Leave_ID, @Effective_Date, @Amount, GetDate())     
   END      
   
 RETURN    
