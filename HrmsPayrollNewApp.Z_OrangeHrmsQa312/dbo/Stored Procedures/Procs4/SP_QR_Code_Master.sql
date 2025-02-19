CREATE PROCEDURE [dbo].[SP_QR_Code_Master]
	@QR_Code_ID uniqueidentifier = null,
	@Cmp_ID int = null,
	@Branch_ID int = null,
	@Department_ID int = null,
	@IO_Flag bit = null,
	@POS_ID int = null,
	@Latitude nvarchar(100) = null,
	@Longitude nvarchar(100) = null,
	@Meters int = null,
	@Is_Active bit = null,
	@Type int -- CRUD pattern code
AS
BEGIN
	SET NOCOUNT ON;
	
	IF @Type = 0 -- To Create QR Code
		Begin
			INSERT into QR_Code_Master
			(QR_Code_ID, Cmp_ID, Branch_ID, Department_ID, IO_Flag, POS_ID, Latitude, Longitude, Meters, Is_Active)
			VALUES
			(@QR_Code_ID, @Cmp_ID, @Branch_ID, @Department_ID, @IO_Flag, @POS_ID, @Latitude, @Longitude, @Meters, @Is_Active)
			Select 1 as Result
		End

	ELSE IF @Type = 1 -- To Read QR Code
		Begin
			--SELECT * from QR_Code_Master
			--WHERE (@Cmp_ID = 0 OR Cmp_ID = @Cmp_ID)
			SELECT  QR.QR_Code_ID, QR.Cmp_ID, CMP.Cmp_Name, QR.Branch_ID, BR.Branch_Name,
			QR.Department_ID, DR.Dept_Name, QR.IO_Flag, QR.POS_ID, PM.POS_Name, QR.Latitude, QR.Longitude,
			QR.Meters, QR.Is_Active
			from QR_Code_Master QR
			LEFT OUTER JOIN T0010_COMPANY_MASTER CMP ON
			CMP.Cmp_Id = QR.Cmp_ID
			LEFT OUTER JOIN T0030_BRANCH_MASTER BR ON
			BR.Branch_ID = QR.Branch_ID
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DR ON
			DR.Dept_Id = QR.Department_ID
			LEFT OUTER JOIN POS_Master PM ON
			PM.POS_ID = QR.POS_ID
			WHERE (@Cmp_ID = 0 OR QR.Cmp_ID = @Cmp_ID)
		End

	ELSE IF @Type = 2 -- To Update QR Code
		Begin
			UPDATE QR_Code_Master
			SET Branch_ID = @Branch_ID,
			Department_ID = @Department_ID,
			IO_Flag = @IO_Flag,
			POS_ID = @POS_ID,
			Latitude = @Latitude,
			Longitude = @Longitude,
			Meters = @Meters,
			Is_Active = @Is_Active
			WHERE QR_Code_ID = @QR_Code_ID
		End

	ELSE IF @Type = 3 -- To Delete QR Code
		Begin
			DELETE FROM QR_Code_Master
			WHERE QR_Code_ID = @QR_Code_ID
		End
	ELSE IF @Type = 4 -- To Get Single QR Code
		Begin
			SELECT  QR.QR_Code_ID, QR.Cmp_ID, CMP.Cmp_Name, QR.Branch_ID, BR.Branch_Name,
			QR.Department_ID, DR.Dept_Name, QR.IO_Flag, QR.POS_ID, PM.POS_Name, QR.Latitude, QR.Longitude,
			QR.Meters, QR.Is_Active
			from QR_Code_Master QR
			LEFT OUTER JOIN T0010_COMPANY_MASTER CMP ON
			CMP.Cmp_Id = QR.Cmp_ID
			LEFT OUTER JOIN T0030_BRANCH_MASTER BR ON
			BR.Branch_ID = QR.Branch_ID
			LEFT OUTER JOIN T0040_DEPARTMENT_MASTER DR ON
			DR.Dept_Id = QR.Department_ID
			LEFT OUTER JOIN POS_Master PM ON
			PM.POS_ID = QR.POS_ID
			WHERE QR_Code_ID = @QR_Code_ID
		End
END
