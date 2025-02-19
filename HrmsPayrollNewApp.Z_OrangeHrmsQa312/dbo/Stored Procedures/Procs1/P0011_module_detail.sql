
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_module_detail]
@module_ID	numeric(18,0),
@module_name varchar(50),
@Cmp_id	numeric(18,0),
@module_status int 

AS 
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	If Exists(Select module_ID From T0011_module_detail WITH (NOLOCK) Where Cmp_ID = @Cmp_ID and upper(module_name) = upper(@module_name))
		begin 
			set @module_ID = 0 
			Return 
		end 
			select @module_ID = Isnull(max(module_ID),0) + 1 From T0011_module_detail WITH (NOLOCK)
			INSERT INTO T0011_module_detail(module_ID,module_name,Cmp_id,module_status)
			VALUES(@module_ID,@module_name,@Cmp_id,@module_status)
			return




