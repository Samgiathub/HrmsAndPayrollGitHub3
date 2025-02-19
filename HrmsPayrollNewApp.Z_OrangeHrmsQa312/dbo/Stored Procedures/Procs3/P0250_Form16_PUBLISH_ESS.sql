

-- =============================================
-- Author:		<Author,,Jimit>
-- Create date: <Create Date,,20112018>
-- Description:	<Description,,For Inserting Publish Form 16 Record>
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0250_Form16_PUBLISH_ESS]
	 @Publish_ID		numeric output
	,@Cmp_Id			numeric(18,0)	
	,@Financial_Year	Varchar(10)
	,@Is_Publish		tinyint	
	,@Emp_ID			numeric(18,0)
	,@Comments			varchar(max) = ''
	
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

			if exists (select 1 from T0250_Form16_Publish_ESS WITH (NOLOCK) where Financial_Year = @Financial_Year and Cmp_ID = @Cmp_Id and Emp_ID = @Emp_ID)
				begin							
					UPDATE   T0250_Form16_Publish_ESS
					SET		 Is_Publish = @Is_Publish, System_Date = GETDATE(),Comments = @Comments
					where	 Financial_Year = @Financial_Year and Cmp_ID = @Cmp_Id  and Emp_Id = @Emp_ID 
				end
			else
			begin
					select @Publish_ID = Isnull(max(Publish_ID),0) + 1 	From T0250_Form16_Publish_ESS WITH (NOLOCK)	
					
					INSERT INTO T0250_Form16_Publish_ESS
								(Publish_ID, Cmp_ID, Emp_ID,Financial_Year, Is_Publish,  System_Date,Comments)
					VALUES		(@Publish_ID,@Cmp_ID,@Emp_ID,@Financial_Year,@Is_Publish,GETDATE(),@Comments)						
			end

	RETURN

