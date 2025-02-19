

-- Created By rohit For Do the Entry for Customized Column in the Employee master on 29102014.
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0080_Emp_Column_Update]
	@Cmp_ID	numeric(18,0)
   ,@Alpha_Emp_Code	varchar(50)	
   ,@Column_Name nvarchar(max)
   ,@Column_Value nvarchar(Max)
   ,@tran_type varchar(1)
 AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	begin
	
	Declare @Emp_id numeric
	declare @emp_Id_sup numeric
	declare @qry varchar(1000)
	Declare @Inc_id numeric
	Declare @Inc_Eff_date datetime
	
	set @Inc_id = 0
	set @qry = ''
	set @Inc_Eff_date = NULL
	
	if @tran_type = 'U'
	begin
		Set @Emp_ID = cast(@Alpha_Emp_Code as numeric(18,0))
	end
	else 
	begin
		If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and Alpha_Emp_Code = @Alpha_Emp_Code)
		Begin
			
			Select @Emp_Id=Emp_Id,@Inc_id = Increment_ID From Dbo.T0080_Emp_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and  Alpha_Emp_Code = @Alpha_Emp_Code 
						
			If Exists(select Emp_ID From dbo.T0080_EMP_MASTER WITH (NOLOCK) WHERE Cmp_ID= @Cmp_ID and  Alpha_Emp_Code = @Alpha_Emp_Code and Emp_ID <> @Emp_ID)
				Begin
					Set @Emp_ID = 0
					Return  
				End
		end
	
	end
	
	If @Column_Name <> ''
				begin					
					set @qry = 'Update dbo.T0080_Emp_Column			
						Set	' + @Column_Name + ' = ''' + @Column_Value + ''' Where Emp_Id = ' +  CAST(@Emp_Id AS NVARCHAR) + ' And Cmp_Id = ' + CAST(@Cmp_ID AS NVARCHAR)
						
				end			
			
			exec (@qry)	
				
						   
	
	RETURN
	end	




