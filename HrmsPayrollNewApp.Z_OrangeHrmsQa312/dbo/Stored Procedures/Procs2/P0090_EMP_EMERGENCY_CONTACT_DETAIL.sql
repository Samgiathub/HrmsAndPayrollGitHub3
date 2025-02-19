



---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0090_EMP_EMERGENCY_CONTACT_DETAIL]
	 @Row_ID numeric(18,0) output
	,@Emp_ID numeric(18,0)
    ,@Cmp_ID numeric(18,0)
    ,@Name varchar(100)
    ,@RelationShip varchar(20)
    ,@Home_Tel_No varchar(30)
    ,@Home_Mobile_No varchar(30)
    ,@Work_Tel_No varchar(30)    
    ,@tran_type char(1)
    ,@Login_Id numeric(18,0)=0 --Rathod 18/04/2012
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @tran_type  = 'I'
		Begin
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0090_EMP_EMERGENCY_CONTACT_DETAIL WITH (NOLOCK)
				
				INSERT INTO T0090_EMP_EMERGENCY_CONTACT_DETAIL
				                      (Emp_ID, Row_ID, Cmp_ID, RelationShip, Name, Home_Tel_No, Home_Mobile_No, Work_Tel_No)
				VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@RelationShip,@Name,@Home_Tel_No,@Home_Mobile_No,@Work_Tel_No)
				
				INSERT INTO T0090_EMP_EMERGENCY_CONTACT_DETAIL_Clone
				                      (Emp_ID, Row_ID, Cmp_ID, RelationShip, Name, Home_Tel_No, Home_Mobile_No, Work_Tel_No,System_Date,Login_Id)
				VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@RelationShip,@Name,@Home_Tel_No,@Home_Mobile_No,@Work_Tel_No,GETDATE(),@Login_Id)
					
								
		End
	Else if @Tran_Type = 'U'
		begin
				
		UPDATE    T0090_EMP_EMERGENCY_CONTACT_DETAIL
		SET              Cmp_ID = @Cmp_ID, Name = @Name, RelationShip = @RelationShip, Home_Tel_No = @Home_Tel_No, Home_Mobile_No = @Home_Mobile_No, 
		                      Work_Tel_No = @Work_Tel_No 
		                      where 
		                      Emp_ID = @Emp_ID and Row_ID = @Row_ID
		                      
		      INSERT INTO T0090_EMP_EMERGENCY_CONTACT_DETAIL_Clone
				            (Emp_ID, Row_ID, Cmp_ID, RelationShip, Name, Home_Tel_No, Home_Mobile_No, Work_Tel_No,System_Date,Login_Id)
				VALUES     (@Emp_ID,@Row_ID,@Cmp_ID,@RelationShip,@Name,@Home_Tel_No,@Home_Mobile_No,@Work_Tel_No,GETDATE(),@Login_Id)
		            
		                      
		   end
	Else if @Tran_Type = 'D'
		begin
			
			DELETE FROM T0090_EMP_EMERGENCY_CONTACT_DETAIL
			WHERE     (Row_ID = @Row_ID)
		end

	RETURN




