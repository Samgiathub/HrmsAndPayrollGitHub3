
Create PROCEDURE [dbo].[P9999_Bank_Transfer_Export_Old12152020]
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Emp_Full_Name nvarchar(500),
	@Month varchar(10),
	@Year numeric(18,0),	
	@File_Name nvarchar(30),
	@Regerate_Flag nvarchar(30),
	@Reason nvarchar(max) = '',
	@Modified_By numeric(18,0),
	@Modified_Date datetime = null
	
AS
BEGIN	
	SET NOCOUNT ON;
	if @Regerate_Flag = 'I'
	begin
		if Not exists(select 1 from T9999_Bank_Transfer_Export where Cmp_Id=@Cmp_ID and Emp_id=@Emp_Id and [Month]=@Month and [Year]=@Year and Regerate_Flag = 'I')
		Begin
				Insert into T9999_Bank_Transfer_Export
				(Cmp_ID,Emp_ID,Emp_Full_Name,[Month],[Year],[Generate_Date],[File_Name],Regerate_Flag,Reason,Modified_By,Modified_Date)
				values(@Cmp_ID,@Emp_ID,@Emp_Full_Name,@Month,@Year,GETDATE(),@File_Name,@Regerate_Flag,@Reason,@Modified_By,GETDATE())
		END
	END

	If @Regerate_Flag ='D' and @Emp_ID = 0
	BEGIN
		update T9999_Bank_Transfer_Export set Regerate_Flag = @Regerate_Flag,Reason = @Reason, Modified_By = @Modified_By,Modified_Date=GETDATE() 
		where [Month]=@Month and [Year]=@Year and [File_Name]=@File_Name
	END

	If @Regerate_Flag ='D' and @Emp_ID <> 0
	BEGIN
		update T9999_Bank_Transfer_Export set Regerate_Flag = @Regerate_Flag,Reason = @Reason,Modified_By = @Modified_By,Modified_Date=GETDATE() 
		where [Month]=@Month and [Year]=@Year and Emp_ID = @Emp_ID
	END
END
