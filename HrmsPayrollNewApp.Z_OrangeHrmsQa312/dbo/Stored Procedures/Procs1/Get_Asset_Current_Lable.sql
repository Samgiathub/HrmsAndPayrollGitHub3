







--Created By Girish On 07-AUG-2009
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE  PROCEDURE [dbo].[Get_Asset_Current_Lable]
	@Cmp_ID as numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Emp_code as numeric
	Declare @Row_id as numeric
	Declare @Asset_Name as varchar(100)
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (1,'Code')
	
	INSERT INTO #Temp_report_Label
						  (Row_ID, Label_Name)
	VALUES     (2,'Employee Name')
	set @Row_id = 3
	
	Declare @Sorting_No as numeric
	declare Cur_Asset   cursor for
	  	select Asset_Name  from t0040_asset_master WITH (NOLOCK) where cmp_id=@Cmp_ID
	open Cur_Asset
	fetch next from Cur_Asset  into @Asset_Name
	while @@fetch_status = 0
		begin
			INSERT INTO #Temp_report_Label
								  (Row_ID, Label_Name)
			VALUES     (@row_ID,@Asset_Name)
			set @row_ID = @row_ID + 1
			fetch next from Cur_Asset  into @Asset_Name
		end
	close Cur_Asset
	deallocate Cur_Asset
	
	
	
	RETURN
	
































