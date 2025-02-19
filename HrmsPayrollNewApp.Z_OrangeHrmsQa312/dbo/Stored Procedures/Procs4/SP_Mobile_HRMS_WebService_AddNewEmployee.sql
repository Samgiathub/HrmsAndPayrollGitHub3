
CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_AddNewEmployee]
	
	@Emp_id numeric(18,0),
	@cmp_id numeric(18,0),
	@Emp_Fullname varchar(200),
	@Salary float ,
	@Age int,
	@Designation varchar(200),
	@Department varchar(200),
	
	
	@tran_type varchar(1)
	 
	--@Result VARCHAR(100) OUTPUT
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	 
	
	If UPPER(@tran_type) = 'I'
		BEGIN
			
			
		
		BEGIN TRY	
		
			Insert into Table_Employee_Sample(
				
				Emp_id,
				Cmp_id,
				Emp_FullName ,Salary,Age,Designation,Department
				
				
			)
			values(
				@Emp_id,
				@Cmp_id,
				@Emp_FullName ,@Salary,@Age,@Designation,@Department
				
			)
			select * from Table_Employee_Sample where Cmp_Id=@cmp_id and Emp_id=@Emp_id
			SELECT 'New Employee Added Successfully#True#'
			
			END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
			
				

			--SET @Result = 'Add New Employee Done#True#'+CAST(@emp_id AS varchar(11))

			--SELECT @Result
		
		end
		If UPPER(@tran_type) = 'U'
		BEGIN
			
			
		
		BEGIN TRY	
		
			update Table_Employee_Sample
				
			set	
				Emp_FullName =@Emp_FullName ,Salary=@Salary,Age=@Age,Designation=@Designation,Department=@Department
				
				
			where Emp_id=@Emp_id and
				Cmp_id=@Cmp_id
				
			
			select * from Table_Employee_Sample where Cmp_Id=@cmp_id and Emp_id=@Emp_id
			SELECT ' Employee Update Successfully#True#'
			
			END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
			
				

			--SET @Result = 'Add New Employee Done#True#'+CAST(@emp_id AS varchar(11))

			--SELECT @Result
		
		end
		If UPPER(@tran_type) = 'D'
		BEGIN
			
			
		
		BEGIN TRY	
		IF   EXISTS(SELECT Emp_Id  from Table_Employee_Sample WITH (NOLOCK)  Where Emp_Id = @Emp_Id and Cmp_id=@cmp_id )
						BEGIN
							
						
			delete Table_Employee_Sample where Emp_id=@Emp_id and Cmp_id=@Cmp_id
						
			
			
			SELECT ' Employee Delete Successfully#True#'
			end
			END TRY
		BEGIN CATCH
			SELECT ERROR_MESSAGE()+'#False#'
		END CATCH
			
				

			--SET @Result = 'Add New Employee Done#True#'+CAST(@emp_id AS varchar(11))

			--SELECT @Result
		
		end
