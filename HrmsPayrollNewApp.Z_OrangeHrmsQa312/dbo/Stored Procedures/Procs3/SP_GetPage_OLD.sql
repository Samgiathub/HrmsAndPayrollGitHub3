
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[SP_GetPage_OLD]
	 @Items_Per_Page numeric(9)
	,@Page_No numeric(9)
	,@Select_Fields varchar(MAX)
	,@From varchar(MAX)
	,@Where varchar(MAX)=null
	,@OrderBy varchar(MAX)=null
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	--if exists(select 1 from sys.triggers where is_disabled=1 and parent_class <>0) --for sql 2005 added by hasmukh 
	----	if not exists(select 1 from sysobjects a join sysobjects b on a.parent_obj=b.id where a.type = 'tr' AND A.STATUS & 2048 = 0) -- for sql 2000
	--begin		
	--	exec sp_msforeachtable 'ALTER TABLE ? ENABLE TRIGGER all'
	--	--set @ErrRaise =':|:ERRT:|: Another Process Running. Try After Sometime'
	--	--return 
	--end

	declare @strQry1 as varchar(Max)	--Max added by Ankit 12062014
	declare @strQry2 as varchar(Max)
	declare @strQry_Count as varchar(Max)
	declare @strQry as varchar(Max)
	declare @strQry_All as varchar(Max)
	declare @1Field as varchar(max)
	

	set @Select_Fields=@Select_Fields
	
	if @Select_Fields = '*'
		begin
		set @Select_Fields=null
		    SELECT @Select_Fields = COALESCE(@Select_Fields + ', ', '') + CAST(name AS varchar(200)) 
			FROM sys.columns WHERE [object_id] = OBJECT_ID(@from)
		end
	
	if (charindex(',',@Select_Fields)<>0 )
		set	@1Field=substring(@Select_Fields,0,charindex(',',@Select_Fields))
	else
		set	@1Field=@Select_Fields
		
	--SELECT 1
	--return
	
	
	
	if (isnull(@OrderBy,'')<>'' )
		set @OrderBy=' Order By '+ @OrderBy
	
 	if (isnull(@Where,'')<>'' )
	begin
	
		set @strQry1='select Top '+ cast((@Items_Per_Page * @Page_No) as varchar) + ' '+ @1Field + ' From '+ @From +' where ' +@Where + isnull(@OrderBy,'')
		set @strQry2='select Top '+ cast((@Items_Per_Page * (@Page_No-1)) as varchar) + ' '+ @1Field + ' From '+ @From +' where ' +@Where + isnull(@OrderBy,'')
		set @strQry='select Top '+ cast((@Items_Per_Page) as varchar) + ' '+ @Select_Fields + ' From '+ @From +' where ' +@Where +' and ' 
		set @strQry_Count='select count ('+ @1Field + ') as Total_Records From '+ @From +' where ' +@Where
		set @strQry_All='select '+ @Select_Fields + ' From '+ @From +' where ' +@Where	
		
	end
	else 
	begin
	
		set @strQry1='select Top '+ cast((@Items_Per_Page * @Page_No) as varchar) + ' '+ @1Field + ' From '+ @From + isnull(@OrderBy,'')
		set @strQry2='select Top '+ cast((@Items_Per_Page * (@Page_No-1)) as varchar) + ' '+ @1Field + ' From '+ @From + isnull(@OrderBy,'')
		set @strQry='select Top '+ cast((@Items_Per_Page) as varchar) + ' '+ @Select_Fields + ' From '+ @From +' where ' 
		set @strQry_Count='select count ('+ @1Field + ') as Total_Records From '+ @From 
		set @strQry_All='select '+ @Select_Fields + ' From '+ @From 		
	end	
	

	set @strQry=@strQry +' '+ @1Field + ' in ' +'('+ @strQry1 +') and '+ @1Field +' Not in '+'('+ @strQry2 +')'+ isnull(@OrderBy,'')
	
	

	if (@Page_No=0)
		set @strQry=@strQry_All+' ' +isnull(@OrderBy,'')
	
	
	exec (@strQry)
	
	exec (@strQry_Count)
		
	RETURN


