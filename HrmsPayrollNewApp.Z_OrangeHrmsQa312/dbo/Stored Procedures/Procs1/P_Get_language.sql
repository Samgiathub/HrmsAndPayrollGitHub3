



-- created by rohit on 07092016
---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P_Get_language] 
@Flag varchar(20)='en'
AS        
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

begin

select lower(name) as name, 
case when @Flag ='ch' then Chinese  else name  end as name_text 
from T0000_Resorce_table WITH (NOLOCK)

return
end

