



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_user_right_View]
	 @Login_ID	 numeric
	,@cmp_ID     numeric
	,@Form_ID   numeric
	
 
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON 

declare @Login numeric
 if @Login_ID = 0
	  set @Login_ID=null
	  
	  ---	Select @Login =Login_ID  from T0015_Login_Branch_Rights where Branch_ID=@Branch_ID

	Declare @Data Table
		( 
		
			Login_Id	numeric ,
			cmp_ID		numeric ,
			Form_ID		numeric ,
			Branch_ID   numeric default 0,
			Is_save		numeric default 0,
			Is_Delete	numeric default 0,
			Is_Edit		numeric default 0,
			IS_View		numeric default 0,
			Is_Print	numeric default 0
		) 



	insert into @Data (login_ID,Cmp_ID,Form_ID,Branch_ID)

	select @Login_ID ,@cmp_ID ,a.Form_ID,b.Branch_ID  from T0000_Default_Form  a WITH (NOLOCK)
	left outer join t0015_Login_Branch_rights b WITH (NOLOCK) on b.Login_ID = @Login_ID  
	
	--Select * From @Data where Form_ID = 855 
--select * from @Data 
--return
	if isnull(@Login_ID,0) > 0
		begin
			Update @Data
			set Is_Save = lfr.Is_SAve ,
				Is_Edit = lfr.Is_Edit ,
				Is_Delete = lfr.Is_Delete,
				is_View = lfr.Is_View,
				Is_PRint = lfr.IS_Print
			
			From @Data d inner join T0015_Login_Form_Rights lfr on d.Form_ID =lfr.Form_ID
			where lfr.Login_ID =@Login_ID
		end 
		
Declare @Admin as tinyint
Declare @Count as numeric(2,0)
set @Count=0
set @Admin=0
select @Admin=isnull(is_Default,0) from T0011_Login WITH (NOLOCK) where Login_ID=@Login_ID and Cmp_ID=@Cmp_ID
		
		
Select @Count=Count(b.Is_View) from T0000_Default_Form  a WITH (NOLOCK) inner join @Data b

		on a.Form_ID =b.Form_ID  inner join T0011_Login LT WITH (NOLOCK) on b.Login_ID =LT.Login_ID 
		
		 where a.Form_ID =@Form_ID and LT.is_Default=0 
		 
if isnull(@Count,0)=0 And isnull(@Admin,0)=0
	Begin
		Select 0 as Is_Save,0 as Is_edit,0 as Is_delete,1 as Is_View

		
	
	End 		 
else
	Begin
		Select a.Form_ID,a.Form_Name,b.Is_Save,b.Is_edit,b.Is_delete,b.Is_View from T0000_Default_Form  a WITH (NOLOCK) inner join @Data b

		on a.Form_ID =b.Form_ID  inner join T0011_Login LT WITH (NOLOCK) on b.Login_ID =LT.Login_ID 
		
		 where a.Form_ID =@Form_ID and LT.is_Default=0 
	
	End	
		 
RETURN




