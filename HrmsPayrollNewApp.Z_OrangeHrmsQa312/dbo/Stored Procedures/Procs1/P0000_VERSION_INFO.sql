


-- =============================================
-- Author     :	Alpesh
-- ALTER date: 15-Jun-2012
-- Description:	For Version Info
-- =============================================
CREATE PROCEDURE [dbo].[P0000_VERSION_INFO]

 @Version_Id		numeric(18, 0)
,@Version_No		nvarchar(20)
--,@Last_Update		datetime
,@Database_Name		nvarchar(50)
,@Server_Name		nvarchar(50)

AS

        SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

	If exists(Select 1 from T0000_VERSION_INFO WITH (NOLOCK) where Version_No=@Version_No)
		begin
			Update T0000_VERSION_INFO Set
				 Last_Update=GETDATE()
				,Database_Name=@Database_Name
				,Server_Name=@Server_Name
			Where Version_No=@Version_No
		end
	Else
		begin
			Select @Version_Id=isnull(max(Version_Id),0)+1 from T0000_VERSION_INFO WITH (NOLOCK)
			
			Insert Into T0000_VERSION_INFO Values(@Version_Id,@Version_No,GETDATE(),@Database_Name,@Server_Name)
		end
    
END


