
create View [dbo].[V0080_File_App_Admin_Side_Approve]
As

select * from V0080_File_App_Admin_Side va
where File_App_Id  in(select File_App_Id from T0080_File_Approval) 


