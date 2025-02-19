
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_DOC_DETAIL]
		 @Row_ID		as numeric output
		,@Doc_ID		as Numeric 
		,@Emp_ID		as Numeric 
		,@Cmp_ID		as numeric 
		,@Doc_Path		as varchar(500)
		,@Doc_Comments	as varchar(250)
		,@tran_type varchar(1)
		,@Login_Id AS numeric(18,0)=0-- Rathod '19/04/2012'
		,@Date_Of_Expiry  datetime 
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		if @Doc_ID = 0
		
		set @Doc_ID =null
		
		if @Date_Of_Expiry = ''  
		SET @Date_Of_Expiry  = NULL
		
		If @tran_type ='I' 
			begin
				if exists(select Doc_ID from T0090_EMP_DOC_DETAIL WITH (NOLOCK) Where Emp_ID = @Emp_ID and Doc_ID = @Doc_ID and Doc_Path = @Doc_Path )
					begin
						return 0
					end								
				
				
				select @Row_ID = isnull(max(Row_ID),0) +1 from T0090_EMP_DOC_DETAIL WITH (NOLOCK)
			
				INSERT INTO T0090_EMP_DOC_DETAIL
				                      (Row_ID, Emp_Id, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments,Date_of_Expiry)
				VALUES     (@Row_ID, @Emp_Id, @Cmp_ID, @Doc_ID, @Doc_Path, @Doc_Comments,@Date_Of_Expiry)
				
				INSERT INTO T0090_EMP_DOC_DETAIL_Clone
				                      (Row_ID, Emp_Id, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments,System_Date,Login_Id)
				VALUES     (@Row_ID, @Emp_Id, @Cmp_ID, @Doc_ID, @Doc_Path, @Doc_Comments,GETDATE(),@Login_Id)
				
				
			end 
	Else If @tran_type ='U' 
				begin
				if exists(select Doc_ID from T0090_EMP_DOC_DETAIL WITH (NOLOCK)  Where Emp_ID = @Emp_ID and Doc_ID <> @Doc_ID )
					begin
						return 0
					end								
					UPDATE    T0090_EMP_DOC_DETAIL
					SET       Doc_Comments =@Doc_Comments, Doc_Path =@Doc_Path, Doc_ID =@Doc_ID
							  ,Date_of_Expiry = @Date_Of_Expiry
					WHERE     Row_ID = @Row_ID and Emp_ID = @Emp_ID
					
					INSERT INTO T0090_EMP_DOC_DETAIL_Clone
				                      (Row_ID, Emp_Id, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments,System_Date,Login_Id)
				VALUES     (@Row_ID, @Emp_Id, @Cmp_ID, @Doc_ID, @Doc_Path, @Doc_Comments,GETDATE(),@Login_Id)
				
				end
	Else If @tran_type ='D'
			Begin
				delete  from T0090_EMP_DOC_DETAIL where Row_ID =@Row_ID and Emp_ID =@Emp_ID
			End
					

	RETURN




