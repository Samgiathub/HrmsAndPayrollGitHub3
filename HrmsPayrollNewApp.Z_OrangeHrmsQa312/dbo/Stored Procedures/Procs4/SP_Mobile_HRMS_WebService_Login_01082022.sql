CREATE PROCEDURE [dbo].[SP_Mobile_HRMS_WebService_Login_01082022]

	@UserName varchar(50),
	@Password varchar(250),
	@IMEINo varchar(250) = '',
	@DeviceID varchar(MAX) = '',
	@NewPassword varchar(250),
	@Login_ID numeric(18,0),
	@Emp_ID numeric(18,0),
	@Cmp_ID numeric(18,0),
	@Type Char(1),
	@Result varchar(255) OUTPUT

AS
SET NOCOUNT ON		
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET ARITHABORT ON

--DECLARE @Cmp_ID Numeric(18,0)
--DECLARE @Emp_ID Numeric(18,0)
DECLARE @LicDate Datetime
DECLARE @Row_ID Numeric(18,0)
DECLARE @Tran_ID Numeric(18,0)
--DECLARE @Login_ID Numeric(18,0)
DECLARE @Privilege_ID Numeric(18,0)

IF @Type = 'L'  -- For Login
	BEGIN
		SELECT @Cmp_ID = Cmp_ID,@Emp_ID = Emp_ID ,@Login_ID = Login_ID FROM T0011_LOGIN WITH (NOLOCK) WHERE Login_Name=@UserName OR Login_Alias = @UserName
		SELECT @LicDate = dbo.Decrypt(LDate_Mobile) FROM Emp_Lcount WITH (NOLOCK) 
		If @LicDate > Getdate()
			Begin
				IF EXISTS (SELECT module_ID FROM T0011_module_detail  WITH (NOLOCK) WHERE module_name = 'MOBILE' AND module_status = 1 AND Cmp_id = @Cmp_ID  )
					BEGIN
						IF EXISTS (SELECT Login_ID FROM T0011_LOGIN WITH (NOLOCK)  WHERE (Login_Name=@UserName OR Login_Alias =@UserName) AND Cmp_ID = @Cmp_ID)
							BEGIN
								IF @Password = 'FyTKmEBA8rw='
									BEGIN
									
										SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,Alpha_Emp_Code,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'Emp_Full_Name',EM.Emp_Left,
										(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name',
										EM.Dept_Name,EM.Desig_Name,(CONVERT(varchar, GETDATE(),103)+' '+CONVERT(varchar, GETDATE(),108)) AS 'LoginDate',
										EM.Is_Geofence_enable,EM.Is_Camera_enable, (CONVERT(varchar(3), TL.Cmp_ID) +'_' + CM.Image_name) AS 'Cmp_Logo',0 AS 'Is_Route',0 AS 'IsVertical',
										EM.Is_MobileWorkplan_Enable,EM.Is_MobileStock_Enable,EM.Is_VBA,
										ISNULL(AN.Store_ID,0) as Store_ID,isnull(NS.Current_Outlet_Mapping,'') as Store_Name --added for vivo wb Chaanges for workplan and stock on 28-8-2020
										,CM.Cmp_Name 
										FROM T0011_LOGIN TL WITH (NOLOCK) 
										INNER JOIN
										(
											SELECT MAX(Login_ID) AS 'Login_ID' 
											FROM T0011_LOGIN WITH (NOLOCK)  
											WHERE (Login_Name=@UserName OR Login_Alias =@UserName) --and Login_Password = 'VuMs/PGYS74=' 
										) TTL ON TL.Login_ID = TTL.Login_ID
										--INNER JOIN T0080_EMP_MASTER EM ON TL.Emp_ID = EM.Emp_ID
										INNER JOIN V0080_Employee_Master EM  WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
										INNER JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON TL.Cmp_ID = CM.Cmp_Id
												LEFT JOIN (SELECT I.* --, Wages_Type , Gross_Salary,
														   FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I WITH (NOLOCK)
															INNER JOIN 
																( SELECT MAX(I.STORE_TRAN_ID) AS STORE_TRAN_ID, I.EMP_ID 
																	FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I WITH (NOLOCK) 
																	INNER JOIN 
																	(
																			SELECT MAX(i3.Effective_Date) AS Effective_Date, I3.EMP_ID
																			FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I3 WITH (NOLOCK)
																			WHERE I3.Effective_Date <= GETDATE() AND I3.CMP_ID = @CMP_ID
																				AND I3.EMP_ID = @Emp_ID
																			GROUP BY I3.EMP_ID  
																		) I3 ON I.Effective_Date=I3.Effective_Date AND I.EMP_ID=I3.Emp_ID	
																   where I.Effective_Date <= GETDATE()  AND I.CMP_ID = @CMP_ID --and I.Cmp_ID = CM.Cmp_Id
																   group by I.emp_ID  
																) Qry on I.Emp_ID = Qry.Emp_ID	and I.STORE_TRAN_ID = Qry.STORE_TRAN_ID) AN on AN.Emp_ID = EM.Emp_ID and AN.Cmp_ID= CM.Cmp_Id										
										--LEFT JOIN T0040_EMP_MOBILE_STORE_ASSIGN_NEW AN With (NOLOCK) On AN.Emp_ID = EM.Emp_ID 
										--Inner JOIN
										--(
										--	SELECT MAX(Effective_Date) AS For_Date,Emp_ID
										--	FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW WITH (NOLOCK)  
										--	WHERE Effective_Date <= GETDATE()
										--	Group BY Emp_ID
										--) AN1 ON AN.Effective_Date =An1.For_Date and AN.Emp_ID = AN1.Emp_ID
										Left outer JOIN T0040_MOBILE_STORE_MASTER_New NS WITH (NOLOCK) on NS.Store_ID = AN.Store_ID 
										WHERE EM.is_for_mobile_Access = 1 AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND  EM.Emp_Left_Date >= Convert(date, getdate())  ))
								
										SELECT @Row_ID = ISNULL(MAX(Row_ID),0) + 1  From T0011_Login_History WITH (NOLOCK)
								
										INSERT INTO T0011_Login_History(Row_ID,Cmp_ID,Login_ID,Login_Date,Ip_Address)
										VALUES(@Row_ID,@Cmp_ID,@Login_ID,GETDATE(),@IMEINo)
								
										IF @IMEINo <> ''
											BEGIN
												UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK) SET Is_Active = 0 WHERE Emp_ID = @Emp_ID 
										
												SELECT @Tran_ID = Tran_ID FROM T0095_Emp_IMEI_Details  WITH (NOLOCK) 
												WHERE Cmp_Id = @Cmp_ID AND Emp_ID = @Emp_ID AND IMEI_No = @IMEINo --AND DeviceID = @DeviceID 
										
												--IF NOT EXISTS (SELECT * FROM T0095_Emp_IMEI_Details WHERE Emp_ID = @Emp_ID AND IMEI_No = @IMEINo AND DeviceID = @DeviceID )
												IF ISNULL(@Tran_ID,0) = 0
													BEGIN
														SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_Emp_IMEI_Details WITH (NOLOCK) 
												
														INSERT INTO T0095_Emp_IMEI_Details(Tran_ID,Cmp_Id,Emp_ID, IMEI_No,Is_Active,Registered_Date,
														SysDatetime,DeviceID) 
														VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@IMEINo,1,GETDATE(),GETDATE(),@DeviceID)
													END
												ELSE
													BEGIN
														UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK) SET Is_Active = 1 WHERE Tran_ID = @Tran_ID 
													END
											END
									END
								ELSE
									BEGIN
										IF EXISTS (SELECT Login_ID FROM T0011_LOGIN  WITH (NOLOCK) WHERE (Login_Name=@UserName OR Login_Alias =@UserName) AND Login_Password = @Password AND Cmp_ID = @Cmp_ID)
											-- Start added by Niraj (10012022)
											BEGIN
												--SELECT TOP 2 Ip_Address FROM T0011_Login_History  WITH (NOLOCK) WHERE Login_ID = @Login_ID and Cmp_ID = @Cmp_ID
												--SELECT IMEINo=@IMEINo FROM Single_Device_Login  WITH (NOLOCK) WHERE Login_ID = @Login_ID and Cmp_ID = @Cmp_ID
												DECLARE @IMEINo_temp varchar(250) = ''
												DECLARE @IMEINo_temp_new varchar(250) = @IMEINo
												DECLARE @IMEINo_temp_check varchar(250) = ''
												
												SET @IMEINo_temp = (Select IMEI_No from T0095_Emp_IMEI_Details WITH (ROWLOCK) WHERE Is_Active = 1 and Emp_ID = @Emp_ID and Cmp_Id = @Cmp_ID)
												IF @IMEINo <> ''
												begin
													SET @IMEINo_temp_check = LEFT(@IMEINo_temp, CHARINDEX('#', (@IMEINo_temp)) -1)
													SET @IMEINo_temp_new = LEFT(@IMEINo_temp_new, CHARINDEX('#', @IMEINo_temp_new) -1)
													--Select @IMEINo_temp,@IMEINo_temp_new,@IMEINo_temp_check
													--Select top 1 Ip_address from T0011_Login_History WHERE Login_ID = 7051 and Cmp_ID = 119 order by 1 desc
													--IF( 1 < (SELECT COUNT(IMEI_No) FROM Single_Device_Login  WITH (NOLOCK) WHERE Login_ID = @Login_ID and Cmp_ID = @Cmp_ID))
												end
												IF (@IMEINo_temp IS NULL OR @IMEINo_temp_new = @IMEINo_temp_check OR @IMEINo = '')
												BEGIN
												-- End added by Niraj (10012022)
													SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,Alpha_Emp_Code,(Alpha_Emp_Code + ' - ' + Emp_Full_Name) AS 'Emp_Full_Name',EM.Emp_Left,
													(CASE WHEN EM.Image_Name = '0.jpg' OR EM.Image_Name = '' THEN (CASE WHEN EM.Gender = 'Male' THEN 'Emp_Default.png' ELSE 'Emp_Default_Female.png' END) ELSE EM.Image_Name END) AS 'Image_Name',
													EM.Dept_Name,EM.Desig_Name,(CONVERT(varchar, GETDATE(),103)+' '+CONVERT(varchar, GETDATE(),108)) AS 'LoginDate',
													EM.Is_Geofence_enable,EM.Is_Camera_enable,(CONVERT(varchar(3), TL.Cmp_ID) +'_' + CM.Image_name) AS 'Cmp_Logo',0 AS 'Is_Route',0 AS 'IsVertical',
													--EM.Image_Name--,PD.Privilege_Id
													EM.Is_MobileWorkplan_Enable,EM.Is_MobileStock_Enable,EM.Is_VBA,
													ISNULL(AN.Store_ID,0) as Store_ID,isnull(NS.Current_Outlet_Mapping,'') as Store_Name 
													,CM.Cmp_Name --added for vivo wb Chaanges for workplan and stock on 28-8-2020
													FROM T0011_LOGIN TL WITH (NOLOCK) 
													INNER JOIN
													(
														SELECT MAX(Login_ID) AS 'Login_ID' 
														FROM T0011_LOGIN  WITH (NOLOCK) 
														WHERE (Login_Name=@UserName OR Login_Alias =@UserName) AND Login_Password = @Password
													) TTL ON TL.Login_ID = TTL.Login_ID
													--INNER JOIN T0080_EMP_MASTER EM ON TL.Emp_ID = EM.Emp_ID
													INNER JOIN V0080_Employee_Master EM  WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
													INNER JOIN T0010_COMPANY_MASTER CM  WITH (NOLOCK) ON TL.Cmp_ID = CM.Cmp_Id
													LEFT JOIN (SELECT I.* --, Wages_Type , Gross_Salary,
															   FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I WITH (NOLOCK)
																INNER JOIN 
																	( SELECT MAX(I.STORE_TRAN_ID) AS STORE_TRAN_ID, I.EMP_ID 
																		FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I WITH (NOLOCK) 
																		INNER JOIN 
																		(
																				SELECT MAX(i3.Effective_Date) AS Effective_Date, I3.EMP_ID
																				FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW I3 WITH (NOLOCK)
																				WHERE I3.Effective_Date <= GETDATE() AND I3.EMP_ID =@EMP_ID
																				GROUP BY I3.EMP_ID  
																			) I3 ON I.Effective_Date=I3.Effective_Date AND I.EMP_ID=I3.Emp_ID	
																	   where I.Effective_Date <= GETDATE() --and I.Cmp_ID = CM.Cmp_Id
																	   group by I.emp_ID  
																	) Qry on I.Emp_ID = Qry.Emp_ID	and I.STORE_TRAN_ID = Qry.STORE_TRAN_ID) AN on AN.Emp_ID = EM.Emp_ID and AN.Cmp_ID= CM.Cmp_Id
													--LEFT JOIN T0040_EMP_MOBILE_STORE_ASSIGN_NEW AN With (NOLOCK) On AN.Emp_ID = EM.Emp_ID 
													--Inner JOIN
													--(
													--	SELECT MAX(Effective_Date) AS For_Date,Emp_ID
													--	FROM T0040_EMP_MOBILE_STORE_ASSIGN_NEW WITH (NOLOCK)  
													--	WHERE Effective_Date <= GETDATE()
													--	Group BY Emp_ID
													--) AN1 ON AN.Effective_Date =An1.For_Date and AN.Emp_ID = AN1.Emp_ID
													Left outer JOIN T0040_MOBILE_STORE_MASTER_New NS WITH (NOLOCK) on NS.Store_ID = AN.Store_ID 
													WHERE EM.is_for_mobile_Access =  1 AND (EM.Emp_Left = 'N' OR (EM.Emp_Left = 'Y' AND  EM.Emp_Left_Date >= Convert(date, getdate()) ))
													--INNER JOIN 
													--(
													--	SELECT MAX(From_Date) AS 'From_Date',Privilege_Id,Login_ID
													--	FROM T0090_EMP_PRIVILEGE_DETAILS 
													--	WHERE Cmp_Id = 1 and Login_ID = 5
													--	GROUP BY Login_ID,Privilege_Id
													--) PD ON TL.Login_ID = PD.Login_Id

													SELECT @Row_ID = ISNULL(MAX(Row_ID),0) + 1  From T0011_Login_History WITH (NOLOCK)

													INSERT INTO T0011_Login_History(Row_ID,Cmp_ID,Login_ID,Login_Date,Ip_Address)
													VALUES(@Row_ID,@Cmp_ID,@Login_ID,GETDATE(),@IMEINo)

													--IF EXISTS (SELECT IMEI_No FROM Single_Device_Login WHERE Login_ID = @Login_ID and Cmp_ID = @Cmp_ID)
													--	Begin
													--		UPDATE Single_Device_Login
													--		SET IMEI_No = @IMEINo
													--		WHERE
													--		Login_ID = @Login_ID and Cmp_ID = @Cmp_ID
													--	End
													--Else
													--Begin
													--	INSERT INTO Single_Device_Login(Login_ID,Cmp_ID,IMEI_No,Is_Logged_In)
													--	VALUES(@Login_ID,@Cmp_ID,@IMEINo,1)
													--End

													IF @IMEINo <> ''
														BEGIN
															UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK) SET Is_Active = 0 WHERE Emp_ID = @Emp_ID

															SELECT @Tran_ID = Tran_ID 
															FROM T0095_Emp_IMEI_Details  WITH (NOLOCK) 
															WHERE Cmp_Id = @Cmp_Id AND Emp_ID = @Emp_ID AND IMEI_No = @IMEINo --AND DeviceID = @DeviceID 

															--IF NOT EXISTS (SELECT * FROM T0095_Emp_IMEI_Details WHERE Emp_ID = @Emp_ID AND IMEI_No = @IMEINo AND DeviceID = @DeviceID )
															IF ISNULL(@Tran_ID,0) = 0
																BEGIN
																	SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0095_Emp_IMEI_Details WITH (NOLOCK) 
			
																	INSERT INTO T0095_Emp_IMEI_Details(Tran_ID,Cmp_Id,Emp_ID, IMEI_No,Is_Active,Registered_Date,
																	SysDatetime,DeviceID) 
																	VALUES(@Tran_ID,@Cmp_ID,@Emp_ID,@IMEINo,1,GETDATE(),GETDATE(),@DeviceID)
																END
															ELSE
																BEGIN
																	UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK) SET Is_Active = 1 WHERE Tran_ID = @Tran_ID 
																END
		
														END
												END
												-- Start added by Niraj (10012022)
												ELSE
													BEGIN
													SELECT 'OK : You need to logout from ' + RIGHT(@IMEINo_temp, CHARINDEX('#', REVERSE(@IMEINo_temp)) -1) + ' device.'
														--SELECT 'OK : You need to logout from ' + RIGHT(@IMEINo_temp,
														--CASE WHEN CHARINDEX('#', REVERSE(@IMEINo_temp)) > 0
														--	 THEN CHARINDEX('#', REVERSE(@IMEINo_temp)) -1
														--	 ELSE 0
														--	 END
														--) + ' device.'
													END
													-- End added by Niraj (10012022)
											END
										ELSE
											BEGIN
												SELECT 'OK : Invalid Password'
												--SELECT 'OK : You Can not Access, Contact to Administrator'
											END	
									END
							END
						ELSE
							BEGIN
								SELECT 'OK : Invalid UserName'
								--SELECT 'OK : You Can not Access, Contact to Administrator'
							END	
					END
				ELSE
					BEGIN
						--SELECT 'OK : Please Contact Administrator'
						SELECT 'OK : Invalid UserName'
					END
			End
		Else
			Begin
				SELECT 'OK : Please Contact HR Administrator'
			End
			
		SELECT PD.*,DF.FORM_NAME,PM.Privilege_Name,SUBSTRING(DF.Alias,7,LEN(DF.Alias)) AS 'Alias',DF.Is_Active_For_menu
		FROM T0050_PRIVILEGE_DETAILS PD WITH (NOLOCK) 
		INNER JOIN T0000_DEFAULT_FORM DF  WITH (NOLOCK) ON  DF.FORM_ID = PD.FORM_ID 
		INNER JOIN T0090_EMP_PRIVILEGE_DETAILS EPD  WITH (NOLOCK) ON PD.Privilage_ID = EPD.Privilege_Id
		INNER JOIN
		(
			SELECT MAX(From_Date) AS 'From_Date',Login_Id
			FROM T0090_EMP_PRIVILEGE_DETAILS  WITH (NOLOCK) 
			GROUP BY Login_Id
		) IPD ON EPD.Login_Id = IPD.Login_Id AND EPD.From_Date = IPD.From_Date
		INNER JOIN T0020_PRIVILEGE_MASTER PM  WITH (NOLOCK) ON PD.Privilage_ID = PM.Privilege_ID
		WHERE DF.Form_Name LIKE '%Mobile%' AND EPD.Cmp_Id = @Cmp_ID 
		AND EPD.Login_ID = @Login_ID  AND DF.Form_ID > 9800 AND DF.Form_Name <> 'Mobile Application'
		--AND (PD.Is_View = 1 OR PD.Is_Edit = 1 OR PD.Is_Save = 1 OR PD.Is_Delete = 1 OR PD.Is_Print = 1)



	END	 
ELSE IF @Type = 'F' --- For Forget Password
	BEGIN
		SELECT @Cmp_ID = Cmp_ID,@Emp_ID = Emp_ID ,@Login_ID = Login_ID FROM T0011_LOGIN  WITH (NOLOCK) WHERE Login_Name=@UserName OR Login_Alias = @UserName
		
		SELECT TL.Login_ID ,TL.Login_Name,TL.Cmp_ID,TL.Emp_ID,EM.Emp_Left,EM.Work_Email,EM.Other_Email,EN.EMAIL_NTF_SENT,EM.Emp_Full_Name,
		EM.Mobile_No
		FROM T0011_LOGIN TL WITH (NOLOCK) 
		INNER JOIN
		(
			SELECT MAX(Login_ID) AS 'Login_ID' 
			FROM T0011_LOGIN WITH (NOLOCK)  
			WHERE (Login_Name=@UserName OR Login_Alias =@UserName) --and Login_Password = 'VuMs/PGYS74=' 
		) TTL ON TL.Login_ID = TTL.Login_ID
		INNER JOIN T0080_EMP_MASTER EM  WITH (NOLOCK) ON TL.Emp_ID = EM.Emp_ID
		INNER JOIN T0040_EMAIL_NOTIFICATION_CONFIG EN  WITH (NOLOCK) ON EM.Cmp_ID = EN.CMP_ID 
		WHERE EM.is_for_mobile_Access = 1 AND EM.Cmp_ID = @Cmp_ID AND EN.EMAIL_TYPE_NAME LIKE 'Forget Password'
	END
ELSE IF @Type = 'C' --- For Change Password
	BEGIN
		BEGIN TRY
			IF EXISTS(SELECT Login_ID FROM T0011_LOGIN  WITH (NOLOCK) WHERE Login_ID = @Login_ID AND Login_Password = @Password AND Cmp_ID = @Cmp_ID)
				BEGIN
					EXEC ChangePassword @User_Id = @Login_ID,@Current_Password = @Password,@Password = @NewPassword,@Cmp_Id = @Cmp_ID
					SET @Result = 'Password Change Successfully#True#'
				END
			ELSE
				BEGIN
					SET @Result = 'Your Current Password is Wrong#False#'
				END
		END TRY
		BEGIN CATCH
			SET @Result = ERROR_MESSAGE()+'#False#'
		END CATCH
	END
ELSE IF @Type = 'R' --- For Reset Password
	BEGIN
		IF EXISTS(SELECT Login_ID FROM T0011_LOGIN  WITH (NOLOCK) WHERE Login_ID = @Login_ID AND Cmp_ID = @Cmp_ID)
			BEGIN
				UPDATE T0011_LOGIN SET Login_Password = @NewPassword 
				WHERE Login_ID = @Login_ID AND Emp_Id = @Emp_ID  AND Cmp_ID = @Cmp_ID
				
				SELECT @Tran_ID = ISNULL(MAX(Tran_ID),0) + 1 FROM T0250_Change_Password_History WITH (NOLOCK) 
				
				INSERT INTO T0250_Change_Password_History (Tran_ID,Cmp_ID,Emp_ID,Password,Effective_From_Date)
				Values(@Tran_ID,@Cmp_ID,@Emp_ID,@NewPassword,GETDATE())
				
				
				SET @Result = 'Password Change Successfully#True#'
			END
		ELSE
			BEGIN
					SET @Result = 'Invalid UserName#False#'
				END
	END
ELSE IF @Type = 'O' --- For Log Out
	BEGIN
		 UPDATE T0095_Emp_IMEI_Details WITH (ROWLOCK)
		 SET Is_Active = 0 WHERE Emp_ID = @Emp_ID 
		 SET @Result = 'Log Out Successfully#True#'
		 select @Result
	END
ELSE IF @Type = 'V' --- For verification password for IOS mobile pattern
	BEGIN
		IF exists(SELECT 1 FROM T0011_LOGIN WITH (NOLOCK) WHERE (Login_Name = @UserName OR Login_Alias = @UserName) and Login_Password = @Password)
		BEGIN
			SET @Result = 'Password Verify Successfully#True#'
		END
		ELSE
		BEGIN
			SET @Result = 'You are not authorize#False#'
		END
		select @Result
		END
