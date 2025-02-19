CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Medical]  
@App_Id Numeric,
@App_For int,
@Cmp_Id numeric(18,0),
@App_Date Datetime,
@Emp_Name varchar(50),
@Hospital_Name Varchar(100),
@State_Id numeric(18,0),
@City varchar(50),
@Incident_Id numeric(18,0),
@Incident_Place varchar(100),
@Hospital_Address varchar(200),
@Date_Of_Incident datetime,
@Time_of_Incident varchar(50),
@Contact_no varchar(50),
@Contact_no2 varchar(50),
@EmailId varchar(100),
@Desc_Details varchar(500),
@Dependent_Details varchar(100),
@Emp_Id numeric(18,0),
@Other_Note varchar(500),
@TransId Char = '',	
@CreatedBy numeric(18,0) = '',	
@Result varchar(250) OUTPUT
AS    
BEGIN

SET NOCOUNT ON		
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

If @TransId = 'I'
			Begin 
				
			IF Exists(Select App_id from T0500_Medical_Application WITH (NOLOCK) Where App_id = @App_Id)  
			Begin  
				set @App_Id = 0  
				SET @Result = 'Record Already Exist#False#'
			Return   
			End  
			
			select @App_Id = isnull(max(App_ID),0) + 1  from T0500_Medical_Application WITH (NOLOCK)
			
			INSERT INTO T0500_Medical_Application 
			(App_For,App_Date,Emp_Name,Hospital_Name,State_Id,City,Incident_Id
			,Incident_Place,Hospital_Address,Date_of_Incident,Time_of_Incident,Contact_no,
			Desc_Details,Dependent_Details,Other_Note,Cmp_id,emp_id,Contact_no2,Email,Created_by)
			VALUES(@App_For,@App_Date,@Emp_Name,@Hospital_Name,@State_Id,@City,@Incident_Id
			,@Incident_Place,@Hospital_Address,@Date_Of_Incident,@Time_of_Incident,@Contact_no
			,@Desc_Details,@Dependent_Details,@Other_Note,@Cmp_Id,@Emp_Id,@Contact_no2,@EmailId,@CreatedBy)
			
			if @App_Id > 0
			Begin 
				SET @Result = 'Submitted Successfully#True#'
				select @Result as Result
			END
			ELse
			Begin
				SET @Result = 'Record Not Inserted Successfully#False#'
				select @Result as Result
			END
			RETURN 
			END
	Else if @TransId = 'U'   
		begin
					IF not Exists(Select App_id  from T0500_Medical_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and App_ID = @App_ID)   
					Begin  
						set @App_Id = 0  
						SET @Result = 'Record Not Found#False#'
						select @Result as Result
					Return   
					End  
					
					UPDATE    T0500_Medical_Application SET 
					Incident_Id = @Incident_Id,
					App_For = @App_For,
					App_Date = @App_Date,
					Emp_Name = @Emp_Name,
					Hospital_Name = @Hospital_Name,
					State_Id = @State_Id,
					City = @City,
					Incident_Place = @Incident_Place,
					Hospital_Address = @Hospital_Address,
					Date_of_Incident = @Date_Of_Incident,
					Time_of_Incident = @Time_of_Incident,
					Contact_no = @Contact_no,
					Contact_no2 = @Contact_no2,
					Desc_Details = @Desc_Details,
					Dependent_Details = @Dependent_Details,
					Other_Note = @Other_Note,
					Cmp_id = @Cmp_Id,
					Emp_id = @Emp_Id,
					Email = @EmailId,
					Created_by = @CreatedBy
					WHERE  App_ID = @App_ID and Created_by = @CreatedBy and Cmp_Id = @Cmp_Id

				
					SET @Result = 'Updated Successfully#True#'
					select @Result as Result
					Return

		end	

	Else if @TransId = 'D'  
		Begin
		
			--select ISNULL(Incident_Id,0)  From dbo.T0500_Medical_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and App_ID = @App_ID		
					
				IF not Exists(Select App_id  from T0500_Medical_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and App_ID = @App_ID)  
					Begin  
						set @App_Id = 0  
						SET @Result = 'Record Not Found#False#'
					Return   
					End  
		
			DELETE FROM T0500_Medical_Application WHERE App_ID = @App_ID and Created_by = @CreatedBy and Cmp_Id = @Cmp_Id
			
			SET @Result = 'Deleted Successfully#True#'
			select @Result as Result
			Return
		end

		
End
