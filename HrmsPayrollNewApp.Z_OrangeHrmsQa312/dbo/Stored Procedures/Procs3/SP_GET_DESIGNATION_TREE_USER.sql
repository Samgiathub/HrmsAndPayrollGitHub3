




-- =============================================
-- Author:		Pranjal
-- ALTER date: 5 Oct 2010
-- Description:	<for Designation chart at user>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_TREE_USER]  
	@cmp_id as numeric,
	@desig_id as NUMERIC,
	@int_level as NUMERIC,
	@MaxLevel as NUMERIC

AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

	BEGIN
		if @desig_id = 0 
			set @desig_id= null

		declare @Row_No numeric
		if @int_level = 0  
		begin
				set @Row_No = 0
				set @Int_Level= 0
					select @Row_No=isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
			
					Insert Into TBL_ORGANIZATION_DISPLAY
					(Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,is_main)
					SELECT @Row_No,0, Desig_name ,desig_id,Def_id,@Int_Level,Parent_id,0,Is_main FROM t0040_designation_master WITH (NOLOCK) WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and def_id=1
					SELECT @desig_id=desig_id FROM t0040_designation_master WITH (NOLOCK) WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main=1 and def_id=1
			 
		end
			
	set @Int_Level= @Int_Level + 1

	
		if @Int_Level = @MaxLevel 
			begin
				return
			end
			
		Declare @Emp_name	varchar(500)
		declare @Desig_id1	numeric(18, 0)
		Declare @Def_id		numeric(18, 0)	
		Declare @Parent_id	numeric(18, 0)
		declare @Is_main	numeric(18, 0)

	
		
		Declare curUser cursor Local for 
		SELECT Desig_name, Desig_id,Def_id,isnull(Parent_id,0),is_main
		FROM t0040_designation_master WITH (NOLOCK)
		WHERE cmp_id=@cmp_id and  Parent_ID=@desig_id  order by Desig_name asc
			
			open curUser
			
			Fetch next from curUser Into  @Emp_name, @Desig_id1,@Def_id,@Parent_id,@Is_main
			while @@Fetch_Status = 0
				begin
					select @Row_No=isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
					Insert Into TBL_ORGANIZATION_DISPLAY 
					(Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)
				values 
				(@Row_No,0,@Emp_name,@Desig_id1,@Def_id,@Int_level,@Parent_id,0,@Is_main)
					
					--select * from TBL_ORGANIZATION_DISPLAY
					Exec SP_GET_DESIGNATION_TREE_USER @cmp_id,@Desig_id1,@int_level,@MaxLevel 
					  
				Fetch next from curUser Into  @Emp_name,@Desig_id1,@Def_id,@Parent_id,@Is_main
				End

			Close curUser
			Deallocate curUser	
	RETURN
END




