



---==================================================
--CREATED BY: NILAY
--DESCRIPTION: OPTIONAL HOLIDAY EMPLOYEE APPROVAL
--DATE CREATED: 04/04/2013
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---==================================================
CREATE PROCEDURE [dbo].[P0120_OP_HOLIDAY_APPLICATION]    
   @OP_Holiday_Apr_ID		NUMERIC OUTPUT    
  ,@OP_Holiday_App_ID		NUMERIC   
  ,@Emp_ID					NUMERIC 
  ,@Cmp_ID					NUMERIC       
  ,@Hday_ID					NUMERIC    
  ,@S_Emp_ID				NUMERIC    
  ,@Op_Holiday_Apr_Date		DATETIME
  ,@Op_Holiday_Apr_Status		CHAR(1)	
  ,@Op_Holiday_Apr_Comment		VARCHAR(4000)
  ,@Created_By				NUMERIC      
  ,@Date_Created			DATETIME
  ,@Modify_By				NUMERIC      
  ,@Date_Modified			DATETIME
  ,@Tran_Type				CHAR(1)
     
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
     


IF @Tran_Type = 'I'     
   BEGIN  
   
     
   IF Exists(SELECT 1 from T0100_OP_Holiday_Application WITH (NOLOCK) WHERE HDAY_id=@Hday_ID AND Emp_ID=@eMP_id)
   BEGIN
		RAISERROR ('Already Exists', 16, 2) 
		RETURN		
   END	
                    
	SELECT @OP_Holiday_Apr_ID = isnull(max(Op_Holiday_Apr_ID),0) +1 FROM dbo.T0120_Op_Holiday_Approval  WITH (NOLOCK)   
    INSERT INTO dbo.T0120_Op_Holiday_Approval    
                 (Op_Holiday_Apr_ID,
                  Op_Holiday_App_ID,                 
                  Emp_ID,
                  Cmp_ID,                  
                  HDay_ID,                 
                  S_Emp_ID,
                  Op_Holiday_Apr_Date,
                  Op_Holiday_Apr_Status,                                  
                  Op_Holiday_Apr_Comments,
                  Created_By,
                  Date_Created,
                  Modify_By,
                  Date_Modified)                  
      VALUES (@OP_Holiday_Apr_ID,
			  @OP_Holiday_App_ID,			 
			  @Emp_ID,
			  @Cmp_ID,
			  @Hday_ID,
			  @S_Emp_ID,
			  @Op_Holiday_Apr_Date,
			  @Op_Holiday_Apr_Status,
			  @Op_Holiday_Apr_Comment,
			  @Created_By,
			  @Date_Created,
			  @Modify_By,
			  @Date_Modified)			  			  			  
   END
   
 ELSE IF @Tran_Type ='U'     
    BEGIN                
    UPDATE    dbo.T0120_Op_Holiday_Approval    
    SET			  Op_Holiday_Apr_ID			= @OP_Holiday_Apr_ID ,
                  Op_Holiday_App_ID			= @OP_Holiday_App_ID,                 
                  Emp_ID					= @Emp_ID,
                  Cmp_ID					= @Cmp_ID ,                  
                  HDay_ID					= @Hday_ID,                 
                  S_Emp_ID					= @S_Emp_ID, 
                  Op_Holiday_Apr_Date		= @Op_Holiday_Apr_Date,
                  Op_Holiday_Apr_Status		= @Op_Holiday_Apr_Status,                                  
                  Op_Holiday_Apr_Comments	= @Op_Holiday_Apr_Comment ,
                  Created_By				= @Created_By,
                  Date_Created				= @Date_Created ,
                  Modify_By					= @Modify_By,
                  Date_Modified				=  @Date_Modified       		
    WHERE Op_Holiday_App_ID = @OP_Holiday_App_ID            
   END    
 ELSE IF @tran_type ='D'    
  BEGIN         
	
	if Exists(SELECT 1 from T0120_Op_Holiday_Approval WITH (NOLOCK) where Op_Holiday_App_ID = @OP_Holiday_App_ID)
	BEGIN
		return
	end	
	DELETE FROM dbo.T0100_OP_Holiday_Application where Op_Holiday_App_ID = @OP_Holiday_App_ID and Op_Holiday_Status='P'       
  END    
 RETURN


