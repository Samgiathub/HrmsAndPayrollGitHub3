
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P9999_Bank_Transfer_Export]
	@Cmp_ID numeric(18,0),
	@Emp_ID  nvarchar(500),
	@Emp_Full_Name nvarchar(500),
	@Month varchar(10),
	@Year numeric(18,0),	
	@File_Name nvarchar(30),
	@Regerate_Flag nvarchar(30),
	@Reason nvarchar(max) = '',
	@Modified_By numeric(18,0),
	@Modified_Date datetime = null,
	@Flag Char(1) = ''
	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	print @Regerate_Flag 
	if @Regerate_Flag = 'I'
	begin
		if Not exists(select 1 from T9999_Bank_Transfer_Export WITH (NOLOCK) where Cmp_Id=@Cmp_ID and Emp_id = @Emp_Id and [Month]=@Month and [Year]=@Year and Regerate_Flag = 'I')
		Begin
				Insert into T9999_Bank_Transfer_Export
				(Cmp_ID,Emp_ID,Emp_Full_Name,[Month],[Year],[Generate_Date],[File_Name],Regerate_Flag,Reason,Modified_By,Modified_Date,Flag)
				values(@Cmp_ID,@Emp_ID,@Emp_Full_Name,@Month,@Year,GETDATE(),@File_Name,@Regerate_Flag,@Reason,@Modified_By,GETDATE(),@Flag)
		END
	END
	
	If @Regerate_Flag ='D' and @Emp_ID = '0'
	BEGIN
		update T9999_Bank_Transfer_Export set Regerate_Flag = @Regerate_Flag,Reason = @Reason, Modified_By = @Modified_By,Modified_Date=GETDATE() 
		where [Month]=@Month and [Year]=@Year and [File_Name]=@File_Name 
		and Regerate_Flag = 'I' -- Add by Deepal 12/23/2020
	END
	--print @Emp_ID
	If @Regerate_Flag ='D' and @Emp_ID <> '0'
	BEGIN
		--update T9999_Bank_Transfer_Export set Regerate_Flag = @Regerate_Flag,Reason = @Reason,Modified_By = @Modified_By,Modified_Date=GETDATE() 
		--where [Month]=@Month and [Year]=@Year and Emp_ID in (select Data from Split(@Emp_ID,',') where Data <> '')
		update w set Regerate_Flag = @Regerate_Flag,Reason = @Reason,Modified_By = @Modified_By,Modified_Date=GETDATE()
		from T9999_Bank_Transfer_Export w inner join Split(@Emp_ID,',') on Emp_ID = convert(numeric,Data)
		where Data <> '' and [Month]=@Month and [Year]=@Year 
		and Regerate_Flag = 'I' -- Add by Deepal 12/23/2020
	END
END
