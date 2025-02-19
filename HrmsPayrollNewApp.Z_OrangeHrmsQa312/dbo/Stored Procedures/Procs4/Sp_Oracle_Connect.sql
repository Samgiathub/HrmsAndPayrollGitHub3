



-- =============================================
-- Author:		Nikunj Nandaniya 
-- ALTER date: 18-Feb-2011
-- Description:	For Ruchi to Connect Oracle databse
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Sp_Oracle_Connect]
	@Cmp_Id As Numeric(18,0)	
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @Max_For_Date As DateTime
	Declare @Enroll_No_Cur As Numeric(18,0)
	Declare @CARDNO As Varchar(50)
	Declare @ADATETIME As DateTime
	Declare @CTRLNAME As Varchar(50)
	Declare @Str_query As Varchar(300)

---Commented By Hardik for take Max date Employee wise on 25/07/2011
	 
/*		 Select @Max_For_Date=ISNULL(Max(IO_DateTime),'1-Jan-2011') From dbo.T9999_DEVICE_INOUT_DETAIL  Where Cmp_Id=@Cmp_Id
			--Set @Max_For_Date='1-Jan-2011'
		Declare SysOracle_Cursor Cursor LOCAL  For
			Select IsNULL(Enroll_No,0) As Enroll_No From dbo.T0080_Emp_Master Where cmp_Id=@Cmp_Id And Enroll_No <> 0
		Open SysOracle_Cursor
		Fetch Next From SysOracle_Cursor Into @Enroll_No_Cur
		While @@Fetch_Status = 0                    
		Begin   				
			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')'
			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM In_Out_Records1 Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + 'And ADATETIME >=' + Convert(Varchar(11),@Max_For_Date,106) + ''')'

			Set	@Str_query = 'Insert Into dbo.T9999_DEVICE_INOUT_DETAIL SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName,NULL FROM OPENROWSET(''MSDAORA'',''diamond''; ''smarti''; ''attendance'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')'

			--SELECT *
			--FROM OPENROWSET('MSDAORA','diamond'; 'smarti'; 'attendance', 'SELECT CARDNO,ADATETIME,CTRLName FROM transactions Where to_char(ADATETIMe,''mm'')=2 And to_char(Adatetime,''YYYY'')=2011 And to_char(Adatetime,''DD'')=18')

			--Select @Str_query
			exec(@Str_query)
			
			Fetch Next From SysOracle_Cursor Into @Enroll_No_Cur
		End				
		Close SysOracle_Cursor
		Deallocate SysOracle_Cursor
*/

		Declare SysOracle_Cursor Cursor LOCAL  For
			Select  IsNULL(Enroll_No,0)As Enroll_No ,Cmp_Id  From dbo.T0080_Emp_Master WITH (NOLOCK) Where Enroll_No <> 0
		Open SysOracle_Cursor
		Fetch Next From SysOracle_Cursor Into @Enroll_No_Cur, @Cmp_Id
		While @@Fetch_Status = 0                    
		Begin   				
			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')'
			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM In_Out_Records1 Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + 'And ADATETIME >=' + Convert(Varchar(11),@Max_For_Date,106) + ''')'

			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM In_Out_Records1 Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + 'And ADATETIME >=' + Convert(Varchar(11),@Max_For_Date,106) + ''')'
			--Set	@Str_query = 'Insert Into dbo.Table_Test SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName FROM OPENROWSET(''MSDAORA'',''Mitsumi''; ''mitsumi''; ''orange505'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')'

			Select @Max_For_Date=ISNULL(Max(IO_DateTime),'1-aug-2011') From dbo.T9999_DEVICE_INOUT_DETAIL WITH (NOLOCK)  Where Enroll_No = @Enroll_No_Cur
			--Set	@Str_query = 'Insert Into dbo.T9999_DEVICE_INOUT_DETAIL SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName,NULL FROM OPENROWSET(''MSDAORA'',''diamond''; ''smarti''; ''attendance'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')'
			Set	@Str_query = 'Insert Into dbo.T9999_DEVICE_INOUT_DETAIL SELECT '+ Cast(@Cmp_Id As Varchar(50) ) +' ,CARDNO,ADATETIME,CTRLName,NULL FROM OPENROWSET(''MSDAORA'',''diamond''; ''smarti''; ''attendance'', ''SELECT CARDNO,ADATETIME,CTRLName FROM Transactions Where CARDNO =' + Cast(@Enroll_No_Cur as Varchar(50))  + ' And ADATETIME >=''''' + Convert(Varchar(11),@Max_For_Date,106) + ''''''')Where adatetime >''' + convert(varchar(45),@Max_For_Date,113) + ''''

			--SELECT *
			--FROM OPENROWSET('MSDAORA','diamond'; 'smarti'; 'attendance', 'SELECT CARDNO,ADATETIME,CTRLName FROM transactions Where to_char(ADATETIMe,''mm'')=8 And to_char(Adatetime,''YYYY'')=2011 And to_char(Adatetime,''DD'')=17'  )

			--declare @spid numeric
			--Select @spid=@@SPID
			--Select @Str_query
			
			exec(@Str_query)
			
			Fetch Next From SysOracle_Cursor Into @Enroll_No_Cur, @Cmp_Id
		End				
		Close SysOracle_Cursor
		Deallocate SysOracle_Cursor

END


RETURN




