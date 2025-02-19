


-- =============================================
-- Author:		MUKTI 
-- ALTER date: 07-01-2020
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[P0090_HRMS_EMP_LANGUAGE_DETAIL]
		 @Tran_ID		numeric(18,0) output
		,@Cmp_id		numeric(18,0)
	    ,@Resume_ID		numeric(18,0)
	    ,@Lang_ID   varchar(50)
	    ,@Is_Read    varchar(10)
	    ,@Is_Write   varchar(10)
	    ,@Is_Speak    varchar(10)	 
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN	
	 if Not exists(Select Tran_ID from T0090_HRMS_EMP_LANGUAGE_DETAIL WITH (NOLOCK) where  Lang_ID=@Lang_ID AND RESUME_ID=@RESUME_ID)
		BEGIN
			select @Tran_ID =isnull(max(Tran_ID),0) + 1 from T0090_HRMS_EMP_LANGUAGE_DETAIL WITH (NOLOCK)
			
			Insert into T0090_HRMS_EMP_LANGUAGE_DETAIL (
							Tran_ID,
							Cmp_id ,
							Resume_ID ,
							Lang_ID  ,
							Is_Read,
							Is_Write,
							Is_Speak						
						)
				values	(
							@Tran_ID,
							@Cmp_id ,
							@Resume_ID ,
							@Lang_ID  ,
							@Is_Read,
							@Is_Write,
							@Is_Speak					
						 )
				END
					
END


