

-- =============================================
-- Author:		<Jaina>
-- Create date: <05-06-2018>
-- Description:	<Description,,>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[P0040_Exit_Group_Master]
	@Group_Id numeric(18,0) output,
	@Cmp_id numeric(18,0),
	@Group_Name varchar(64),
	@Group_Sort_Id numeric(18,0),
	@Is_Active bit,
	@Grp_Rate_ID varchar(500),
	@Tran_type char(1)
	
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	
	
	
    if @Tran_type = 'I'
		begin
				IF exists (SELECT 1 from T0040_Exit_Group_Master WITH (NOLOCK) where Cmp_Id = @Cmp_Id AND Group_Name = @Group_Name)
				BEGIN
						RAISERROR('@@THIS GROUP ALREADY EXISTS@@', 16, 1)
						SET @Group_ID = 0
						RETURN
				END
				
				select @Group_Id = ISNULL(max(Group_Id),0)+ 1 from T0040_Exit_Group_Master WITH (NOLOCK)
				
				INSERT INTO T0040_Exit_Group_Master (Group_Id,Cmp_Id,Group_Name,Group_Sort_Id,Is_Active,Grp_Rate_Id,System_Date)
				VALUES (@Group_Id,@Cmp_id,@Group_Name,@Group_Sort_Id,@Is_Active,@Grp_Rate_Id,GETDATE())
		end
    else if @Tran_type = 'U'
		BEGIN
					
				IF exists (SELECT 1 from T0040_Exit_Group_Master WITH (NOLOCK) where Cmp_Id = @Cmp_Id AND Group_Name = @Group_Name AND Group_Id <> @Group_ID)
				BEGIN
						RAISERROR('@@THIS GROUP ALREADY EXISTS@@', 16, 1)
						SET @Group_ID = 0
						RETURN
				END
								
								
				IF EXISTS (SELECT 1 FROM T0040_Exit_Group_Master G WITH (NOLOCK) INNER JOIN
								T0200_Question_Exit_Analysis_Master Q WITH (NOLOCK) ON G.Group_Id = Q.Group_Id INNER JOIN
								T0200_Exit_Interview I WITH (NOLOCK) ON I.Question_Id = Q.Quest_ID
						WHERE G.Cmp_Id=@Cmp_Id and G.Group_Id = @Group_Id)
				BEGIN
					RAISERROR('@@Group is assigned for feedback, Can''t Updated@@', 16, 1)
					SET @Group_Id = 0
					RETURN
				END
			
				update T0040_Exit_Group_Master set
				Group_Name = @Group_Name,
				Group_Sort_Id = @Group_Sort_Id,
				Is_Active = @Is_Active,
				Grp_Rate_Id = @Grp_Rate_ID
				where Cmp_Id= @cmp_Id and Group_Id = @Group_Id
		end
	else IF @Tran_Type = 'D'
		begin
			
						
			IF exists (SELECT 1 FROM T0040_Exit_Group_Master G WITH (NOLOCK) INNER JOIN
								T0200_Question_Exit_Analysis_Master Q WITH (NOLOCK) ON G.Group_Id = Q.Group_Id
						WHERE G.Cmp_Id=@Cmp_Id and G.Group_Id = @Group_Id)
			BEGIN
				RAISERROR('@@Reference Exists, Can''t Deleted@@', 16, 1)
				SET @Group_Id = 0
				RETURN
			END
			delete FROM T0040_Exit_Group_Master where Cmp_Id=@Cmp_Id and Group_Id = @Group_Id
		End
END


