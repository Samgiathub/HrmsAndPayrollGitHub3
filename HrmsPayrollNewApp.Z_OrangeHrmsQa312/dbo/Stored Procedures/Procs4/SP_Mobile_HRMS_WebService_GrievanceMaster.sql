CREATE Procedure [dbo].[SP_Mobile_HRMS_WebService_GrievanceMaster]
(
@Emp_ID as int=0,
@Cmp_ID as int=0,
@Type as varchar(10)='',
@Result as varchar(20)='' output
)
As
Begin



If @Type='AN'
Begin
 
select 'GA'+Cast((max(GA_ID)+1) as nvarchar) as AppNo from T0080_Griev_Application

select 'Successfully#True' as Msg

End

Else If @Type='CMT'
Begin
 select GC_ID,Com_Name from T0040_Griev_Committee_Master where Cmp_id=@Cmp_ID and NodelHR_id = @Emp_ID          
End

Else IF @Type='GTP'
Begin
  select GrievanceTypeID,GrievanceTypeTitle from T0040_Grievance_Type_Master where Is_Active=1 and Cmp_ID=@Cmp_ID
End

else if @Type='Cat'
Begin
select G_CategoryID,CategoryTitle from T0040_Griev_Category_Master where Is_Active=1 and Cmp_ID=@Cmp_ID
End

else if @Type='PRT'
Begin
 select G_PriorityID,PriorityTitle from T0040_Griev_Priority_Master where Is_Active=1 and Cmp_ID=@Cmp_ID
End

else if @Type ='STT'
Begin
 select S_ID,S_Name from T0030_Griev_Status_Common where S_PageFlag like '%GA%' 
End

else if @Type ='GAP'
Begin


		select GA_ID,App_No,ReceiveDate,[From],Name_From,R_From,Griev_Against,Name_Against,SubjectLine,DocumentName,ApplicationStatus
		
		from V0080_Griev_App_Admin_Side where Cmp_ID=@Cmp_ID and Emp_IDF=@Emp_ID

End

else if @Type ='GAAL'
Begin

if exists (select NodelHR_id from T0040_Griev_Committee_Master where NodelHR_id= @Emp_ID  group by NodelHR_id)
Begin

Declare @BRID as nvarchar(1000)

select 
@BRID=COALESCE(@BRID + ',' + cast(Branch_ID as nvarchar(1000)),cast(Branch_ID as nvarchar(1000)))
from T0040_Griev_Committee_Master where NodelHR_id=@Emp_ID and Branch_ID !=''


select * from V0080_Griev_App_Admin_Side where Cmp_ID=@Cmp_ID and ApplicationStatus = 'Pending' and Emp_IDT <> @Emp_ID
and B_ID in (Select Cast(Data As Numeric) As ID FROM dbo.Split(@BRID,',') T Where T.Data <> '') 

End
else
Begin

select * from V0080_Griev_App_Admin_Side where Cmp_ID=@Cmp_ID and ApplicationStatus='None'

End






End

else
Begin

select App_No from T0080_Griev_Application where Cmp_ID=@Cmp_ID and App_No=@Type

if Exists(select App_No from T0080_Griev_Application where Cmp_ID=@Cmp_ID and App_No=@Type)
Begin

 select 'App No is already exists#False'
 
End
else
Begin
 select 'Successfully#True'
End




end



End