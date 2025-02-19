
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_SAP_LEAVE]
	  @Cmp_Id	numeric output	 
	 ,@To_Date  datetime
	 ,@Flag Char = 'C'
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @from_date as datetime
set @from_date = dbo.GET_MONTH_ST_DATE(MONTH(@To_Date),YEAR(@To_Date))
 
 select Em.Alpha_Emp_Code as 'E-CODE',
  '="' + REPLACE(CONVERT(VARCHAR(10), Lt.For_Date, 103), '/', '') + '"' as 'FROM',
 '="' + REPLACE(CONVERT(VARCHAR(10), Lt.For_Date, 103), '/', '')   + '"'   as 'TO',
 LM.Leave_Code as 'LEAVE CODE'
 
 from T0140_LEAVE_TRANSACTION LT WITH (NOLOCK)
 inner join T0040_LEAVE_MASTER LM WITH (NOLOCK) on LT.Leave_ID = LM.Leave_ID
 inner join T0080_EMP_MASTER EM WITH (NOLOCK) on Lt.Emp_ID = Em.Emp_ID
 where lt.Cmp_Id = @Cmp_Id and For_Date>=@from_date and For_Date<=@To_Date
 and upper(LM.Default_Short_Name) <> 'COMP' and upper(LM.Default_Short_Name) <> 'LWP'
 and lt.Leave_Used >= 1
 	

RETURN
