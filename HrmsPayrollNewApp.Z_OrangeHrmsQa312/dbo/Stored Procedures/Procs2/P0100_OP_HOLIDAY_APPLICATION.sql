---==================================================
--CREATED BY: NILAY
--DESCRIPTION: OPTIONAL HOLIDAY EMPLOYEE APPLICATION
--DATE CREATED: 04/04/2013
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
---==================================================
CREATE PROCEDURE [dbo].[P0100_OP_HOLIDAY_APPLICATION]    
   @OP_Holiday_App_ID	NUMERIC OUTPUT    
  ,@Cmp_ID			    NUMERIC    
  ,@Emp_ID				NUMERIC    
  ,@Hday_ID				NUMERIC    
  ,@Op_Holiday_Date		DATETIME      
  ,@Op_Holiday_Status	CHAR(1)	
  ,@Op_Holiday_Comment  VARCHAR(4000)
  ,@Created_By			NUMERIC      
  ,@Date_Created		DATETIME
  ,@Modify_By			NUMERIC      
  ,@Date_Modified		DATETIME
  ,@Tran_Type			CHAR(1)
     
AS    
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

 -- Added By Sajid and Deepal for IFSCA 30-12-2021
  Declare @Setting_Value INT = 0
   Select @Setting_Value= Setting_Value From T0040_SETTING  WITH (NOLOCK) 
      Where Setting_Name='This Months Salary Exists Validation If Salary Geneated.' and Cmp_ID=@cmp_Id
  if (@Setting_Value = 0)
  BEGIN

IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WITH (NOLOCK) WHERE Emp_ID=@Emp_Id and  Month_End_Date >= @Op_Holiday_Date and Cmp_ID = @Cmp_ID)
				BEGIN
					RAISERROR ('Current Months Salary Exists', 16, 2) 
					RETURN
				END 
				END
				
				
	DECLARE @Optional_Holiday_Approval_Days as numeric(18,0)
	DECLARE @Approval_Days as numeric(18,0)
	DECLARE @Branch_id as numeric(18,0)  --Added by Ramiz on 15092014
	
	--Select @Optional_Holiday_Approval_Days = Optional_HOliday_days from T0040_General_setting where Cmp_ID=@Cmp_ID and  Branch_ID 
	--in ( SELECT Branch_ID from T0080_EMP_MASTER where Emp_ID=@Emp_ID and Cmp_ID= @Cmp_ID) 
	--and For_Date = (select max(for_date) From T0040_General_Setting where Cmp_ID = @Cmp_ID and Branch_ID in ( SELECT Branch_ID from T0080_EMP_MASTER where Emp_ID=@Emp_ID and Cmp_ID= @Cmp_ID))  
	
		-------Commented and Added by Ramiz on 15092014  ----------
	-- Commented and added by rohit for take branch id from increment table in place of employee master.
		select @Branch_ID = Branch_ID From T0095_Increment I WITH (NOLOCK) inner join 
		(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= @Op_Holiday_Date Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= @Op_Holiday_Date group by ti.emp_id) Qry on 
				I.Emp_ID = Qry.Emp_ID and I.Increment_ID = Qry.Increment_ID Where I.Emp_ID = @Emp_ID	
	--	SELECT @Branch_id = Branch_ID from T0080_EMP_MASTER where Emp_ID=@Emp_ID and Cmp_ID= @Cmp_ID
	-- Ended by rohit	
		Select @Optional_Holiday_Approval_Days = Optional_HOliday_days from T0040_General_setting WITH (NOLOCK) where Cmp_ID=@Cmp_ID and Branch_ID = @Branch_id and
		For_Date = (select max(for_date) From T0040_General_Setting WITH (NOLOCK) where Cmp_ID = @Cmp_ID and Branch_ID =@branch_id)  		
		
		-------Ended by Ramiz on 15092014  ----------	
		
		Declare @F_StartDate datetime	--Ankit 05012015
		Declare @F_EndDate Datetime
		SET @F_StartDate= DATEADD(yy, DATEDIFF(yy,0,@Op_Holiday_Date), 0) 
		SET @F_EndDate = DATEADD(yy, DATEDIFF(yy,0,@Op_Holiday_Date) + 1, -1)
				
		SELECT @Approval_Days= COUNT(Op_Holiday_App_ID) 
		FROM T0100_OP_Holiday_Application WITH (NOLOCK)
		where emp_ID=@Emp_ID and Cmp_ID=@Cmp_ID  and (Op_Holiday_Status = 'A' or Op_Holiday_Status = 'P')
				And Op_Holiday_Date >= @F_StartDate And Op_Holiday_Date <= @F_EndDate	--Ankit 05012015
    
IF @Tran_Type = 'I'     
   BEGIN         
   	  
    IF @Approval_Days >= @Optional_Holiday_Approval_Days
     BEGIN    
		RAISERROR ('Exceed Limit', 16, 2) 
	    RETURN	
     END	
    		
   
  IF Exists(SELECT 1 from T0100_OP_Holiday_Application WITH (NOLOCK) WHERE HDAY_id=@Hday_ID AND Emp_ID=@eMP_id AND Cmp_ID=@Cmp_ID)
   BEGIN
		RAISERROR ('Already Exists', 16, 2) 
		RETURN		
   END
	
		SET @Modify_By = NULL	
		SET @Date_Modified = NULL 
	
	 
	
	SELECT @OP_Holiday_App_ID = isnull(max(Op_Holiday_App_ID),0) +1 FROM dbo.T0100_OP_Holiday_Application  WITH (NOLOCK)
	
	Select @OP_Holiday_App_ID
    INSERT INTO dbo.T0100_OP_Holiday_Application    
                 (Op_Holiday_App_ID,                 
                  Cmp_ID,
    Emp_ID,
                  HDay_ID,                 
                  Op_Holiday_Date,
                  Op_Holiday_Status,                                  
                  Op_Holiday_Comment,
                  Created_By,
                  Date_Created,
                  Modify_By,
                  Date_Modified)                  
      VALUES (@OP_Holiday_App_ID,
			  @Cmp_ID,
			  @Emp_ID,
			  @Hday_ID,
			  @Op_Holiday_Date,
			  @Op_Holiday_Status,
			  @Op_Holiday_Comment,
			  @Created_By,
			  @Date_Created,
			  @Modify_By,
			  @Date_Modified)			  			  			  
   END
   
 ELSE IF @Tran_Type ='U'     
    BEGIN                
    UPDATE    dbo.T0100_OP_Holiday_Application    
    SET			  Op_Holiday_App_ID   = @OP_Holiday_App_ID,                 
                  Cmp_ID			  = @Cmp_ID,
                  HDay_ID			  = @HDay_ID,                 
                  Emp_ID              = @Emp_ID,                  
                  Op_Holiday_Date	  = @Op_Holiday_Date,
                  Op_Holiday_Status	  = @Op_Holiday_Status,                                  
                  Op_Holiday_Comment  = @Op_Holiday_Comment,
                  Created_By		  = @Created_By,
                  Date_Created		  = @Date_Created,
                  Modify_By			  = @Modify_By,
                  Date_Modified		  = @Date_Modified          		
    WHERE Op_Holiday_App_ID = @OP_Holiday_App_ID     AND Cmp_ID=@Cmp_ID       
   END    
 ELSE IF @tran_type ='D'    
  BEGIN  
	
	IF EXISTS(SELECT 1 from T0120_Op_Holiday_Approval WITH (NOLOCK) where Op_Holiday_App_ID = @OP_Holiday_App_ID AND Cmp_ID=@Cmp_ID)
	BEGIN
		RAISERROR ('Can not delete records', 16, 2)
		RETURN
	END
         
    DELETE FROM dbo.T0100_OP_Holiday_Application where Op_Holiday_App_ID = @OP_Holiday_App_ID   AND Cmp_ID=@Cmp_ID  
  END    
 RETURN


