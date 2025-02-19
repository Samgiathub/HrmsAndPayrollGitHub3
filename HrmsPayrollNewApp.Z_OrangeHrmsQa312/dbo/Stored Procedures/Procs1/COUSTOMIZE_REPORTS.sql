




---------------------------------------------------------
--Created By Girish on 12-june-2010 for Dynamic reports--
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
--------------------------------------------------------- 
CREATE PROCEDURE [dbo].[COUSTOMIZE_REPORTS]
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

Declare @Count as numeric  
Set @Count = 0
Delete from TABLE_CUSTOMIZE_REPORTS   
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'--Select All--')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'COMPANY NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'EMP CODE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'FULL NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'INITIAL NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'FIRST NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'SECOND NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'LAST NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'ENROLL NO')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DATE OF JOIN')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'BASIC SALARY')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'GROSS SALARY')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DATE OF CONFIRMATION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'BRANCH')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'SHIFT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DEPARTMENT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DESIGNATION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'GENDER')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'STATUS')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'MARITAL STATUS')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'GRADE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DATE OF BIRTH')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'MANAGER NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'EMP LEFT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'OT APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'LATE MARK APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PT APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'FULL PF APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'FIX SALARY APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'GRATUITY APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'YEARLY BONUS APPLICABLE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'ON PROBATION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PROBATION PERIOD')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PT AMOUNT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'MOBILE NO')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORKING ADDRESS')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORKING TOWN')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORKING REGION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORKING POSTBOX')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'LEFT DATE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'HOME TELEPHONE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PERSONAL EMAIL')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORK TELEPHONE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WORKING EMAIL')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PERMANENT ADDRESS')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PERMANENT REGION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PERMANENT TOWN')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PERMANENT POSTBOX')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'NATIONALITY')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DRIVING LICENSE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DRIVING LICENSE EXPIRY')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PAN NO')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'ESIC NO')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PF NO')

--set @Count  = @Count + 1  
--insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'P OTHER MAIL')

set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'IMAGE NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'YEARLY BONUS AMOUNT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'YEARLY BONUS PERCENTAGE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'BANK ACOUNT NO')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'PAYMENT MODE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'SALARY BASIS ON')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'WAGES TYPE')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'BLOOD GROUP')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'RELIGION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'HEIGHT')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'MARK OF IDENTIFICATION')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DESPENCERY')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DOCTOR NAME')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'DESPENCERY ADDRESS')
set @Count  = @Count + 1  
insert into TABLE_CUSTOMIZE_REPORTS values (@Count,'INSURANCE NO')

RETURN




