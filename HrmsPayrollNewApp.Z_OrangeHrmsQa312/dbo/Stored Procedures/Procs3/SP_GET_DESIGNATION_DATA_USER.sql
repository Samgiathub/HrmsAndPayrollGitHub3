




-- =============================================
-- =============================================
-- Author:		Pranjal 
-- ALTER date: 5 Oct 2010
-- Description:	<for designation chart of user>
-- =============================================
CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_DATA_USER]  
		@cmp_id as numeric,
		@desig_id as NUMERIC,
		@emp_id as numeric,
		@int_level as NUMERIC,
		@MaxLevel as NUMERIC
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON
					
				delete from TBL_ORGANIZATION_DISPLAY
				
				exec SP_GET_DESIGNATION_TREE_USER @cmp_id,@desig_id,@int_level,@MaxLevel
				
				Declare @Emp_name	varchar(500)
		declare @Desig_id1	numeric(18, 0)
		Declare @Def_id		numeric(18, 0)	
		Declare @Parent_id	numeric(18, 0)
		declare @Is_main	numeric(18, 0)

	
		select @int_level = isnull(max(int_level),0)  from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
		Declare curUser cursor Local for 
		SELECT Desig_name ,desig_id,Def_id,Parent_id,Is_main FROM t0040_designation_master WITH (NOLOCK) WHERE cmp_id=@cmp_id and isnull(Parent_id,0)=0 and Is_main<>1 and def_id<>1
			
			open curUser
			
			Fetch next from curUser Into  @Emp_name, @Desig_id1,@Def_id,@Parent_id,@Is_main
			while @@Fetch_Status = 0
				begin
					
					declare @Row_No as numeric(18,0)
					select @Row_No=isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
					
						select @Row_No=isnull(max(Row_Id), 0) + 1 from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)
						Insert Into TBL_ORGANIZATION_DISPLAY 
						(Row_Id,Emp_id,Emp_name,Desig_id,Def_id,Int_level,Parent_id,Total_Member,Is_main)
					values 
					(@Row_No,0,@Emp_name,@Desig_id1,@Def_id,@Int_level,@Parent_id,0,@Is_main)
					  
				Fetch next from curUser Into  @Emp_name,@Desig_id1,@Def_id,@Parent_id,@Is_main
				End

			Close curUser
			Deallocate curUser	
					
			--	select * from TBL_ORGANIZATION_DISPLAY

					
				Select replace(space(10),space(1),'.') as data1 , replace(space(Qry.Int_Level * 10),space(1),'-') as data,Qry.* From 
					(Select Row_ID,EMP_ID,case when desig_id=(select desig_id from t0080_emp_master WITH (NOLOCK) where emp_id=@emp_id) then '<img src=image_new/dir.png border=0 />&nbsp;' else '<img src=image_new/desig.png border=0 />&nbsp;' end + Cast(emp_name as varchar(500)) as desig_name, is_main,def_id, Parent_id, Int_Level,Desig_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)) Qry
					order by Row_ID	
					
				select desig_id,emp_full_name from v0080_employee_master where emp_id=@emp_id	
return




