--select * from KPMS_T0020_Goal_Allotment_Master
--select * from T0011_LOGIN where Login_ID = 7013
--exec KPMS_SP0020_Insert_GoalAlt_Details 1,0,'Xyz','Tcs',1,1
CREATE PROCEDURE [dbo].[KPMS_SP0020_Insert_GoalAlt_Details]	
(
@Cmp_ID	Int,
@GoalaltId	Int,
@GoalSheet_Name	Varchar(300),
@Effect_date Varchar(300),
@Dept_Name Varchar(300),
@Desig_Name	Varchar(300),
@Emp_Name	Varchar(300),
@Status Varchar(300),
@User_ID	Int
)
as

SELECT @Effect_date = CASE ISNULL(@Effect_date,'') WHEN '' THEN '' ELSE CONVERT(VARCHAR(10), CONVERT(DATE, @Effect_date, 105), 23) END

IF NOT EXISTS(Select 1 From KPMS_T0020_Goal_Allotment_Master WHERE GoalAlt_ID = @GoalaltId)

	BEGIN
	INSERT INTO [KPMS_T0020_Goal_Allotment_Master]
				(  [Cmp_ID],
				   [GoalSheet_Name]
				   ,[Galt_Effect_Date]
				   ,[Galt_Dept_Name]
				   ,[Galt_Desig_Name]
				   ,[Galt_Emp_Name]
				   ,[Galt_Status_Name]
				   ,[User_Id]
				   ,[Created_Date]
				  )
		 VALUES
			   (
					@Cmp_ID		,					
					@GoalSheet_Name	,
					@Effect_date	,
					@Dept_Name , 
						@Desig_Name,
					 @Emp_Name,
					 @Status ,
					@User_ID	,
					GETDATE()	
				)
	END

ELSE

	BEGIN
					UPDATE [KPMS_T0020_Goal_Allotment_Master]
					SET [Cmp_ID] =@Cmp_ID,
			  	     [GoalSheet_Name] =@GoalSheet_Name
				    ,[Galt_Effect_Date] = @Effect_date
				    ,[Galt_Dept_Name] =@Dept_Name
				    ,[Galt_Desig_Name] = @Desig_Name
				    ,[Galt_Emp_Name] = @Emp_Name
				    ,[Galt_Status_Name] = @Status
				    ,[User_ID] =@User_ID
				    ,[Modify_Date] =GETDATE()
				   WHERE [GoalAlt_ID] = @GoalaltId
	END

