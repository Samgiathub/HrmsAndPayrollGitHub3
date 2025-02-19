



---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0160_GET_RIGHTS_VIEW]
	 @Login_ID	 numeric
	,@cmp_ID     numeric
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @Login numeric
 if @Login_ID = 0
	  set @Login_ID=null
	  
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
		declare @data_New table
		(
		Form_Id  numeric(18,0),
		Form_Name varchar(50),
		IS_Save  numeric(18,0),
		IS_Edit  numeric(18,0),
		IS_Delete numeric(18,0),
		IS_View numeric(18,0) 
		)
		Declare @IS_Default numeric(18,0)
		set @IS_Default = 0
		
		select @IS_Default = isnull(IS_Default,0) from T0011_login WITH (NOLOCK) where Login_ID =@Login_ID 
		if @IS_Default = 1
			Begin
				insert into @data_New 
				select Form_ID,Form_Name,1,1,1,1 from t0000_default_form WITH (NOLOCK)
				
				select * from @data_New
			End
		else
			BEgin
				Select a.Form_ID,a.Form_Name,b.Is_Save,b.Is_edit,b.Is_delete,b.Is_View from T0000_Default_Form  a WITH (NOLOCK) inner join @Data b
				on a.Form_ID =b.Form_ID  inner join T0011_Login LT WITH (NOLOCK) on b.Login_ID =LT.Login_ID 
			End	
		
	
	
RETURN




