

-- Created By Rohit For Import It Estimated Amount in the Master.
-- Created on 11052015
CREATE PROCEDURE [dbo].[P0100_Emp_Earn_Deduction_Update_For_It_Estimated_Import]    
 @Cmp_ID			NUMERIC ,    
 @Emp_Code			Varchar(100) ,    
 @AD_Sort_Name		VARCHAR(50),    
 @AD_Amount			NUMERIC(18,2),
 @GUID			    VARCHAR(2000) = '' --Added by Nilesh patel on 14062016
 
AS

 SET NOCOUNT ON 
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SET ARITHABORT ON     


 DECLARE @Emp_ID		NUMERIC     
 DECLARE @Increment_ID  NUMERIC
 DECLARE @For_Date		DATETIME     
 DECLARE @AD_ID			NUMERIC
 
 
	SELECT @Emp_ID = Emp_ID FROM T0080_Emp_Master e WITH (NOLOCK) WHERE Cmp_ID =@Cmp_ID  and Alpha_Emp_Code =@Emp_Code    
	SELECT @AD_ID = AD_ID FROM T0050_AD_MAster WITH (NOLOCK) WHERE cmp_ID =@Cmp_ID AND (UPPER(AD_SORT_NAME) =UPPER(@AD_Sort_Name)  OR UPPER(AD_SORT_NAME) =UPPER(replace(@AD_Sort_Name,' ','_')) )  
	 
	 If @Emp_ID= null
		Set @Emp_ID = 0
	
	 IF @AD_ID = null
		Set @AD_ID = 0
	 
	 if @EMP_ID = 0
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'Employee Doesn''t exists',@EMP_ID,'Employee Doesn''t exists',GetDate(),'IT Estimated Amount',@GUID)
			return
		End
	 
	 if @AD_ID = 0
		Begin
			Insert Into dbo.T0080_Import_Log Values (0,@Cmp_Id,@EMP_ID,'Allowance Doesn''t exists',@EMP_ID,'Allowance Doesn''t exists',GetDate(),'IT Estimated Amount',@GUID)
			return
		End
	     
	 IF @Emp_ID = 0 OR @AD_ID = 0     
	  RETURN
	   
		SELECT @Increment_ID =I.Increment_ID FROM T0095_Increment i WITH (NOLOCK) INNER JOIN
			(select Max(TI.Increment_ID) Increment_Id,ti.Emp_ID from t0095_increment TI WITH (NOLOCK) inner join
				(Select Max(Increment_Effective_Date) as Increment_Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
				Where Increment_effective_Date <= GETDATE() and increment_type<>'transfer' Group by emp_ID) new_inc
				on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Increment_Effective_Date
				Where TI.Increment_effective_Date <= GETDATE() and increment_type<>'transfer' group by ti.emp_id) Qry on i.Increment_Id = Qry.Increment_Id and I.Emp_ID =Qry.Emp_ID 
		WHERE I.Emp_ID =@Emp_ID      


			IF  @Increment_ID > 0
				BEGIN
						UPDATE T0100_EMP_EARN_DEDUCTION 
							SET It_Estimated_Amount = @AD_Amount
						WHERE  EMP_ID =@EMP_ID AND AD_ID =@AD_ID AND Increment_ID =@Increment_ID
				END
	
	   
RETURN    
    
  


