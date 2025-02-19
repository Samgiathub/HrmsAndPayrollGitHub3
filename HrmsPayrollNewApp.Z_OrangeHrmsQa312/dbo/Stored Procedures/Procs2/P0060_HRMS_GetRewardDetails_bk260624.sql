

---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---

CREATE PROCEDURE [dbo].[P0060_HRMS_GetRewardDetails_bk260624]
	 @empReward_id		numeric(18,0)
	,@cmp_id			numeric(18,0)
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
declare @employee_id varchar(500)
declare @col1 as numeric(18,0)
declare @col2 as numeric(18,0)

Select @employee_id=Employee_Id from v0060_HRMS_EmployeeReward where EmpReward_Id=@empReward_id
	
	create table #finaltbl
 (
	 Empreward_Id	numeric(18,0)
	,From_Date		datetime
	,To_date		datetime
	,emp_id			numeric(18,0)
	,EmpReward_rating int
	,RewardValues	varchar(500)
	,Award_name		varchar(500)
	,Emp_Full_name	varchar(100)
	,Alpha_Emp_Code	varchar(100)
	,emp_Img		varchar(100)
	,Gender			varchar(3)
	,Department		varchar(100)
	,Designation		varchar(100)
	,Branch			varchar(100)
	,dateofJoin		datetime
	,RewardAttachment varchar(500)--10 dec 2015 sneha
	,Emp_First_Name	varchar(100)
	,Emp_Last_Name	varchar(100)
	,Emp_Initial	varchar(50)
 )
 
 Declare cur  cursor
  for
 select data,@empReward_id from Split(@employee_id,'#' ) 
open cur
	fetch next from cur into @col1,@col2
		while @@FETCH_STATUS = 0
		begin
			insert into #finaltbl
			(Empreward_Id,emp_id,Emp_Full_name,Alpha_Emp_Code,emp_img,gender,Designation,Branch,Department,dateofJoin,Emp_First_Name,Emp_Last_Name,Emp_Initial)
			(select @col2,@col1,e.Emp_Full_Name,e.Alpha_Emp_Code,
			Case when  isnull(Image_Name,'') = '' then case when Gender = 'M' then 'Emp_default.png' else 'Emp_Default_Female.png' END else Image_Name END as Image_Name 
			,gender,Desig_Name,Branch_Name,Dept_Name,e.Date_Of_Join,e.Emp_First_Name,e.Emp_Last_Name,e.Initial from 
			T0080_EMP_MASTER e WITH (NOLOCK) left join t0095_INCREMENT i WITH (NOLOCK) on i.Emp_ID=e.emp_id left join T0040_DESIGNATION_MASTER dg WITH (NOLOCK)
			on dg.Desig_ID = i.Desig_Id left join T0030_BRANCH_MASTER br WITH (NOLOCK) on br.Branch_ID=i.Branch_ID left join T0040_DEPARTMENT_MASTER Dp WITH (NOLOCK)
			on dp.Dept_Id = i.Dept_ID
			where e.Emp_ID=@col1 and i.Increment_ID = (select MAX(Increment_ID) from t0095_INCREMENT WITH (NOLOCK) where Emp_ID=i.emp_id))
					
			UPDATE #finaltbl SET From_Date = i.From_Date, To_date = i.To_date ,EmpReward_rating=i.EmpReward_rating,RewardValues=i.RewardValues,Award_name=i.Award_name,RewardAttachment=i.Reward_Attachment
			FROM (SELECT From_Date, To_date,EmpReward_rating,RewardValues,Award_name,Reward_Attachment FROM  V0060_HRMS_EmployeeReward where EmpReward_Id=@col2 ) i 
			where #finaltbl.Empreward_Id = @col2
			--select  @col1
		fetch next from cur into @col1,@col2
		End
close cur
deallocate cur

select * from #finaltbl

drop table #finaltbl
END

