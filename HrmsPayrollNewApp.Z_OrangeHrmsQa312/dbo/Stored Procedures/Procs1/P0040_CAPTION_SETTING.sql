

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_CAPTION_SETTING]
	@Cmp_ID Numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	--/*
    -- Insert statements for procedure here
	--; with Setting_List as ( SELECT ROW_NUMBER() OVER(PARTITION BY Group_BY ORDER BY Group_BY,Caption) As RowID, * 
	--FROM T0040_CAPTION_SETTING  WHERE Cmp_Id = @Cmp_ID and Is_Hidden = 0)--Added by Mukti(02012018)Is_Hidden=0
	 
	--select case when rowID = 1 then Group_BY else '' end as Group_BY,Tran_Id,SL.Cmp_ID,Caption,Alias,SortingNo,Remarks,SL.Module_Name,
	--(Case When rowID = 1 Then 'True' Else 'False' End) As IsGroup
	--from Setting_List SL
	--Inner Join (
	--		Select isnull(module_status,0) as module_status,Cmp_id From T0011_module_detail Where Cmp_id = @Cmp_ID And Module_Name = 'HRMS'
	--	) as Qry
	--	ON SL.Cmp_Id = Qry.Cmp_id
	--where SL.Cmp_ID = @Cmp_ID and Module_Name <> (Case When module_status = 1 then '' else 'HRMS' End) 
	--*/
	
	/* NOW AS WE ARE WORKING ON MULTIPLE MODULE , THIS QUERY IS CHANGED BY RAMIZ (23/04/2018). */

	; WITH Setting_List AS 
		(	SELECT ROW_NUMBER() OVER(PARTITION BY Group_BY ORDER BY Group_BY,Caption) As RowID, * 
			FROM T0040_CAPTION_SETTING  WITH (NOLOCK)
			WHERE Cmp_Id = @Cmp_ID and Is_Hidden = 0	--Added by Mukti(02012018)Is_Hidden=0
		 )
	SELECT	CASE WHEN rowID = 1 THEN Group_BY ELSE '' END AS Group_BY,Tran_Id,SL.Cmp_ID,Caption,Alias,SortingNo,Remarks,SL.Module_Name,
			CASE WHEN rowID = 1 THEN 'True' ELSE 'False' END As IsGroup
	FROM Setting_List SL
	WHERE SL.Cmp_ID = @Cmp_ID  AND
		EXISTS(
				SELECT 1 FROM T0011_module_detail T  WITH (NOLOCK)
				WHERE Cmp_id = @Cmp_ID and module_status = 1 And SL.Module_Name=T.module_name
			   )
	
END

