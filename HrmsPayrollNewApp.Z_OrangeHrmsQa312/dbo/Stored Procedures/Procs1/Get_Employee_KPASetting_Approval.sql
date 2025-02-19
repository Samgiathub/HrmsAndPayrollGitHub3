


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_Employee_KPASetting_Approval]
	 @Emp_Id		numeric(18,0)
	,@ApproverId	numeric(18,0)
	,@KPA_InitId	numeric(18,0)
	,@FinalApprove	int
	,@rpt_level		int
	,@HODId			numeric(18,0)
	,@GHId			numeric(18,0)
	,@AppType		varchar(3)
	,@Approval_Type int 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	IF @Approval_Type = 1
		BEGIN
			IF @FinalApprove = 0
				BEGIN
					IF @rpt_level = 1
						BEGIN
							IF @AppType = 'RM'
								BEGIN
									IF	@HODId <> 0
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @HODId
										END	
									Else IF	@GHId <> 0
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @GHId
										END	
									ELSE
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
										END					
								END
							ELSE IF @AppType = 'HOD'
								BEGIN
									IF	@GHId <> 0
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @GHId
										END	
									ELSE
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
										END	
								END
							ELSE IF @AppType = 'GH'
								BEGIN
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								END
							ELSE
								BEGIN
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								END
						END
					ELSE IF @rpt_level= 2
						BEGIN
							IF @AppType = 'HOD'
								BEGIN
									IF	@GHId <> 0
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @GHId
										END	
									ELSE
										BEGIN
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
											SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
										END	
								END
							Else IF @AppType = 'GH'
								BEGIN
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								END
							ELSE
								BEGIN
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
									SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
								END
						END
					ELSE IF @rpt_level= 3
						BEGIN
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
						END
				END
			ELSE
				BEGIN
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
				END
		END
	ELSE IF @Approval_Type = 2
		BEGIN
			IF @rpt_level = 1
				BEGIN
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
				END
			ELSE IF @rpt_level = 2
				BEGIN
					IF @AppType = 'HOD'
						BEGIN
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
							SELECT ER.Emp_Full_Name,ISNULL(ER.Work_Email,'')Work_Email,e.Alpha_Emp_Code FROM T0080_EMP_MASTER E WITH (NOLOCK) INNER JOIN
								   T0080_EMP_MASTER ER WITH (NOLOCK) on ER.Emp_ID = E.Emp_Superior	
							 WHERE E.Emp_ID = @Emp_id
						END
					ELSE IF @AppType = 'GH'
						BEGIN
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
							SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @HODId
						END
				END
			ELSE IF @rpt_level = 3
				BEGIN
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @ApproverId
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @Emp_id
					SELECT Emp_Full_Name,ISNULL(Work_Email,'')Work_Email,Alpha_Emp_Code FROM T0080_EMP_MASTER WITH (NOLOCK) WHERE Emp_ID = @HODId
				END
		END
END


