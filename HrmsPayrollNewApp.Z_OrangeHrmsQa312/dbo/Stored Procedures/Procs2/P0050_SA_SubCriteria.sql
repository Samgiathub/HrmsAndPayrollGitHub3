

CREATE PROCEDURE [dbo].[P0050_SA_SubCriteria]
	 @SAppCriteria_ID		numeric(18,0) out
	,@Cmp_ID				numeric(18,0)
	,@SApparisal_ID			numeric(18,0)
	,@SAppCriteria_Content	varchar(200)
	,@tran_type				varchar(1)	
	,@User_Id				numeric(18,0) = 0
	,@IP_Address			varchar(30)= ''
AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN	
	If Upper(@tran_type) ='I'
		begin
			if @SApparisal_ID =0
				begin
					select @SApparisal_ID = ISNULL(MAX(SApparisal_ID),0) from T0040_SelfAppraisal_Master WITH (NOLOCK) 
				end
			
			select @SAppCriteria_ID = isnull(max(SAppCriteria_ID),0) + 1 from T0050_SA_SubCriteria WITH (NOLOCK)
			Insert into T0050_SA_SubCriteria
			(
				 SAppCriteria_ID
				,Cmp_ID
				,SApparisal_ID
				,SAppCriteria_Content
			)
			values
			(
				@SAppCriteria_ID
			   ,@Cmp_ID
			   ,@SApparisal_ID
			   ,@SAppCriteria_Content
			)
		End
	Else If  Upper(@tran_type) ='U' 
		begin
			Update	T0050_SA_SubCriteria
			Set		SAppCriteria_Content	=	@SAppCriteria_Content
			Where   SAppCriteria_ID			= @SAppCriteria_ID
		end
	Else If  Upper(@tran_type) ='D'
		begin
			Delete from T0050_SA_SubCriteria where  SAppCriteria_ID			= @SAppCriteria_ID
		end
END

