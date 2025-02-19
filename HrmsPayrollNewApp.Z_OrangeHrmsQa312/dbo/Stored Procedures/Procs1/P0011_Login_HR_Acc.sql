


-- =============================================
-- Author:		Mihir Trivedi
-- ALTER date: 26/03/2012
-- Description:	This SP used to update HR and Account detail from Employee Privilege master
---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0011_Login_HR_Acc]
	@Login_ID numeric(18,0) output
   ,@Cmp_ID numeric(18,0)     
   ,@IS_HR tinyint = 0
   ,@Is_Accou tinyint =0
   ,@Email_ID varchar(60)=''
   ,@A_Email_ID varchar(60)='' 
   ,@trans_type char(1)  
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

		
	If @trans_type = 'U'
	    begin
	       if @IS_HR <> 0 
	        UPDATE dbo.T0011_LOGIN set Is_HR = 0, Email_ID = ''  where Login_ID <> @Login_ID And Cmp_Id = @Cmp_Id --, Email_ID = '', Email_ID_Accou = ''
	       if @Is_Accou <> 0
	        UPDATE dbo.T0011_LOGIN set Is_Accou = 0, Email_ID_Accou = ''  where Login_ID <> @Login_ID And Cmp_Id = @Cmp_Id
	    end
		begin			
			UPDATE    dbo.T0011_LOGIN
			SET        IS_HR = @IS_HR
					  ,Is_Accou = @Is_Accou
					  ,Email_ID = @Email_ID
					  ,Email_ID_Accou = @A_Email_ID
			WHERE      Login_ID = @Login_ID And Cmp_Id = @Cmp_Id
		end	
	RETURN


