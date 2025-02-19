
CREATE View [dbo].[V0080_Griev_App_Admin_Side_2]
as
select GA_ID,isnull(App_No,'GA'+cast(GA_ID as nvarchar)) as App_No,Receive_Date,[From],isnull(Emp_IDF,0) as Emp_IDF,isnull(NameF,'') as NameF,
isnull(AddressF,'') as AddressF,isnull(EmailF,'') as EmailF,isnull(ContactF,'') as ContactF,
Receive_From,Griev_Against,isnull(Emp_IDT,0) as Emp_IDT , isnull(NameT,'') as NameT,
isnull(AddressT,'') as AddressT,isnull(EmailT,'') as EmailT,isnull(ContactT,'') as ContactT,
SubjectLine,Details,DocumentName,Cmp_ID
from T0080_Griev_Application
