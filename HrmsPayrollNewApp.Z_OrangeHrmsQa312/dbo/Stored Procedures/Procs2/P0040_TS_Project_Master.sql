

 ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0040_TS_Project_Master]   
@Project_ID NUMERIC output,   
@Project_Name varchar(100),   
@Project_Code varchar(50),   
@Project_Description varchar(MAX),   
@Start_Date datetime,   
@Due_Date datetime,   
@Duration varchar(50),   
@Project_Status_ID numeric(18,0),   
@TimeSheet_Approval_Type varchar(50),
@Project_Cost numeric(18,2),
@Client_ID numeric(18,0),
@Attachment varchar(MAX),
@Address1 varchar(MAX),
@Address2 varchar(MAX),
@Loc_ID numeric(18,0),
@State_ID numeric(18,0),
@Zipcode varchar(50),
@PhoneNo varchar(50),
@FaxNo varchar(50),
@Contact_Person varchar(50),
@Contact_Email varchar(50),
@Specialty varchar(50),
@Contract_Type varchar(50),
@Fedora_Charges numeric(18,2),
@Assign_To varchar(max),   
@Completed int,   
@Disabled int,
@Overhead_Calculation int,   
@Cmp_ID numeric(18,0),   
@Created_By numeric(18,0),   
@Trans_Type varchar(1),
@City varchar(50),
@TaskDetails varchar(Max),
@Branch_ID numeric(18,0) = NULL,
@strBranchID varchar(MAX),
@Savedby varchar(500) = ''

  
AS  
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @Project_Detail_ID as numeric(18,0)  
DECLARE @EMPID Numeric(18,0)
DECLARE @Task_ID Numeric(18,0)
DECLARE @Task_Name varchar(50)
Declare @LoginCreated as Numeric
Declare @CreatedTime as Datetime


CREATE TABLE #TEMP (
	PROJECT_DETAIL_ID NUMERIC,
	PROJECT_ID NUMERIC,
	ASSIGN_TO NUMERIC,
	BRANCH_ID NUMERIC,
	CMP_ID NUMERIC,
	CREATED_BY NUMERIC,
	CREATED_DATE DATETIME,
	MODIFY_BY NUMERIC,
	MODIFY_DATE DATETIME
)

IF @Project_Status_ID = 0
	set	@Project_Status_ID = null
IF @Client_ID = 0
	set @Client_ID = null 
IF @Branch_ID = 0
	set @Branch_ID = null 
If @Trans_Type  = 'I'  
	BEGIN
		If Exists(Select Project_ID From T0040_TS_Project_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Project_Name) = upper(@Project_Name))  
			BEGIN  
				SET @Project_ID = 0  
			RETURN  
		END
		SELECT @Project_ID = Isnull(max(Project_ID),0) + 1  FROM T0040_TS_Project_Master WITH (NOLOCK)  
      
		INSERT INTO T0040_TS_Project_Master(Project_ID,Project_Name,Project_Code,Project_Description,Start_Date,Due_Date,Duration,Project_Status_ID,
		TimeSheet_Approval_Type,Project_Cost,Client_ID, Completed,Disabled,Attachment,Address1,Address2,Loc_ID,State_ID,City,Zipcode,PhoneNo,FaxNo,
		Contact_Person,Contact_Email,Speciality_ID,Contract_Type,Fedora_Charges,Overhead_Calculation, Cmp_ID,Created_By,Created_Date,Branch_ID)  
		VALUES(@Project_ID,@Project_Name,@Project_Code,@Project_Description,@Start_Date,@Due_Date,@Duration,@Project_Status_ID,@TimeSheet_Approval_Type,
		@Project_Cost,@Client_ID,@Completed,@Disabled,@Attachment,@Address1,@Address2,@Loc_ID,@State_ID,@City,@Zipcode,@PhoneNo,@FaxNo,
		@Contact_Person,@Contact_Email,@Specialty,@Contract_Type,@Fedora_Charges,@Overhead_Calculation,@Cmp_ID,@Created_By,GETDATE(),@Branch_ID)
		
		
		
		--DECLARE Project_CURSOR CURSOR FOR SELECT data from dbo.Split(@Assign_To,'#')
		  
		DECLARE Project_CURSOR CURSOR FOR 
		
		SELECT EM.Data AS 'Emp_ID',BM.Data AS 'Branch_ID'
		FROM 
		(
			SELECT * FROM dbo.Split(@Assign_To,'#') 
		) EM
		FULL OUTER JOIN 
		(
			SELECT * FROM dbo.Split(@strBranchID,'#')
			
		) BM
		ON EM.Id = BM.Id
		
		OPEN Project_CURSOR  
		FETCH NEXT FROM Project_CURSOR INTO @EMPID,@Branch_ID 
		WHILE @@fetch_status = 0  
			BEGIN  
				SELECT @Project_Detail_ID = ISNULL(MAX(Project_Detail_ID), 0) + 1 FROM T0050_TS_Project_Detail  WITH (NOLOCK)
				INSERT INTO T0050_TS_Project_Detail(Project_Detail_ID,Project_ID,Assign_To,Branch_ID,Cmp_ID,Created_By,Created_Date)
				VALUES (@Project_Detail_ID,@Project_ID,@EMPID,@Branch_ID,@Cmp_ID,@Created_By,GETDATE()) 
				
				FETCH NEXT FROM Project_CURSOR INTO @EMPID,@Branch_ID    
			END  
		CLOSE Project_CURSOR  
		DEALLOCATE Project_CURSOR 
		---------- Entry in Task Master ------
		IF @TaskDetails <> ''
			BEGIN
				DECLARE Task_CURSOR CURSOR FOR SELECT data from dbo.Split(@TaskDetails,'#')  

				OPEN Task_CURSOR  
				FETCH NEXT FROM Task_CURSOR INTO @Task_Name  
				WHILE @@fetch_status = 0  
					BEGIN  
						IF NOT EXISTS(SELECT Task_ID FROM T0040_Task_Master WITH (NOLOCK) WHERE Cmp_ID = @Cmp_ID AND UPPER(Task_Name) = UPPER(@Task_Name) AND Project_ID = @Project_ID AND IsReOpen = 1 )
							BEGIN
								SELECT @Task_ID = ISNULL(MAX(Task_ID),0) + 1  FROM T0040_Task_Master WITH (NOLOCK)
								
								INSERT INTO T0040_Task_Master(Task_ID,Task_Name,Project_ID,IsReOpen,Cmp_ID,Created_By,Created_Date)
								VALUES (@Task_ID,@Task_Name,@Project_ID,1,@Cmp_ID,@Created_By,GETDATE())
							END
						
						FETCH NEXT FROM Task_CURSOR INTO @Task_Name    
					END  
				CLOSE Task_CURSOR  
				DEALLOCATE Task_CURSOR
			END
		---------- Entry in Task Master ------
	END
ELSE IF @Trans_Type = 'U'  
	BEGIN  
		If Exists(Select Project_ID From T0040_TS_Project_Master WITH (NOLOCK)  Where Cmp_ID = @Cmp_ID and upper(Project_Name) = upper(@Project_Name) and Project_ID <> @Project_ID)  
			BEGIN  
				SET @Project_ID = 0  
				Return   
			END  
			
		UPDATE T0040_TS_Project_Master SET Project_Name=@Project_Name,Project_Code=@Project_Code,Project_Description=@Project_Description,
		Start_Date=@Start_Date,Due_Date=@Due_Date,Duration=@Duration,Project_Status_ID=@Project_Status_ID,TimeSheet_Approval_Type=@TimeSheet_Approval_Type,
		Project_Cost = @Project_Cost,Client_ID = @Client_ID,Completed = @Completed,Disabled = @Disabled,Attachment = @Attachment,Address1 = @Address1,
		Address2 = @Address2,Loc_ID = @Loc_ID,State_ID = @State_ID,City=@City,Zipcode =@Zipcode,PhoneNo = @PhoneNo,FaxNo = @FaxNo,
		Contact_Person = @Contact_Person,Contact_Email = @Contact_Email,Speciality_ID=@Specialty,Contract_Type=@Contract_Type,Fedora_Charges=@Fedora_Charges,
		Overhead_Calculation = @Overhead_Calculation,Cmp_ID=@Cmp_ID,Modify_By=@Created_By,Modify_Date=GETDATE(),Branch_ID = @Branch_ID   
		WHERE Project_ID = @Project_ID  
		
		--DELETE FROM T0050_TS_Project_Detail WHERE Project_ID = @Project_ID  
		
		----DECLARE Project_CURSOR CURSOR FOR SELECT data from dbo.Split(@Assign_To,'#')  
		--DECLARE Project_CURSOR CURSOR FOR
		--SELECT EM.Data AS 'Emp_ID',BM.Data AS 'Branch_ID'
		--FROM 
		--(
		--	SELECT * FROM dbo.Split(@Assign_To,'#') 
		--) EM
		--FULL OUTER JOIN 
		--(
		--	SELECT * FROM dbo.Split(@strBranchID,'#')
			
		--) BM
		--ON EM.Id = BM.Id
		
		--OPEN Project_CURSOR  
		--FETCH NEXT FROM Project_CURSOR INTO @EMPID,@Branch_ID  
		--WHILE @@fetch_status = 0  
		--	BEGIN

				SELECT @LoginCreated = Created_By,@CreatedTime = Created_Date FROM T0040_TS_Project_Master WHERE Cmp_ID = @Cmp_ID and Project_ID = @Project_ID
				
				DELETE FROM T0050_TS_Project_Detail WHERE Cmp_ID = @Cmp_ID AND Project_ID = @Project_ID

				SELECT top 1 @Project_Detail_ID = Project_Detail_ID  FROM T0050_TS_Project_Detail order by Project_Detail_ID desc
				--Set @Project_Detail_ID = @Project_Detail_ID 

				Insert into #TEMP	
				select @Project_Detail_ID+T.RowNo as Project_Detail_ID,@Project_ID,T.AssignTo , @Branch_ID,@Cmp_ID,@LoginCreated,@CreatedTime,@Created_By,GETDATE()
				from
				(  
					select  ROW_NUMBER() OVER (ORDER BY @Project_ID) AS RowNo,AssignTo 
					From (select Cast(data as numeric)  as AssignTo from dbo.Split (@Assign_To,'#')) as a 
				) as T
				
				
				Create table #tmp(
					Project_Detail_ID numeric,
					Branch_Id numeric
				)

				Insert into #tmp
				select @Project_Detail_ID+T.RowNo as Project_Detail_ID,T.Branch_ID
				from
				(  
					select  ROW_NUMBER() OVER (ORDER BY @Project_ID) AS RowNo,Branch_ID
					From (select Cast(data as numeric)  as Branch_ID from dbo.Split (@strBranchID,'#')) as a 
				) as T


				--select @Project_Detail_ID+T.RowNo as Project_Detail_ID,@Project_ID,T.AssignTo , @Branch_ID,@Cmp_ID,@LoginCreated,@CreatedTime,@Created_By,GETDATE()
				--from  
				--(  
				--	select  ROW_NUMBER() OVER (ORDER BY @Project_ID) AS RowNo,AssignTo 
				--	From (select Cast(data as numeric)  as AssignTo from dbo.Split (@Assign_To,'#')) as a
				--) as T


				INSERT INTO T0050_TS_Project_Detail(Project_Detail_ID,Project_ID,Assign_To,Branch_ID,Cmp_ID,Created_By,Created_Date,Modify_By,Modify_Date)
				SELECT t.Project_Detail_ID,isnull(Project_ID,@Project_ID) as Project_Id,Assign_To,T.Branch_Id,
				Isnull(CMP_ID,@Cmp_ID) as Cmp_Id,isnull(CREATED_BY,@LoginCreated) as L,
				Isnull(CREATED_DATE,@CreatedTime) as C,Isnull(MODIFY_BY,@Created_By) as MY,Isnull(MODIFY_DATE,GETDATE()) as MD
				FROM #tmp T	left join #TEMP TP on t.Project_Detail_ID = tp.PROJECT_DETAIL_ID
					

				Drop Table #tmp
				--DELETE FROM #TEMP WHERE CMP_ID = @Cmp_ID AND ASSIGN_TO IN (SELECT ASSIGN_TO FROM T0050_TS_Project_Detail WHERE CMP_ID = @Cmp_ID AND Project_ID = @Project_ID)

				--INSERT INTO T0050_TS_Project_Detail(Project_Detail_ID,Project_ID,Assign_To,Branch_ID,Cmp_ID,Created_By,Created_Date,Modify_By,Modify_Date)
				--VALUES (@Project_Detail_ID,@Project_ID,@EMPID,@Branch_ID,@Cmp_ID,@LoginCreated,@CreatedTime,@Created_By,GETDATE())   
		--		FETCH NEXT FROM Project_CURSOR INTO @EMPID,@Branch_ID 
		--	END
		--CLOSE Project_CURSOR  
		--DEALLOCATE Project_CURSOR 
		---------- Update in Task Master ------
		IF @TaskDetails <> ''
			BEGIN
				DECLARE TaskUpdate_CURSOR CURSOR FOR SELECT data from dbo.Split(@TaskDetails,'#')  

				OPEN TaskUpdate_CURSOR  
				FETCH NEXT FROM TaskUpdate_CURSOR INTO @Task_Name  
				WHILE @@fetch_status = 0  
					BEGIN  
						IF NOT EXISTS (SELECT Task_ID FROM T0040_Task_Master WITH (NOLOCK) WHERE Project_ID = @Project_ID AND Task_Name = @Task_Name AND IsReOpen = 1 )							BEGIN
								SELECT @Task_ID = ISNULL(MAX(Task_ID),0) + 1  FROM T0040_Task_Master WITH (NOLOCK)
						
								INSERT INTO T0040_Task_Master(Task_ID,Task_Name,Project_ID,Cmp_ID,Created_By,Created_Date)
								VALUES (@Task_ID,@Task_Name,@Project_ID,@Cmp_ID,@Created_By,GETDATE())
							END
						FETCH NEXT FROM TaskUpdate_CURSOR INTO @Task_Name    
					END  
				CLOSE TaskUpdate_CURSOR  
				DEALLOCATE TaskUpdate_CURSOR
			END
		---------- Entry in Task Master ------
		
	END  
ELSE IF @Trans_Type = 'D'  
	BEGIN  
		Delete From T0050_TS_Project_Detail Where Project_ID = @Project_ID 
		Delete From T0040_TS_Project_Master Where Project_ID = @Project_ID  
	END





