
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_IMMIGRATION_DETAIL_APP]
		@Row_ID int output
		,@Emp_Tran_ID bigint
		,@Emp_Application_ID int
  		,@Cmp_ID int
  		,@Loc_ID int
		,@Imm_Type varchar(20)
		,@Imm_No varchar(20)
		,@Imm_Issue_Date datetime
		,@Imm_Issue_Status varchar(20)
		,@Imm_Review_Date datetime
		,@Imm_Comments varchar(250)
		,@Imm_Date_of_Expiry datetime		
		,@tran_type varchar(1)
		,@Login_id int=0-- Rathod '18/04/2012'
		,@attach_doc nvarchar(max)=''  --Mukti 06072015
		,@Approved_Emp_ID int
		,@Approved_Date datetime = Null
		,@Rpt_Level int 
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		if @Imm_Review_Date = '01/01/1900'
			Begin
				Set @Imm_Review_Date = null
			End 
		if @tran_type ='i' 
			begin
					if exists( select Row_ID from T0065_EMP_IMMIGRATION_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And cmp_ID = @cmp_ID And Imm_Issue_Date = @Imm_Issue_Date AND Imm_type = @Imm_Type)
					begin 
						set @Row_ID = 0
						return
					end 
					select @Row_ID = isnull(max(Row_ID),0) from T0065_EMP_IMMIGRATION_DETAIL_APP WITH (NOLOCK)
					if @Row_ID is null or @Row_ID = 0
						set @Row_ID =1
					else
						set @Row_ID = @Row_ID + 1			
						
					INSERT INTO T0065_EMP_IMMIGRATION_DETAIL_APP
					                      (Row_ID,Emp_Tran_ID,Emp_Application_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,attach_doc,Approved_Emp_ID,Approved_Date,Rpt_Level)
					VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,@attach_doc,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
					/*INSERT INTO T0065_EMP_IMMIGRATION_DETAIL_APP_Clone
					                      (Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,System_Date,Login_id)
					VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,GETDATE(),@Login_id)		*/
				end 
	else if @tran_type ='u' 
				Begin
				if exists(select Row_ID from T0065_EMP_IMMIGRATION_DETAIL_APP WITH (NOLOCK) where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID And cmp_ID = @cmp_ID And Imm_Issue_Date = @Imm_Issue_Date And Row_ID <> @Row_ID AND Imm_type = @Imm_Type)
					begin 
						set @Row_ID = 0
						return
					end 
				
				
					UPDATE    T0065_EMP_IMMIGRATION_DETAIL_APP
					SET              Cmp_ID = @Cmp_ID, Imm_Type = @Imm_Type, Imm_No = @Imm_No, Imm_Issue_Date = @Imm_Issue_Date, 
				                      Imm_Issue_Status = @Imm_Issue_Status, Imm_Date_of_Expiry = @Imm_Date_of_Expiry, Imm_Review_Date = @Imm_Review_Date, 
				                      Imm_Comments = @Imm_Comments ,attach_doc=@attach_doc,
				                      Loc_ID  = @Loc_ID,
				                      Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level
				                      where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Row_ID = @Row_ID	
				                      
				      /* INSERT INTO T0065_EMP_IMMIGRATION_DETAIL_APP_Clone
					           (Row_ID, Emp_ID, Cmp_ID, Imm_Type, Imm_No, Imm_Issue_Date, Imm_Issue_Status, Imm_Review_Date, Imm_Comments, Imm_Date_of_Expiry,Loc_ID,System_Date,Login_id)
					VALUES     (@Row_ID,@Emp_ID,@Cmp_ID,@Imm_Type,@Imm_No,@Imm_Issue_Date,@Imm_Issue_Status,@Imm_Review_Date,@Imm_Comments,@Imm_Date_of_Expiry,@Loc_ID,GETDATE(),@Login_id)		                 */
				end
	else if @tran_type ='d'
					delete  from T0065_EMP_IMMIGRATION_DETAIL_APP where Row_ID = @Row_ID
	RETURN


