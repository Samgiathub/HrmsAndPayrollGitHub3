
-- =============================================
-- Author:		Nilesh Patel
-- Create date: 01-04-2019
-- Description:	Mandatory Fields Details
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Setting_Mandatory_Fields_Bind]
	@Cmp_ID Numeric(18,0),
	@flag	varchar(15)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	IF @flag='Mandatory'
		BEGIN
			; with Setting_List as 
			(SELECT ROW_NUMBER() OVER(PARTITION BY Module_Name ORDER BY Module_Name) As RowID, * 
				FROM T0040_Setting_Mandatory_Fields WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID 
			)  
			select case when rowID = 1 then Module_Name else '' end as Group_By,
			Tran_ID,Cmp_ID,Replace(Fields_Name,'-',' ') as Fields_Name,(Case When rowID = 1 Then 'True' Else 'False' End) As IsGroup,Is_Mandatory,Module_Name,Fields_Name as Actual_Fields_Name
			from Setting_List where Cmp_ID = @Cmp_ID
		END
	ELSE
		BEGIN
			; with Setting_List as 
			(SELECT ROW_NUMBER() OVER(PARTITION BY Module_Name ORDER BY sorting_no) As RowID, * 
				FROM T0040_Setting_Display_Fields WITH (NOLOCK) WHERE Cmp_Id = @Cmp_ID 
			)  
			select case when rowID = 1 then Module_Name else '' end as Group_By,
			Tran_ID,Cmp_ID,Replace(Field_Name,'_',' ') as Fields_Name,(Case When rowID = 1 Then 'True' Else 'False' End) As IsGroup,Module_Name,Field_Name as Actual_Fields_Name,Control_Type,Is_Display,sorting_no
			from Setting_List where Cmp_ID = @Cmp_ID
			order by sorting_no
		END
	
END
