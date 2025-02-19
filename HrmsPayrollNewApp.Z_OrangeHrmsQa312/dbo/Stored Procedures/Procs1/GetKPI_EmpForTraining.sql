


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec GetKPI_EmpForTraining 9,2015
---29/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GetKPI_EmpForTraining]
	 @cmp_id as numeric(18,0)
	, @finyear as int  
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
declare @UserNames NVARCHAR(MAX)
DECLARE @DELIMITER NCHAR(1)  
DECLARE @tmpUserNames NVARCHAR(MAX)
Declare @cnt  int
set @cnt = 0

SET @UserNames =''

SET @DELIMITER = '#'     
DECLARE @commaIndex INT    
DECLARE @singleUserName NVARCHAR(MAX)

create table #SampleUserTable
(
	 UserName  varchar(50)
	,Employeecnt int
)

SELECT @commaIndex = 1  

declare cur  cursor 
for 
	select  Final_Training
	 from T0080_KPIPMS_EVAL WITH (NOLOCK)
	 where Cmp_ID=@cmp_id  and KPIPMS_FinancialYr = (@finyear)-1 
	and KPIPMS_Status = 7 and KPIPMS_Type =2
open cur
fetch next from cur into @UserNames
	while @@FETCH_STATUS = 0
	Begin
	SET @tmpUserNames = @UserNames
				 
IF LEN(@tmpUserNames)<1 OR @tmpUserNames IS NULL  RETURN    
WHILE @commaIndex!= 0    
BEGIN    
      SET @commaIndex= CHARINDEX(@DELIMITER,@tmpUserNames)    
      IF @commaIndex!=0    
            SET @singleUserName= LEFT(@tmpUserNames,@commaIndex - 1)    
      ELSE    
            SET @singleUserName = @tmpUserNames    
      
      IF(LEN(@singleUserName)>0)      
		  BEGIN  
				IF NOT Exists (select 1 from #SampleUserTable where UserName = @singleUserName  )   
					begin               
						set @cnt = 1    
						INSERT INTO #SampleUserTable
						(
							  UserName
							 ,Employeecnt
						)
						VALUES
						(
							  @singleUserName
							  ,@cnt
						)
					end
				Else
					begin
						Update #SampleUserTable set Employeecnt = Employeecnt + 1 where UserName =  @singleUserName
					End
		  END
      SET @tmpUserNames = RIGHT(@tmpUserNames,LEN(@tmpUserNames) - @commaIndex)    
      IF LEN(@tmpUserNames) = 0 BREAK    
END
	fetch next from cur into @UserNames

	End
close cur
deallocate cur 

select s.* ,t.Training_name
from #SampleUserTable s left join T0040_Hrms_Training_master t WITH (NOLOCK)
on t.Training_id = s.UserName 

drop table #SampleUserTable
END


