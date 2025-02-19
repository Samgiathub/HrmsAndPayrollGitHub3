
---13/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0081_CUSTOMIZED_COLUMN]
	@Tran_Id numeric(18,0) output
   ,@Cmp_ID numeric(18,0)
   ,@Column_Name varchar(50)
   ,@Table_Name varchar(60)
   ,@Active tinyint 
   ,@trans_type char
   ,@Ess_Editable tinyint = 0 --Added by Jaina 21-04-2018
   ,@Ess_Visible tinyint = 0 --Added by Jaina 21-04-2018
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	If @trans_type = 'I'
	begin
			IF EXISTS(SELECT Tran_Id from dbo.T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) where Column_Name = @Column_Name and Cmp_Id=@Cmp_ID  and Tran_Id <> @Tran_Id)
				begin
					set @Tran_Id = 0
					REturn 
				end
			 INSERT INTO dbo.T0081_CUSTOMIZED_COLUMN
								   ( Cmp_ID, Column_Name , Table_Name,active,Ess_Editable,Ess_Visible)
			 VALUES     (@Cmp_ID ,@Column_Name,@Table_Name ,@Active,@Ess_Editable,@Ess_Visible)
		end
	Else If @trans_type = 'U'
		begin
			IF EXISTS(SELECT Tran_Id from dbo.T0081_CUSTOMIZED_COLUMN WITH (NOLOCK) where Column_Name = @Column_Name and Cmp_Id=@Cmp_ID  and Tran_Id <> @Tran_Id)
				begin
					set @Tran_Id = 0
					REturn 
				end
			UPDATE    dbo.T0081_CUSTOMIZED_COLUMN
			SET       Column_Name = @Column_Name
					  ,Table_Name = @Table_Name
					  ,active=@active
					  ,Ess_Editable = @Ess_Editable
					  ,Ess_Visible = @Ess_Visible
		WHERE      Tran_Id  = @Tran_Id And Cmp_Id=@Cmp_Id
		end
	Else If @trans_type = 'D'
		begin
		if exists(select 1 from T0082_Emp_Column WITH (NOLOCK) where mst_Tran_Id =@Tran_Id and cmp_Id=@Cmp_ID)
		begin 
			RAISERROR('@@Reference Exist You Can not Delete.@@',16,2)
			RETURN -1
		end
		else
		begin
			DELETE FROM dbo.T0081_CUSTOMIZED_COLUMN WHERE tran_id=@Tran_Id And Cmp_Id=@Cmp_Id
		end
		end
	RETURN




