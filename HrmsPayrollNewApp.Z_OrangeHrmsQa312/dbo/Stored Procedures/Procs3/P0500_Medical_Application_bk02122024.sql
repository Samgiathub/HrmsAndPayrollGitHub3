
create PROCEDURE [dbo].[P0500_Medical_Application_bk02122024]
@App_Id numeric(18,0) OUTPUT, 
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
@Desc_Details varchar(500),
@Dependent_Details varchar(100),
@Emp_Id numeric(18,0),
@Other_Note varchar(500),
@TransId Char = '',
@Createdby numeric(18,0) = 0,
@Hospital_Contact VARCHAR(50) = '',
@Hospital_Emailid VARCHAR(100) = ''


AS
Begin

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If @TransId = 'I'
		Begin 
					IF Exists(Select App_id  from T0500_Medical_Application WITH (NOLOCK) Where App_id = @App_Id)  
					Begin  
						set @App_Id = 0  
					Return   
					End  
				
					select @App_Id = isnull(max(App_ID),0) + 1  from T0500_Medical_Application WITH (NOLOCK)
					
					INSERT INTO T0500_Medical_Application 
					(App_For,App_Date,Emp_Name,Hospital_Name,State_Id,City,Incident_Id
					,Incident_Place,Hospital_Address,Date_of_Incident,Time_of_Incident,Contact_no,
					Desc_Details,Dependent_Details,Other_Note,Cmp_id,emp_id,Created_by,Contact_no2,Email)
					VALUES(@App_For,@App_Date,@Emp_Name,@Hospital_Name,@State_Id,@City,@Incident_Id
					,@Incident_Place,@Hospital_Address,@Date_Of_Incident,@Time_of_Incident,@Contact_no
					,@Desc_Details,@Dependent_Details,@Other_Note,@Cmp_Id,@Emp_Id,@Createdby,@Hospital_Contact,@Hospital_Emailid)
					
		end 

	Else if @TransId = 'U'   
		begin
			
					IF not Exists(Select App_id  from T0500_Medical_Application WITH (NOLOCK) Where App_id = @App_Id)  
					Begin  
						set @App_Id = 0  
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
					Desc_Details = @Desc_Details,
					Dependent_Details = @Dependent_Details,
					Other_Note = @Other_Note,
					Cmp_id = @Cmp_Id,
					Emp_id = @Emp_Id,
					Created_by = @Createdby,
					Contact_no2 = @Hospital_Contact,
					Email = @Hospital_Emailid
					WHERE     App_Id = @App_Id

		end	

	Else if @TransId = 'D'  
		Begin
		
			select ISNULL(Incident_Id,0)  From dbo.T0500_Medical_Application WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and App_ID = @App_ID		
		
			DELETE FROM T0500_Medical_Application 	WHERE  App_ID = @App_ID
			
		end

	RETURN	

	End