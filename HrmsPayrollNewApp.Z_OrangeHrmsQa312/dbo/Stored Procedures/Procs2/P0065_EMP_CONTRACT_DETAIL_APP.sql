
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_CONTRACT_DETAIL_APP]
 @TRAN_ID INT OUTPUT
,@Emp_Tran_ID bigint
,@Emp_Application_ID int
,@CMP_ID INT
,@PRJ_ID INT
,@START_DATE DATETIME
,@END_DATE DATETIME
,@IS_RENEW TINYINT
,@IS_REMINDER TINYINT
,@COMMENTS VARCHAR(200)
,@TRAN_TYPE CHAR
,@Login_Id INT=0 -- Rathod '24/04/2012'
,@Approved_Emp_ID int
,@Approved_Date datetime = Null
,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TRAN_TYPE  = 'I'
		Begin
			If Exists(Select TRAN_ID From T0065_EMP_CONTRACT_DETAIL_APP WITH (NOLOCK)  
			Where Cmp_ID = @Cmp_ID and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
			And Prj_ID=@prj_Id And @Is_renew=0)
					begin
						set @TRAN_ID = 0
						Return 
					end
				select @TRAN_ID = Isnull(max(TRAN_ID),0) + 1 	From T0065_EMP_CONTRACT_DETAIL_APP WITH (NOLOCK)
				
				INSERT INTO T0065_EMP_CONTRACT_DETAIL_APP 
				                      (TRAN_ID, CMP_ID, Emp_Tran_ID,Emp_Application_ID, PRJ_ID, START_DATE, END_DATE, IS_RENEW,IS_REMINDER,COMMENTS,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES     (@TRAN_ID,@CMP_ID,@Emp_Tran_ID,@Emp_Application_ID,@PRJ_ID,@START_DATE,@END_DATE,@IS_RENEW,@IS_REMINDER,@COMMENTS,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				
			/*	INSERT INTO T0065_EMP_CONTRACT_DETAIL_APP _Clone
				            (TRAN_ID, CMP_ID, EMP_ID, PRJ_ID, START_DATE, END_DATE, IS_RENEW,IS_REMINDER,COMMENTS,System_Date,Login_Id)
				VALUES     (@TRAN_ID,@CMP_ID,@EMP_ID,@PRJ_ID,@START_DATE,@END_DATE,@IS_RENEW,@IS_REMINDER,@COMMENTS,GETDATE(),@Login_Id)
				*/
						
								
		End
	Else if @TRAN_TYPE = 'U'
		begin
				If Exists(Select TRAN_ID From T0065_EMP_CONTRACT_DETAIL_APP WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID 
				and Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID
				 And Prj_ID=@prj_Id And @Is_renew=0 And TRAN_ID <> @TRAN_ID)
					begin
						set @TRAN_ID = 0
						Return 
					end
				UPDATE    T0065_EMP_CONTRACT_DETAIL_APP 
				SET
				CMP_ID=@CMP_ID
				,PRJ_ID=@PRJ_ID
				,START_DATE=@START_DATE
				,END_DATE=@END_DATE
				,IS_RENEW=@IS_RENEW
				,IS_REMINDER=@IS_REMINDER
				,COMMENTS=@COMMENTS
				,Approved_Emp_ID=@Approved_Emp_ID
				,Approved_Date=@Approved_Date
				,Rpt_Level=@Rpt_Level
				WHERE     (Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID) 
							AND (TRAN_ID = @TRAN_ID)
				
			/*	INSERT INTO T0065_EMP_CONTRACT_DETAIL_APP _Clone
				            (TRAN_ID, CMP_ID, EMP_ID, PRJ_ID, START_DATE, END_DATE, IS_RENEW,IS_REMINDER,COMMENTS,System_Date,Login_Id)
				VALUES     (@TRAN_ID,@CMP_ID,@EMP_ID,@PRJ_ID,@START_DATE,@END_DATE,@IS_RENEW,@IS_REMINDER,@COMMENTS,GETDATE(),@Login_Id)
				
				*/
		
		   end
	Else if @TRAN_TYPE = 'D'
		begin
			
			DELETE FROM T0065_EMP_CONTRACT_DETAIL_APP 
			WHERE     (TRAN_ID = @TRAN_ID)
		end

	RETURN


