



---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_ASSET_DETAIL_IMPORT]	
	  @Emp_Asset_ID numeric(18) output
	 ,@Cmp_ID numeric
	 ,@Alpha_Emp_Code varchar(100)
	 ,@Emp_Name	varchar(50)
     ,@Asset_Name	varchar(20) 
	 ,@Model_no	varchar(20)
	 ,@Issue_Date datetime
	 ,@Return_Date datetime
	 ,@Asset_Comment varchar(150) 
     ,@Tran_Type varchar(1)	 
	 
 AS
 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
 
 
DECLARE @Emp_id numeric
Declare @Asset_ID numeric

select @Emp_id = emp_id  from T0080_EMP_MASTER WITH (NOLOCK) where Alpha_Emp_Code = @Alpha_Emp_Code  and Cmp_ID = @cmp_id
select @Asset_ID = Asset_ID from T0040_Asset_Master WITH (NOLOCK) where Asset_Name=@Asset_Name and Cmp_ID=@Cmp_ID
 
  
 If @Return_Date = ''  
   SET @Return_Date  = NULL

IF @Tran_Type ='I'
		
		BEGIN 
		 	
			If exists(select Emp_Asset_ID from T0090_EMP_ASSET_DETAIL WITH (NOLOCK) where Asset_id = @Asset_ID And Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID And Issue_Date = @Issue_Date And Return_Date=@Return_Date)
				BEgin 
					Set @Emp_Asset_ID = 0
					return
				End
				select @Emp_Asset_ID = Isnull(max(Emp_Asset_ID),0) + 1 	From T0090_EMP_ASSET_DETAIL WITH (NOLOCK)
			
				Insert into  T0090_EMP_ASSET_DETAIL (Emp_Asset_ID,Cmp_ID,Emp_ID,Asset_ID,Model_No,Issue_Date,Return_Date,Asset_Comment)
				Values		(@Emp_Asset_ID,@Cmp_ID,@Emp_ID,@Asset_ID,@Model_No,@Issue_Date,@Return_Date,@Asset_Comment)
		END
		
RETURN





