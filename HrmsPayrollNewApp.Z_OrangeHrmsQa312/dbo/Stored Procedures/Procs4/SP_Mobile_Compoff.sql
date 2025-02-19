
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_Mobile_Compoff]
	@Compoff_App_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@SEmp_ID numeric(18,0),
	@Extra_Work_Date Datetime,
	@Extra_Work_Hours VARCHAR(50),
	@Extra_Work_Reason VARCHAR(255),
	@CompOff_Type varchar(50),
	@DayFlag varchar(50),
	@OT_Type int,
	@Sanctioned_Hours Varchar(10),
	@Approval_Status Char(1)  ,
	@Approval_Comments Varchar(250),
	@Login_ID numeric(18,0),
	@Type Char(1),
	@Result VARCHAR(100) OUTPUT
	

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

DECLARE @ForDate Datetime

SET @ForDate = CAST(GETDATE() AS varchar(11))

IF @Type = 'O' -- For Get Over Time Date List for Comp-Off
	BEGIN
		EXEC GET_Applicable_Working_Date_For_CompOff @Cmp_ID = @Cmp_ID,@Branch_ID = 0,@Emp_ID = @Emp_ID,
		@For_Date = @ForDate,@constraint = '',@Sanctioned_Hours = '',@Search_Flag = 0,@with_table = 0
	END
ELSE IF @Type = 'I' -- For Comp-Off Application
	BEGIN
		BEGIN TRY
			EXEC P0100_COMPOFF_APPLICATION @Compoff_App_ID OUTPUT,@Cmp_ID = @Cmp_ID,@Emp_ID = @Emp_ID,
			@S_Emp_ID = @SEmp_ID,@CompOff_App_Date = @ForDate,@Extra_Work_Date = @Extra_Work_Date,@Extra_Work_Hours = @Extra_Work_Hours,
			@Application_Status = 'P',@Extra_Work_Reason = @Extra_Work_Reason,@Login_ID = @Login_ID,
			@System_Date = @ForDate,@Trans_Type='Insert',@CompOff_Type = @DayFlag,@User_Id = @Login_ID,
			@IP_Address = 'Mobile',@OT_Type = @OT_Type
			
			SET @Result = 'Comp-Off Approved Successfully#True#'
			
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
		END CATCH
	END
ELSE IF @Type = 'S'
	BEGIN
		SELECT Compoff_App_ID,Emp_ID,Emp_Full_Name,Extra_Work_Date,Extra_Work_Hours,Application_Status,Senior_Employee,
		Emp_first_name,Emp_Code,Branch_Name,Desig_Name,Alpha_Emp_code,Extra_Work_Reason,CompOff_Type
		FROM V0110_COMPOFF_APPLICATION_DETAIL 
		WHERE Cmp_ID = @Cmp_ID AND Emp_ID = @Emp_ID AND Application_Status = 'P'
		ORDER BY Compoff_App_ID ASC
	END
ELSE IF @Type = 'P' -- For Comp Off Pendig Application Count
	BEGIN
		IF @Compoff_App_ID = 0 -- For List of Pending Application
			BEGIN
				
				SELECT * 
				FROM V0110_COMPOFF_APPLICATION_DETAIL VC
				INNER JOIN
				(
					SELECT RD.EMP_ID
					FROM T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) 
					INNER JOIN 
					(
						SELECT MAX(EFFECT_DATE) AS EFFECT_DATE,EMP_ID FROM T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK)
						WHERE EFFECT_DATE <= GETDATE()
						GROUP BY EMP_ID
					) AS EMP_SUP
					ON RD.EMP_ID = EMP_SUP.EMP_ID AND RD.EFFECT_DATE = EMP_SUP.EFFECT_DATE
					INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON RD.Emp_ID = EM.Emp_ID
					WHERE RD.R_EMP_ID = @Emp_ID AND (EM.Emp_Left = 'N' OR  (EM.Emp_Left = 'Y' AND EM.Emp_Left_Date > GETDATE()))
					GROUP BY RD.EMP_ID 
				) EM ON VC.Emp_ID = EM.Emp_ID
				WHERE Application_Status = 'P'
				ORDER BY Compoff_App_ID ASC
			END
		ELSE -- For Comp Off Pendig Application Count
			BEGIN
				IF EXISTS(SELECT 1 FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID AND (CONVERT(VARCHAR(11),From_date,120)) = CONVERT(VARCHAR(11),GETDATE(),120) AND CONVERT(VARCHAR(11),To_date,120) >= CONVERT(VARCHAR(11),GETDATE(),120) AND Pass_To_Emp_id = @EMP_ID AND Type = 'Comp off')
					BEGIN					
						SELECT COUNT(V.Compoff_App_ID) AS 'COMPOFF' 
						FROM T0095_MANAGER_RESPONSIBILITY_PASS_TO M WITH (NOLOCK)
						INNER JOIN 	V0110_COMPOFF_APPLICATION_DETAIL V ON M.Manger_Emp_id = V.S_Emp_ID 											
						INNER JOIN 
						(
							SELECT R1.EMP_ID,R_Emp_ID,R1.Effect_Date 										
							FROM T0090_EMP_REPORTING_DETAIL R1	WITH (NOLOCK)				
							INNER JOIN 
							(
								SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID			
								FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
								GROUP BY Emp_ID	
							) R2 ON R1.Emp_ID = R2.Emp_ID AND R1.Effect_Date = R2.Effect_Date	
						) R1 ON V.Emp_ID = R1.Emp_ID						
						WHERE Pass_To_Emp_id = @Emp_ID AND  GETDATE() >= from_date AND getdate() <= to_date AND Type = 'Comp Off' AND M.Cmp_id=@Cmp_id AND V.Application_Status='P' 	
					   GROUP BY V.Compoff_App_ID											
					END
				ELSE
					BEGIN
						SELECT	ISNULL(COUNT(Compoff_App_ID),0) AS 'COMPOFF'
						FROM V0110_COMPOFF_APPLICATION_DETAIL COMP
						INNER JOIN 
						(
							SELECT R1.EMP_ID,R_Emp_ID,R1.Effect_Date 
							FROM T0090_EMP_REPORTING_DETAIL R1 WITH (NOLOCK)
							INNER JOIN 
							(
								SELECT MAX(Effect_Date) AS 'Effect_Date',Emp_ID
								FROM T0090_EMP_REPORTING_DETAIL R2 WITH (NOLOCK)
								GROUP BY Emp_ID
							) R2 ON R1.Emp_ID = R2.Emp_ID AND R1.Effect_Date = R2.Effect_Date
						) R1 ON COMP.Emp_ID = R1.Emp_ID
						WHERE Application_Status = 'P' AND R1.R_Emp_ID = @Emp_ID	
					END
			
			END	
	END
ELSE IF @Type = 'E' -- For Comp Off Application Details
	BEGIN
		EXEC GET_Applicable_Working_Date_For_CompOff @cmp_ID = @Cmp_ID,@Branch_ID = 0,@Emp_ID = @Emp_ID,
		@For_Date = @Extra_Work_Date,@constraint = '',@Sanctioned_Hours = @Extra_Work_Hours,@Search_Flag = 1
	END
ELSE IF @TYPE = 'A'
	BEGIN
		
		BEGIN TRY
		
			EXEC P0120_COMPOFF_APPROVAL @Compoff_App_ID OUTPUT,@CompOff_Application_ID = @Compoff_App_ID,@Cmp_ID=@Cmp_ID,@Emp_ID = @Emp_ID,
			@S_Emp_ID = @SEmp_ID,@Extra_Work_Date = @Extra_Work_Date,@Approval_Date = @ForDate,@Extra_Work_Hours = @Extra_Work_Hours,
			@Sanctioned_Hours = @Sanctioned_Hours,@Approval_Status = @Approval_Status,@Extra_Work_Reason = @Extra_Work_Reason,@Approval_Comments=@Approval_Comments,
			@Contact_No = '',@Email_ID = '',@Login_ID = @Login_ID,
			@System_Date = @ForDate,@Tran_type='I',@User_Id = @Login_ID,
			@IP_Address = 'Mobile'
			
			IF(@Approval_Status = 'R')
					SET @Result = 'Comp-Off Rejected Done#True#'
				ELSE
					SET @Result = 'Comp-Off Approved Done#True#'
				
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE() + '#False#'
		END CATCH
	
	END

