
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0065_EMP_EMERGENCY_CONTACT_DETAIL_APP]
	 @Row_ID int output
	,@Emp_Tran_ID bigint
	,@Emp_Application_ID int
    ,@Cmp_ID int
    ,@Name varchar(100)
    ,@RelationShip varchar(20)
    ,@Home_Tel_No varchar(30)
    ,@Home_Mobile_No varchar(30)
    ,@Work_Tel_No varchar(30)    
    ,@tran_type char(1)
    ,@Login_Id int=0 --Rathod 18/04/2012
    ,@Approved_Emp_ID int
	,@Approved_Date datetime = Null
	,@Rpt_Level int 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @tran_type  = 'I'
		Begin
				select @Row_ID = Isnull(max(Row_ID),0) + 1 	From T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP WITH (NOLOCK)
				
				INSERT INTO T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP
				                      (Row_ID,Emp_Tran_ID,Emp_Application_ID,Cmp_ID, RelationShip, Name, Home_Tel_No, Home_Mobile_No, Work_Tel_No,Approved_Emp_ID,Approved_Date,Rpt_Level)
				VALUES     (@Row_ID,@Emp_Tran_ID,@Emp_Application_ID,@Cmp_ID,@RelationShip,@Name,@Home_Tel_No,@Home_Mobile_No,@Work_Tel_No,@Approved_Emp_ID,@Approved_Date,@Rpt_Level)
				
				
					
		End
	Else if @Tran_Type = 'U'
		begin
				
		UPDATE    T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP
		SET              Cmp_ID = @Cmp_ID, Name = @Name, RelationShip = @RelationShip, Home_Tel_No = @Home_Tel_No, Home_Mobile_No = @Home_Mobile_No, 
		                      Work_Tel_No = @Work_Tel_No,Approved_Emp_ID=@Approved_Emp_ID,Approved_Date=@Approved_Date,Rpt_Level=@Rpt_Level 
		                      where Emp_Tran_ID=@Emp_Tran_ID and Emp_Application_ID=@Emp_Application_ID and Row_ID = @Row_ID
		                      
		      
		                      
		   end
	Else if @Tran_Type = 'D'
		begin
			
			DELETE FROM T0065_EMP_EMERGENCY_CONTACT_DETAIL_APP
			WHERE     (Row_ID = @Row_ID)
		end

	RETURN


