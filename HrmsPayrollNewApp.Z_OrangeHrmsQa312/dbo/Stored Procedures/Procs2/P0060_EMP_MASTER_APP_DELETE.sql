
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0060_EMP_MASTER_APP_DELETE]
	 @Emp_Tran_ID	bigint output,
	 @Emp_ID		INT
AS	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	DECLARE @Next_Emp_Tran_ID AS BIGINT
	
		IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Emp_Tran_ID AND Approved_Emp_ID<>@Emp_ID)
			BEGIN 
				IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Ref_Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status <> 'P')
					BEGIN
						SET @Emp_Tran_ID = 0
						RAISERROR('@@Record cannot be deleted of other user!@@', 16,1)
						RETURN
					END
			END
			
			--Select @Emp_Tran_ID
		IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Emp_Tran_ID AND Approved_Emp_ID=@Emp_ID AND Is_Final_Approval = 1)
			BEGIN 
				SET @Emp_Tran_ID = 0
				RAISERROR('@@Record cannot be deleted once confirmed!@@', 16,1)
				RETURN
			END
	
		IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Ref_Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status <> 'P')
			BEGIN 
				SET @Emp_Tran_ID = 0
				RAISERROR('@@Next Level Reference Already Exist!@@', 16,1)
				RETURN
			END
			
		IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Ref_Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status = 'P')			
			BEGIN 
				
				SELECT	@Next_Emp_Tran_ID = ISNULL(Emp_Tran_ID,0)
				FROM	T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Ref_Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status = 'P'				
				
				EXEC SP_DELETE_EMP_MASTER_APP @Emp_Tran_ID=@Next_Emp_Tran_ID		
					
			END
			
		IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status <> 'P' And Is_Final_Approval=0)
			BEGIN
			
				UPDATE	APP
				SET		Approve_Status = 'P'
				FROM	T0060_EMP_MASTER_APP APP 
				WHERE	Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status <> 'P' And Is_Final_Approval=0	
				
				
							
			END
		ELSE IF EXISTS(SELECT 1 FROM T0060_EMP_MASTER_APP WITH (NOLOCK) WHERE Emp_Tran_ID=@Emp_Tran_ID AND Approve_Status = 'P' And Is_Final_Approval=0)
			BEGIN
			
				Declare @Prev_Approve_Status CHAR(1)
				Declare @Prev_Emp_Tran_ID BIGINT			
			
			
				SELECT @Prev_Emp_Tran_ID=ISNULL(Ref_Emp_Tran_ID,0) 
				FROM T0060_EMP_MASTER_APP WITH (NOLOCK) 
				WHERE Emp_Tran_ID=@Emp_Tran_ID 
				
				SELECT @Prev_Approve_Status= ISNULL(Approve_Status,'')
				FROM T0060_EMP_MASTER_APP  WITH (NOLOCK)
				WHERE Emp_Tran_ID=@Prev_Emp_Tran_ID 
				
				
				
				IF 	@Prev_Approve_Status ='A'
				BEGIN
				
					UPDATE	APP
					SET		Approve_Status = 'P'
					FROM	T0060_EMP_MASTER_APP APP 
					WHERE	APP.Emp_Tran_ID=@Prev_Emp_Tran_ID and APP.Approved_Emp_ID=@Emp_ID
					
					
				END			
				
				EXEC SP_DELETE_EMP_MASTER_APP @Emp_Tran_ID=@Emp_Tran_ID	
				
			END
				
	
			
	RETURN
