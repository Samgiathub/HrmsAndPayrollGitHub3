



---20/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_RPT_GET_APPLICANT_REC]
	
	 @Cmp_ID		numeric
	,@Rec_Post_Id	numeric
	,@From_Date		datetime
	,@To_Date		datetime
	,@Resume_Id		numeric
	,@Resume_Status	numeric
	,@Constraint 	varchar(5000) = ''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--------------------------------------
	-- Created By : Falak 0n 5-jun-2010 --
	--------------------------------------
	
	if @Resume_Id = 0 
		set @Resume_Id = null
		
		
	Declare @Emp_Cons Table
		(
			Emp_ID	numeric
		)
	
	if @Constraint <> ''
		begin
			Insert Into @Emp_Cons
			select  cast(data  as numeric) from dbo.Split (@Constraint,'#') 
		end
	else 
		begin
			Insert Into @Emp_Cons

			select R.Resume_Id from T0055_Resume_MAster R WITH (NOLOCK)					
			Where Cmp_ID = @Cmp_ID 
			and R.Resume_Posted_Date >= @From_Date and R.Resume_Posted_Date <= @To_Date 			
		end
	
		if @Resume_Status < 4
		begin
			if @Rec_Post_Id > 0
			begin
			
				select R.Resume_Id as Emp_Id,R.Resume_Id as Emp_Code,(R.Initial + ' ' + R.Emp_First_Name + ' ' + isnull(R.Emp_Second_Name,'') 
						+ ' ' + R.Emp_Last_Name) as Emp_Full_Name, R.Resume_Status, P.Job_Title, R.Total_EXP, R.Exp_CTC ,
						Case R.Resume_Status when 0 then 'New'
											when 1 then 'Approved'
											when 2 then 'Hold'
											when 3 then 'Reject'
											end as Resume_Status,
						C.Cmp_Name,C.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date
						from T0055_Resume_Master R WITH (NOLOCK) inner join T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on
						R.Rec_Post_Id = P.Rec_Post_Id inner join T0010_Company_Master C WITH (NOLOCK) on
						R.Cmp_Id = C.Cmp_Id
						WHERE R.Cmp_ID = @Cmp_Id and R.Resume_Status = @Resume_Status
						and R.Rec_Post_Id = @Rec_Post_Id And R.Resume_ID in 
							(select Emp_ID From @Emp_Cons)
			end
			else
			begin
				select R.Resume_Id as Emp_Id,R.Resume_Id as Emp_Code,(R.Initial + ' ' + R.Emp_First_Name + ' ' + isnull(R.Emp_Second_Name,'') 
						+ ' ' + R.Emp_Last_Name) as Emp_Full_Name, R.Resume_Status, P.Job_Title, R.Total_EXP, R.Exp_CTC ,
						Case R.Resume_Status when 0 then 'New'
											when 1 then 'Approved'
											when 2 then 'Hold'
											when 3 then 'Reject'
											end as Resume_Status,
						C.Cmp_Name,C.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date
						from T0055_Resume_Master R WITH (NOLOCK) inner join T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on
						R.Rec_Post_Id = P.Rec_Post_Id inner join T0010_Company_Master C WITH (NOLOCK) on
						R.Cmp_Id = C.Cmp_Id
						WHERE R.Cmp_ID = @Cmp_Id and R.Resume_Status = @Resume_Status And R.Resume_ID in 
							(select Emp_ID From @Emp_Cons)
			end
		end
		else
		begin
			if @Rec_Post_Id > 0
			begin
			
				select R.Resume_Id as Emp_Id,R.Resume_Id as Emp_Code,(R.Initial + ' ' + R.Emp_First_Name + ' ' + isnull(R.Emp_Second_Name,'') 
						+ ' ' + R.Emp_Last_Name) as Emp_Full_Name, R.Resume_Status, P.Job_Title, R.Total_EXP, R.Exp_CTC ,
						Case R.Resume_Status when 0 then 'New'
											when 1 then 'Approved'
											when 2 then 'Hold'
											when 3 then 'Reject'
											end as Resume_Status,
						C.Cmp_Name,C.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date
						from T0055_Resume_Master R WITH (NOLOCK) inner join T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on
						R.Rec_Post_Id = P.Rec_Post_Id inner join T0010_Company_Master C WITH (NOLOCK) on
						R.Cmp_Id = C.Cmp_Id
						WHERE R.Cmp_ID = @Cmp_Id and R.Rec_Post_Id = @Rec_Post_Id And R.Resume_ID in 
							(select Emp_ID From @Emp_Cons)
			end
			else
			begin
				select R.Resume_Id as Emp_Id,R.Resume_Id as Emp_Code,(R.Initial + ' ' + R.Emp_First_Name + ' ' + isnull(R.Emp_Second_Name,'') 
						+ ' ' + R.Emp_Last_Name) as Emp_Full_Name, R.Resume_Status, P.Job_Title, R.Total_EXP, R.Exp_CTC ,
						Case R.Resume_Status when 0 then 'New'
											when 1 then 'Approved'
											when 2 then 'Hold'
											when 3 then 'Reject'
											end as Resume_Status,
						C.Cmp_Name,C.Cmp_Address,@From_Date as From_Date,@To_Date as To_Date
						from T0055_Resume_Master R WITH (NOLOCK) inner join T0052_HRMS_Posted_Recruitment P WITH (NOLOCK) on
						R.Rec_Post_Id = P.Rec_Post_Id inner join T0010_Company_Master C WITH (NOLOCK) on
						R.Cmp_Id = C.Cmp_Id
						WHERE R.Cmp_ID = @Cmp_Id And R.Resume_ID in 
							(select Emp_ID From @Emp_Cons)
			end
		end
	
	RETURN




