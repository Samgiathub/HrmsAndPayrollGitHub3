CREATE Procedure [dbo].[SP_Mittsure_API_Sync]
as
Begin
	
	BEGIN TRY
		DROP TABLE IF EXISTS ##TBL_ConvertJSONToTable;

		CREATE TABLE ##TBL_ConvertJSONToTable(
			EmployeeId int not null,
			Start_Date_In varchar(200),
			End_Date_Out varchar(200)
		)

		INSERT INTO ##TBL_ConvertJSONToTable (
			EmployeeId,
			Start_Date_In,
			End_Date_Out
		)
		SELECT Emp_ID, Start_date_time, End_date_time
		FROM
		Mittsure_Json_Master

		--Select * From ##TBL_ConvertJSONToTable

		Declare @MaxNo numeric(18,0)
		select @MaxNo= isnull(MAX(IO_Tran_ID),0) from dbo.T9999_DEVICE_INOUT_DETAIL


   		insert into dbo.T9999_DEVICE_INOUT_DETAIL
		select @MaxNo + ROW_NUMBER() OVER (ORDER BY EmpCode) AS IO_TranID, API_Data.Cmp_ID,
		API_Data.EmpCode, API_Data.[Datetime], API_Data.[IP], API_Data.Flag, API_Data.IsVerify 
		from  
		(  
			SELECT 1 as Cmp_ID
			 ,TRY_CAST(EmployeeId as NUMERIC(18,0)) as EmpCode
			, CAST(CONVERT(DATETIME, Start_Date_In, 103) as Datetime) as [Datetime]
			, 'Mittsure_RestAPI' as [IP]
			, '0' as Flag
			, 0 as IsVerify
			From ##TBL_ConvertJSONToTable
			where ISNUMERIC(EmployeeId) = 1 AND
			ISNULL(Start_Date_In, '') <> '' AND ISNULL(Start_Date_In, '') <> ''

			UNION ALL

			SELECT 1 as Cmp_ID
			,TRY_CAST(EmployeeId as NUMERIC(18,0)) as EmpCode
			,CAST(CONVERT(DATETIME, End_Date_Out, 103) as Datetime) as [Datetime]
			,'Mittsure_RestAPI' as [IP]
			,'1' as Flag,
			0 as IsVerify
			From ##TBL_ConvertJSONToTable
			where ISNUMERIC(EmployeeId) = 1 AND
			ISNULL(End_Date_Out, '') <> '' AND ISNULL(End_Date_Out, '') <> ''

		)as API_Data 
		left join(select Enroll_No as Enroll_No, IO_DateTime as MaxDate
		from dbo.T9999_DEVICE_INOUT_DETAIL) as InOut
		on API_Data.EmpCode = InOut.Enroll_No and API_Data.[Datetime] = MaxDate
		inner join T0080_EMP_MASTER WITH (NOLOCK)
		on API_Data.EmpCode = T0080_EMP_MASTER.Enroll_No
		where isnull(InOut.Enroll_No,0) = 0 AND
		API_Data.[Datetime] <= CONVERT(DATETIME, GETDATE(), 103)

		--EXEC (@SQL)
		exec SP_EMP_INOUT_SYNCHRONIZATION_AUTO 1

	END TRY  
	BEGIN CATCH  
		SELECT  
			ERROR_NUMBER() AS ErrorNumber  
			,ERROR_SEVERITY() AS ErrorSeverity  
			,ERROR_STATE() AS ErrorState
			,ERROR_LINE () AS ErrorLine 
			,ERROR_PROCEDURE() AS ErrorProcedure  
			,ERROR_MESSAGE() AS ErrorMessage;  
	END CATCH
End