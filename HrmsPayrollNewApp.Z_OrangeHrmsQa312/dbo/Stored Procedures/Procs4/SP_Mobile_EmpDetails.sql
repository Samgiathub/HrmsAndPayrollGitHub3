

CREATE PROCEDURE [dbo].[SP_Mobile_EmpDetails]
	@Emp_ID numeric(18,0) OUTPUT,
	@Cmp_ID numeric(18,0),
	@Address Varchar(Max),
	@City Varchar(50),
	@State Varchar(50),
	@Pincode varchar(50),
	@PhoneNo varchar(50),
	@MobileNo varchar(50),
	@Email varchar(50),
	@Type char(1)
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

IF @Type = 'U'
	BEGIN
		IF @State LIKE '%Select State%'
			BEGIN
				SET @State = ''
			END
		UPDATE T0080_EMP_MASTER SET Street_1 = @Address,City =@City,State = @State,Zip_code = @Pincode,
		Home_Tel_no = @PhoneNo,Mobile_No = @MobileNo,Other_Email = @Email
		WHERE Emp_ID = @Emp_ID
	END
ELSE IF @Type = 'E'
	BEGIN
		--SELECT Emp_ID,Emp_code,Street_1,isnull(City,'') as 'City',isnull(State,'') as 'State',Zip_code,Home_Tel_no,Mobile_No,Other_Email,
		--Emp_Second_Name,CONVERT(varchar(11),Date_Of_Birth,103) AS 'DOB',CONVERT(varchar(11),Date_Of_Join,103) AS 'DOJ',
		
		--FROM T0080_EMP_MASTER
		--WHERE Emp_ID = @Emp_ID AND Cmp_ID = @Cmp_ID
		
		SELECT EM.Emp_ID,EM.Emp_code,EM.Street_1,ISNULL(EM.City,'') AS 'City',ISNULL(EM.State,'') AS 'State',EM.Zip_code,
		EM.Home_Tel_no,EM.Mobile_No,EM.Other_Email,EM.Father_name,CONVERT(varchar(11),EM.Date_Of_Join,103) AS 'DOJ',
		CONVERT(varchar(11),EM.Date_Of_Birth,103) AS 'DOB',IC.Bank_ID,BM.Bank_Name,EM.Ifsc_Code,IC.Inc_Bank_AC_No AS 'AccountNo',
		EM.SIN_No AS 'ESIC_No',EM.Pan_No,EM.UAN_No,EM.Aadhar_Card_No,EM.DBRD_Code as 'SBUCode',convert(nvarchar(20),Em.Emp_Left_Date,103) as Emp_Left_Date
		FROM T0080_EMP_MASTER EM WITH (NOLOCK)
		INNER JOIN T0095_INCREMENT IC WITH (NOLOCK) ON EM.Emp_ID = IC.Emp_ID
		INNER JOIN
		(
			SELECT TIC.Increment_ID,TIC.Increment_Date
			FROM T0095_INCREMENT TIC WITH (NOLOCK)
			INNER JOIN
			(
				SELECT MAX(Increment_Date) AS 'Increment_Date',Emp_ID
				FROM T0095_INCREMENT WITH (NOLOCK)
				GROUP BY Emp_ID
			)IIC ON TIC.Increment_Date = IIC.Increment_Date AND TIC.Emp_ID = IIC.Emp_ID
		) INC ON IC.Increment_ID = INC.Increment_ID
		INNER JOIN T0040_BANK_MASTER BM WITH (NOLOCK) ON IC.Bank_ID = BM.Bank_ID

		WHERE EM.Emp_ID = @Emp_ID AND EM.Cmp_ID = @Cmp_ID
	END

