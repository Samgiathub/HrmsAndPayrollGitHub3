





CREATE VIEW [dbo].[MyView]
 as
 Select Rec_End_date,
         Case 
		 When (Rec_End_date <= getdate())
             Then 'Expired'
           Else 'Active'
         End as end_date
   From  T0052_HRMS_Posted_REcruitment WITH (NOLOCK)




