

-- Created By Mukti on 04012016 for Default_Entry of Scheme.
---01/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- ===============================================================
CREATE PROCEDURE [dbo].[InsertDefaultScheme] 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		Declare @Scheme Table(Scheme varchar(100),Module_Name varchar(100))

		insert into @Scheme values  ('Leave','')
		insert into @Scheme  values ('Loan','PAYROLL')
		insert into @Scheme values  ('Claim','PAYROLL')
		insert into @Scheme  values ('Travel','PAYROLL')
		insert into @Scheme  values ('Travel Settlement','PAYROLL')
		insert into @Scheme  values ('Reimbursement','PAYROLL')
		insert into @Scheme  values ('Attendance Regularization','')
		insert into @Scheme  values ('Over Time','')
		insert into @Scheme  values ('Change Request','')
		insert into @Scheme  values ('Pre-CompOff','')
		insert into @Scheme  values ('Recruitment Request','HRMS')
		insert into @Scheme  values ('Candidate Approval','HRMS')
		insert into @Scheme  values ('KPI Objectives','APPRAISAL3')
		insert into @Scheme  values ('Appraisal Review','APPRAISAL3')
		
		insert into @Scheme  values ('Trainee','PAYROLL')	--Ankit 23012016
		insert into @Scheme  values ('Probation','PAYROLL')	--Ankit 23012016
		insert into @Scheme  values ('GatePass','PAYROLL')	--Ankit 26052016
		
		insert INTO @Scheme VALUES ('Exit','PAYROLL')   --Added By Jaina 03-06-2016
		insert INTO @Scheme VALUES ('Increment','PAYROLL')   --Ankit 20072016
		insert INTO @Scheme VALUES ('Own Vehicle','PAYROLL')
		
		insert INTO @Scheme VALUES ('Employee Application','PAYROLL') --Added by ronakk 04082023
		insert INTO @Scheme VALUES ('GOAL','PAYROLL')				  --Added by ronakk 04082023
		insert INTO @Scheme VALUES ('Ticket Module','PAYROLL')		  --Added by ronakk 04082023
		insert INTO @Scheme VALUES ('File Management','PAYROLL')	  --Added by ronakk 04082023




		DECLARE @Scheme_Name Nvarchar(max), 
				@Module_Name NVARCHAR(MAX)				

		DECLARE S_Master CURSOR FOR SELECT Scheme,Module_Name FROM @Scheme
		OPEN S_Master
		FETCH NEXT FROM S_Master INTO @Scheme_Name,@Module_Name
		WHILE @@FETCH_STATUS = 0
		BEGIN
			if @Module_Name=''
				set @Module_Name= NULL
				
			DECLARE @CNT as int
			DECLARE @Scheme_id_max as int
			SET @CNT = 0	
			SET @CNT = (Select COUNT(*) from T0001_SCHEME_MASTER WITH (NOLOCK) WHERE UPPER(Scheme) = UPPER(@Scheme_Name))
			IF @CNT = 0
			BEGIN
			   select @Scheme_id_max = isnull(max(Scm_Id),0) + 1 from T0001_SCHEME_MASTER WITH (NOLOCK)
			   INSERT INTO T0001_SCHEME_MASTER (Scm_Id,Scheme,Module_Name,Modify_Date) VALUES (@Scheme_id_max,@Scheme_Name,@Module_Name,GETDATE())
			END
		   FETCH NEXT FROM S_Master INTO @Scheme_Name,@Module_Name
		END

		CLOSE S_Master
		DEALLOCATE S_Master
END


