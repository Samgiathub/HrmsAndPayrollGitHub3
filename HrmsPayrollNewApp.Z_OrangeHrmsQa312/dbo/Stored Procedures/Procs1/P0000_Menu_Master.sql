

---25/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0000_Menu_Master]
 @cmp_id numeric
,@Form_id			NUMERIC OUTPUT
,@Form_Name			VARCHAR(50)
,@Form_url			VARCHAR(50)
,@Form_Image_url	VARCHAR(50)
,@Under_Form_id		NUMERIC
,@Sort			NUMERIC
,@Ess_Admin			NUMERIC
,@is_active_for_menu as tinyint
,@alias varchar(100)
,@Tran_type			CHAR(1)

AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


		if @Under_Form_id=0 
		begin
			set @Under_Form_id = -1
		end



IF @Tran_type = 'I'
	BEGIN
	
	declare @from_type as numeric(18,0)
			set @from_type = 1

			if @Ess_Admin = 0 
			begin
			select @Form_id = isnull(max(Form_ID),6000) + 1  from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6000 and Form_ID < 6500
			set @from_type = 1
			end
			else if @Ess_Admin =1
			begin
			select @Form_id = isnull(max(Form_ID),6500) + 1  from T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID > 6500 and Form_ID < 7000
			set @from_type =2
			end
			else if @Ess_Admin =2
			begin
			select @Form_id = isnull(max(Form_ID),7000) + 1  from T0000_DEFAULT_FORM WITH (NOLOCK)	where Form_ID > 7000 and Form_ID < 8000
			set @from_type =0
			end
			
		if exists(select Form_ID from T0000_DEFAULT_FORM WITH (NOLOCK) where upper(Form_Name) = upper(@Form_Name))
			Begin
				Set @Form_id = 0
			return
			End
		
		insert into T0000_DEFAULT_FORM (Form_id,Form_Name,Form_url,Form_Image_url,Under_Form_ID,Sort_ID,Form_Type,Is_Active_For_menu,Alias)
				Values(@Form_id,@Form_Name,@Form_url,@Form_Image_url,@Under_Form_id,@Sort,@from_type,@is_active_for_menu,@alias)
				
	END		
else if @Tran_type = 'U'
	Begin 
		if not exists(select Form_id  from  T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID = @Form_id)    
		
			Begin
				set @Form_id = 0
	             return
	         End
			if @Form_Image_url ='' 
			begin
				select @Form_Image_url =Form_Image_url  from  T0000_DEFAULT_FORM WITH (NOLOCK) where Form_ID = @Form_id
			end
	
		    update T0000_DEFAULT_FORM 
			set 
			Form_Name = @Form_Name,
				Form_url=@Form_url,
				Form_Image_url=@Form_Image_url,
				Under_Form_id=@Under_Form_id,
				Sort_ID=@Sort,
				Is_Active_For_menu=@is_active_for_menu,
				Alias=@alias
			where Form_id = @Form_id
			
	                   

	End
	
Else if @Tran_Type = 'D' 			
	Begin
	
 
	if  exists( select 1 from T0000_DEFAULT_FORM WITH (NOLOCK) where Under_Form_ID=@Form_id)
	begin 
	
		RAISERROR('Reference Exist',16,2)
		RETURN -1
	
	end
	 
			Delete from T0000_DEFAULT_FORM where Form_id = @Form_id		
			
	End			

RETURN

