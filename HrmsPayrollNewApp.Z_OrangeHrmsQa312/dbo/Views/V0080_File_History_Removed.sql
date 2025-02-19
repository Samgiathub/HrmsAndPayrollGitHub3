

create View [dbo].[V0080_File_History_Removed]
As

	select distinct fh.FH_Id,fh.File_App_Id,fh.Emp_Id,fh.File_Apr_Id,
	(CASE
    WHEN fh.H_Trans_Type='I' THEN 'Inserted'
    WHEN fh.H_Trans_Type='U' THEN 'Updated'
    ELSE 'Deleted' END)as Trans_Type,
	fh.H_File_Number as File_Number

			from T0115_File_Level_Approval_History FH where H_Trans_Type='D'
			


