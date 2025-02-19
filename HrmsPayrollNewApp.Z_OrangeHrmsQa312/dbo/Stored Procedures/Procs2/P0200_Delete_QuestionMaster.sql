



-- =============================================
-- Author:		Sneha
-- ALTER date: march 2012
-- Description:	<Description,,>
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0200_Delete_QuestionMaster]
	@cmp_id as numeric(18,0),
	@Question_Id as numeric(18,0)
   ,@User_Id numeric(18,0) = 0
   ,@IP_Address varchar(30)= '' --Add By Paras 12-10-2012

AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


declare @OldValue as  varchar(max)
declare @ValueData as varchar(max)
declare @OldQuestion as varchar(150)
declare @OldDescription as varchar(100)
declare @OldIsActive as varchar(1)

set @OldValue = ''
set @ValueData =''
set @OldValue = ''
set @OldQuestion = ''
set @OldDescription = ''
set @OldIsActive = 0

BEGIN
	
	SET NOCOUNT ON;
	If @cmp_id<>0
		Begin
		
			 select @OldQuestion  = Question ,@OldDescription  =[Description],@OldIsActive  =isnull(Is_Active,0)  
			 From dbo.T0200_Question_Master WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and Question_Id = @Question_Id --Mukti 28052015 condition added- Question_Id = @Question_Id
		       
			 Delete From T0200_Question_Master Where Cmp_Id = @cmp_id and Question_Id = @Question_Id
			 set @OldValue = 'old Value' + '#'+ 'Question :' + @OldQuestion  + '#' + 'Discription :' + @OldDescription  + '#' + 'Is Active :' + CAST(ISNULL(@OldIsActive,'')as varchar(1)) 
		 
		End
					
		exec P9999_Audit_Trail @Cmp_ID,'D','Question Master',@OldValue,@Question_Id,@User_Id,@IP_Address
   
END



