

---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0065_EMP_DOC_DETAIL_APP]
		 @Row_ID		as int output
		,@Emp_Tran_ID bigint
		,@Emp_Application_ID int
		,@Doc_ID		as int 
		,@Cmp_ID		as int 
		,@Doc_Path		as varchar(500)
		,@Doc_Comments	as varchar(250)
		,@tran_type varchar(1)
		,@Login_Id AS int=0-- Rathod '19/04/2012'
		,@Date_Of_Expiry  datetime   = Null
		,@Approved_Emp_ID int
		,@Approved_Date datetime = Null
		,@Rpt_Level int 
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
				if exists(select Doc_ID from T0065_EMP_DOC_DETAIL_APP WITH (NOLOCK)
				   Where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Doc_ID = @Doc_ID and Doc_Path = @Doc_Path )
					begin
						return 0
					end								
				
				
				select @Row_ID = isnull(max(Row_ID),0) +1 from T0065_EMP_DOC_DETAIL_APP WITH (NOLOCK)
			
				INSERT INTO T0065_EMP_DOC_DETAIL_APP
				           (Row_ID,Emp_Tran_ID,Emp_Application_ID, Cmp_ID, Doc_ID, Doc_Path, Doc_Comments,Date_of_Expiry,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID, @Cmp_ID, @Doc_ID, @Doc_Path, @Doc_Comments,@Date_Of_Expiry,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				
				
				
			end 
	Else If @tran_type ='U' 
				begin
				if exists(select Doc_ID from T0065_EMP_DOC_DETAIL_APP WITH (NOLOCK)
						Where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Doc_ID <> @Doc_ID )
					begin
						return 0
					end								
					UPDATE    T0065_EMP_DOC_DETAIL_APP
					SET       Doc_Comments =@Doc_Comments, Doc_Path =@Doc_Path, Doc_ID =@Doc_ID
							  ,Date_of_Expiry = @Date_Of_Expiry
							  ,Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
					WHERE     Row_ID = @Row_ID and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
					
					
				
				end
	Else If @tran_type ='D'
			Begin
				delete  from T0065_EMP_DOC_DETAIL_APP where Row_ID =@Row_ID and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
			End
					

	RETURN


