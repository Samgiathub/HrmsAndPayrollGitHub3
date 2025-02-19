



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Get_Applicant]
	@Cmp_id as numeric(18,0)
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	 
	select qry1.resume_id,qry1.Status,qry2.App_Full_NAme from V0055_Resume_View as Qry2 inner join
(  select  IS1.*  from T0055_HRMS_Interview_Schedule IS1 WITH (NOLOCK) inner join   
     (select max(Process_dis_no) as For_Date,Resume_ID from T0055_HRMS_Interview_Schedule WITH (NOLOCK) 
   	  where Cmp_ID = @cmp_id group by Resume_ID) Qry on  
     IS1.Resume_ID = Qry.Resume_ID   
   Where Cmp_ID = @cmp_id and  IS1.Process_dis_no = Qry.For_Date) as qry1

on qry1.Resume_Id = qry2.Resume_Id order by qry1.resume_id
   
	RETURN




