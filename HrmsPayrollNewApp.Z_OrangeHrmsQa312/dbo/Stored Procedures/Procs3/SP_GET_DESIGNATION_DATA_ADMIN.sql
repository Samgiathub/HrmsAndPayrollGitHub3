


CREATE PROCEDURE [dbo].[SP_GET_DESIGNATION_DATA_ADMIN]  
		@cmp_id as numeric,
		@desig_id as NUMERIC,
		@branch_id as NUMERIC=0,
		@emp_id as numeric,
		@int_level as NUMERIC,
		@MaxLevel as NUMERIC
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

		if @branch_id=0
			set @branch_id =null
						
				delete from TBL_ORGANIZATION_DISPLAY
				
				exec SP_GET_DESIGNATION_TREE_USER @cmp_id,@desig_id,@int_level,@MaxLevel
				
				Declare @Emp_name	varchar(500)
		declare @Desig_id1	numeric(18, 0)
		Declare @Def_id		numeric(18, 0)	
		Declare @Parent_id	numeric(18, 0)
		declare @Is_main	numeric(18, 0)



---added on 7 jan 2015----
declare @col as numeric(18,0)
create table #tmptbl
(
	desig_Id  numeric(18,0)
	,proposedcnt numeric(18,0)	
	,actualcnt numeric(18,0)
)
insert into #tmptbl(desig_Id) 
(select Desig_ID from T0040_DESIGNATION_MASTER WITH (NOLOCK) where Cmp_ID = @cmp_id)
---end---------------------	
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
			
			---added on 7 jan 2015 sneha to get emp strength----
			Declare cur cursor For
				select desig_id from #tmptbl
			open cur
				fetch next from cur into @col
				while @@FETCH_STATUS = 0 
				begin
					update #tmptbl set proposedcnt = (select Strength from T0040_Employee_Strength_Master WITH (NOLOCK) where Flag = 'G' and desig_id = @col) where desig_Id = @col
					update #tmptbl set actualcnt = ( SELECT COUNT(i.Increment_ID)  FROM T0095_Increment I WITH (NOLOCK) INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , Emp_ID FROM T0095_Increment WITH (NOLOCK)  
										WHERE Increment_Effective_date <= GETDATE()
										AND Cmp_ID = @cmp_id
										GROUP BY emp_ID  ) Qry ON
										I.Emp_ID = Qry.Emp_ID	AND I.Increment_Id = Qry.Increment_Id
										INNER JOIN T0080_EMP_MASTER e WITH (NOLOCK) ON i.Emp_ID = e.Emp_ID							
								WHERE i.Cmp_ID = @cmp_id and i.Desig_Id = @col and emp_left <> 'Y') where desig_Id=@col
					fetch next from cur into @col
				End
			close cur
			deallocate cur
			---end---------------------
					
			--select * from TBL_ORGANIZATION_DISPLAY
					
					--commneted by sneha on 07 jan 2015
				--Select replace(space(10),space(1),'.') as data1 , replace(space(Qry.Int_Level * 10),space(1),'-') as data,Qry.* From 
				--	(Select Row_ID,EMP_ID,case when desig_id=(select desig_id from t0080_emp_master where emp_id=@emp_id) then '<img src=../image_new/dir.png border=0 />&nbsp;' else '<img src=../image_new/desig.png border=0 />&nbsp;' end + Cast(emp_name as varchar(500)) as desig_name, is_main,def_id, Parent_id, Int_Level,Desig_id from TBL_ORGANIZATION_DISPLAY) Qry
				--	order by Row_ID	
				---commneted end
				
				--modified by sneha on 07 Jan 2015--				
				
				Select replace(space(10),space(1),'.') as data1 , replace(space(Qry.Int_Level * 10),space(1),'-') as data,Qry.*,tmp.proposedcnt,tmp.actualcnt From 
				(Select Row_ID,EMP_ID,case when desig_id=(select desig_id from t0080_emp_master WITH (NOLOCK) where emp_id=@emp_id) then '<img src=../image_new/dir.png border=0 />&nbsp;' else '<img src=../image_new/desig.png border=0 />&nbsp;' end + Cast(emp_name as varchar(500)) as desig_name, is_main,def_id, Parent_id, Int_Level,Desig_id from TBL_ORGANIZATION_DISPLAY WITH (NOLOCK)) Qry
				left join #tmptbl tmp on tmp.desig_Id = qry.Desig_id
				order by Row_ID	
					
					if @desig_id <>0
						begin
							select desig_id,emp_full_name,branch_name,emp_id,(select actualcnt from #tmptbl where desig_Id = @desig_id)as actualcnt,(select proposedcnt from #tmptbl where desig_Id = @desig_id)as proposedcnt 
							from v0080_employee_master where desig_id=@desig_id and cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_left <> 'Y' --added on 29 apr 2015 not to show left emp
						end
					else
						begin
							select desig_id,emp_full_name,branch_name,emp_id,'' as actualcnt,''as proposedcnt 
							from v0080_employee_master where desig_id=@desig_id and cmp_id=@cmp_id and branch_id=isnull(@branch_id,branch_id) and emp_left <> 'Y'--added on 29 apr 2015 not to show left emp
						End
			
				--select * from #tmptbl
			drop table #tmptbl
return




