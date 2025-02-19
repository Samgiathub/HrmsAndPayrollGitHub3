
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_ASSET_DETAIL] 
 @Emp_Asset_ID	numeric output
,@Cmp_ID		numeric
,@Emp_ID		numeric
,@Asset_ID		numeric 
,@Model_no		varchar(20)
,@Issue_Date	datetime
,@Return_Date	datetime
,@Asset_Comment varchar(150)  
,@Tran_Type     char(1)
,@login_Id numeric(18,0) -- Rathod '18/04/2012'
		
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

if @return_Date = ''  
  SET @return_Date  = NULL 
  
   
if @Tran_Type = 'I'
	Begin
		IF EXISTS(Select Emp_Asset_ID from T0090_EMP_ASSET_DETAIL WITH (NOLOCK) where Asset_id = @Asset_ID And Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID And Issue_Date = @Issue_Date)
			Begin
				Set @Emp_Asset_ID = 0
				Return
			End 
		Select @Emp_Asset_ID = isnull(max(Emp_Asset_ID),0) +1 FROM T0090_EMP_ASSET_DETAIL WITH (NOLOCK)
		
		Insert into T0090_EMP_ASSET_DETAIL (Emp_Asset_ID,Cmp_ID,Emp_ID,Asset_ID,Model_No,Issue_Date,Return_Date,Asset_Comment)
								Values(@Emp_Asset_ID,@Cmp_ID,@Emp_ID,@Asset_ID,@Model_No,@Issue_Date,@Return_Date,@Asset_Comment)
								
		Insert into T0090_EMP_ASSET_DETAIL_Clone (Emp_Asset_ID,Cmp_ID,Emp_ID,Asset_ID,Model_No,Issue_Date,Return_Date,Asset_Comment,System_Date,login_Id)
		Values(@Emp_Asset_ID,@Cmp_ID,@Emp_ID,@Asset_ID,@Model_No,@Issue_Date,@Return_Date,@Asset_Comment,GETDATE(),@login_Id)
	End
	
Else if @Tran_Type = 'U'
	Begin
		IF EXISTS(Select Emp_Asset_ID from T0090_EMP_ASSET_DETAIL WITH (NOLOCK) where Asset_id = @Asset_ID And Cmp_ID = @Cmp_ID And Emp_ID = @Emp_ID And Issue_Date = @Issue_Date And Emp_Asset_ID <> @Emp_Asset_ID )
			Begin
				Set @Emp_Asset_ID = 0
				Return
			End
		Update 	T0090_EMP_ASSET_DETAIL
		Set     Asset_ID = @Asset_ID,
				Model_no = @Model_no,
				Issue_Date = @Issue_Date,
				return_Date = @return_Date,
				Asset_Comment = @Asset_Comment
		Where   Emp_Asset_ID = @Emp_Asset_ID		
		
		Insert into T0090_EMP_ASSET_DETAIL_Clone (Emp_Asset_ID,Cmp_ID,Emp_ID,Asset_ID,Model_No,Issue_Date,Return_Date,Asset_Comment,System_Date,login_Id)
		Values(@Emp_Asset_ID,@Cmp_ID,@Emp_ID,@Asset_ID,@Model_No,@Issue_Date,@Return_Date,@Asset_Comment,GETDATE(),@login_Id)	
	End
Else if @Tran_Type = 'D'	
	Begin
			Delete from T0090_EMP_ASSET_DETAIL where Emp_Asset_ID = @Emp_Asset_ID
	
	End
	
RETURN










