



---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0090_Hrms_Appraisal_Status_Report]
@Cmp_ID numeric(18,0),
@appr_int_id numeric(18,0),
@branch_id numeric(18,0)
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

    

Declare @Count_Arraisal table
(
	appr_int_id numeric(18,0),
	Initiated numeric(22,0),
	S_To_team numeric(22,0),
	S_By_team numeric(22,0),
	S_To_Supr numeric(22,0),
	S_By_Supr numeric(22,0),
	S_To_Emp numeric(22,0),
	S_By_Emp numeric(22,0),
	Rejected numeric(22,0),
	Accepted numeric(22,0),
	Pending numeric(22,0),
	For_Date  Varchar(15),
	Initiated_name Varchar(50)
	--End_Date Varchar(15)
)
Declare @Initiated     numeric(22,0)
Declare @Is_team_To_Submit numeric(22,0)
Declare @Is_team_submit numeric(22,0)
Declare @Is_Sup_To_Submit numeric(22,0)
Declare @Is_Sup_submit numeric(22,0)
Declare @Is_Emp_To_Submit numeric(22,0)
Declare @Is_Emp_Submit numeric(22,0)
Declare @Is_Accept     numeric(22,0)
Declare @Is_Rejected   numeric(22,0)
Declare @Is_Pending    numeric(22,0)
Declare @For_Date	   Varchar(15)
Declare @Initiated_name    Varchar(50)
--Declare @End_Date      Varchar(15)

--for branch login

if @branch_id = 0 
 SET @branch_id = NULL


Select  @For_Date = Convert(varchar(15),For_Date,106) From dbo.T0090_Hrms_Appraisal_Initiation WITH (NOLOCK) Where Appr_Int_Id=@appr_int_id

Select  @Initiated_name = login_name From dbo.V0090_Hrms_Appraisal_Initiation Where Appr_Int_Id=@appr_int_id

insert into @Count_Arraisal(appr_int_id,Initiated,S_To_Supr,S_By_Supr,S_To_Emp,S_By_Emp,Rejected,Accepted,Pending,For_Date,Initiated_name)
values(@appr_int_id,0,0,0,0,0,0,0,0,@For_Date,@Initiated_name)

select @Initiated=count(HAIID.Appr_Int_Id) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set Initiated = @Initiated

--team

select @Is_team_To_submit=count(HAII.invoke_team) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID) and HAIID.Is_team_Submit=2 --and HAII.invoke_team = 2

update @Count_Arraisal set S_To_team = @Is_team_To_Submit

select @Is_team_submit=count(HAIID.Is_team_submit) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_team_submit = 1 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set S_By_team = @Is_team_submit

select @Is_Sup_To_submit=count(HAII.invoke_superior) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)and HAIID.Is_Sup_Submit=2--and HAII.invoke_superior = 2 

update @Count_Arraisal set S_To_Supr = @Is_Sup_To_Submit

select @Is_Sup_submit=count(HAIID.Is_Sup_submit) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_Sup_submit = 1 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set S_By_Supr = @Is_Sup_submit

---Employee Invoke

select @Is_Emp_To_Submit=count(HAII.invoke_emp) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID) and HAIID.Is_Emp_Submit=2 --and HAII.invoke_emp=2

update @Count_Arraisal set S_To_Emp = @Is_Emp_To_Submit

---Employee Submitted

select @Is_Emp_Submit=count(HAIID.Is_Emp_Submit) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_Emp_Submit=1 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set S_By_Emp = @Is_Emp_Submit

--Accepted

select @Is_Accept=count(HAIID.Is_Accept) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_Accept = 1 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set Accepted = @Is_Accept

--Rejected

select @Is_Rejected=count(HAIID.Is_Accept) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_Accept = 0 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set Rejected = @Is_Rejected

--Pending

select @Is_Pending=count(HAIID.Is_Accept) from dbo.T0090_Hrms_Appraisal_Initiation HAII WITH (NOLOCK) inner join 
dbo.V0090_hrms_Appraisal HAIID  on HAII.appr_int_id=HAIID.appr_int_id 
where  HAII.appr_int_id = @appr_int_id and HAIID.Is_Accept = 2 AND HAIID.BRANCH_ID=ISNULL(@BRANCH_ID,HAIID.BRANCH_ID)

update @Count_Arraisal set Pending = @Is_Pending


select * from @Count_Arraisal

RETURN




