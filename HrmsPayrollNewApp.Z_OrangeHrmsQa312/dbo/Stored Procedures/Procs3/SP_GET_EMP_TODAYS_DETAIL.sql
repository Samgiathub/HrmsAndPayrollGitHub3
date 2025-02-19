

---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[SP_GET_EMP_TODAYS_DETAIL]
 @EMP_ID NUMERIC(18,0)	
,@STATUS CHAR(2) 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

IF @STATUS = 'OD'
	BEGIN
		select la.Emp_ID,em.Emp_COde,em.Emp_Full_Name,TLM.lEAVE_NAME,lad.*,l.*,isnull(e.emp_full_name,login_name) as Approver from t0120_leave_approval as la WITH (NOLOCK) 
		inner join t0080_emp_master as em WITH (NOLOCK) on la.emp_id=em.emp_ID INNER JOIN t0130_leave_approval_detail as lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID
		inner join t0011_login L WITH (NOLOCK) on lad.login_ID=l.login_ID left outer join t0080_emp_master e WITH (NOLOCK) on l.Emp_id=e.emp_id	 where   
		left(lad.from_Date,10) < = left(getdate(),10) and left(lad.To_Date,10) >= left(getdate(),10) and la.approval_status='A' And Leave_TYpe = 'Company Purpose' AND LA.EMP_ID=@EMP_ID 
	END
ELSE IF @STATUS='L'		
	BEGIN
		select la.Emp_ID,em.Emp_COde,em.Emp_Full_Name,TLM.lEAVE_NAME,lad.*,l.*,isnull(e.emp_full_name,login_name) as Approver  from t0120_leave_approval as la  WITH (NOLOCK) 
		inner join t0080_emp_master as em WITH (NOLOCK) on la.emp_id=em.emp_ID INNER JOIN t0130_leave_approval_detail as lad WITH (NOLOCK) on la.leave_approval_ID=lad.leave_approval_ID Inner join t0040_leave_master TLM WITH (NOLOCK) on lad.Leave_ID=TLM.Leave_ID
		inner join t0011_login L WITH (NOLOCK) on lad.login_ID=l.login_ID	 left outer join t0080_emp_master e WITH (NOLOCK) on l.Emp_id=e.emp_id	 where    
		left(lad.from_Date,10) < = left(getdate(),10) and left(lad.To_Date,10) >= left(getdate(),10) and la.approval_status='A' And Leave_TYpe <> 'Company Purpose' AND LA.EMP_ID=@EMP_ID    
	END
ELSE IF @STATUS='P'	 
	BEGIN
		select EIO.Emp_ID,em.Emp_COde,em.Emp_Full_Name,EIO.* from t0150_EMP_INOUT_RECORD as EIO WITH (NOLOCK) 
		inner join t0080_emp_master as em WITH (NOLOCK) on EIO.emp_id=em.emp_ID WHERE EIO.EMP_ID=@EMP_ID AND
		month(EIO.in_time)   = month(getdate()) and Year(EIO.in_time) = year(getdate()) and day(EIO.in_time) = day(getdate())
	END
RETURN




