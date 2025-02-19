


-- =============================================
-- Author:		<Gadriwala Muslim >
-- Create date: <02/02/2015>
-- Description:	<Medical Checkup Diagnosis Report>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[RPT_Medical_Checkup_Diagnosis]
 @Company_Id   numeric,      
 @From_Date  datetime,      
 @To_Date  datetime ,      
 @Branch_ID  numeric   ,      
 @Cat_ID   numeric  ,      
 @Grade_ID   numeric ,      
 @Type_ID  numeric ,      
 @Dept_ID  numeric  ,      
 @Desig_ID  numeric ,      
 @Emp_ID   numeric  ,      
 @Constraint  varchar(MAX) = '',      
 @Report_call varchar(20) = '',      
 @Weekoff_Entry varchar(1) = '',  
 @PBranch_ID varchar(200) = '0'  
AS
BEGIN
	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	
	CREATE table #Emp_Cons 
	(      
		Emp_ID numeric ,     
		Branch_ID numeric,
		Increment_ID numeric    
	)      

	if @Constraint <> ''
		begin
			Insert Into #Emp_Cons
			Select cast(data  as numeric),cast(data  as numeric),cast(data  as numeric) From dbo.Split(@Constraint,'#') 
		end
	else 
		begin
			if @PBranch_ID <> '0' and isnull(@Branch_ID,0) = 0
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Company_Id 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
					and Branch_ID in (select cast(isnull(data,0) as numeric) from dbo.Split(@PBranch_ID,'#'))					   
				   --and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grade_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						Delete From #Emp_Cons Where Increment_ID Not In
						(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						Where Increment_effective_Date <= @to_date) 
				End	
			Else
				Begin
					Insert Into #Emp_Cons      
					  select distinct emp_id,branch_id,Increment_ID from dbo.V_Emp_Cons where 
					  cmp_id=@Company_Id 
					   and Isnull(Cat_ID,0) = Isnull(@Cat_ID ,Isnull(Cat_ID,0))      
				   and Branch_ID = isnull(@Branch_ID ,Branch_ID)      
				   and Grd_ID = isnull(@Grade_ID ,Grd_ID)      
				   and isnull(Dept_ID,0) = isnull(@Dept_ID ,isnull(Dept_ID,0))      
				   and Isnull(Type_ID,0) = isnull(@Type_ID ,Isnull(Type_ID,0))      
				   and Isnull(Desig_ID,0) = isnull(@Desig_ID ,Isnull(Desig_ID,0)) 
				   and Emp_ID = isnull(@Emp_ID ,Emp_ID)   
					  and Increment_Effective_Date <= @To_Date 
					  and 
							  ( (@From_Date  >= join_Date  and  @From_Date <= left_date )      
								or ( @To_Date  >= join_Date  and @To_Date <= left_date )      
								or (Left_date is null and @To_Date >= Join_Date)      
								or (@To_Date >= left_date  and  @From_Date <= left_date )) 
								order by Emp_ID
								
						Delete From #Emp_Cons Where Increment_ID Not In
						(select TI.Increment_ID from t0095_increment TI WITH (NOLOCK) inner join
						(Select Max(Increment_Effective_Date) as Effective_Date,Emp_ID from T0095_Increment WITH (NOLOCK)
						Where Increment_effective_Date <= @to_date Group by emp_ID) new_inc
						on TI.Emp_ID = new_inc.Emp_ID and Ti.Increment_Effective_Date=new_inc.Effective_Date
						Where Increment_effective_Date <= @to_date) 
				End	
		end
		
		declare @colsDiagnosis as varchar(max)
		declare @Query as varchar(max)
		declare @Diagnosis_Count numeric(18,0)
		DECLARE @intFlag INT
		SET @intFlag = 1
		Create table #Diagnosis
		(
			sr_No numeric(18,0)
		)
		    
			select @Diagnosis_Count = max(Diagnosis_Count) from   (
			select	ROW_NUMBER() over (Partition by Emp_ID Order by For_Date asc) as Diagnosis_Count 
													from dbo.T0090_Emp_Medical_Checkup  WITH (NOLOCK)
												where For_Date >=@From_Date
												and For_Date <= @To_Date
													group by EMP_ID,For_Date 

			)a
						
			WHILE (@intFlag <=@Diagnosis_Count)
				BEGIN
						insert into #Diagnosis
						 select @intFlag
						  
						SET @intFlag = @intFlag + 1
				END
					
				
				select @colsDiagnosis = STUFF((SELECT     ',' + QUOTENAME('Diagnosis_' + cast(SR_No as varchar(10))  )  
						from #Diagnosis
						FOR XML PATH(''), TYPE
					).value('.', 'NVARCHAR(MAX)') ,1,1,'')	


--select  ROW_NUMBER() over (Order by Medical_ID asc) as SR_NO,*
--			   From  (
			   
--				 select  EMC.Tran_ID as Medical_Tran_ID,EMC.Medical_ID as Medical_ID,IM.Ins_Name as Parameter
--				,EMC.Description as Diagnosis
--				from T0090_Emp_Medical_Checkup EMC 
--				inner join T0040_INSURANCE_MASTER IM on EMC.Medical_ID = IM.Ins_Tran_ID and IM.Type = 'Medical'
--							where EMC.Cmp_ID = @cmp_ID and Emp_ID = @Emp_ID and For_date = @For_Date
--				Union  
--				select 0 as Medical_Tran_ID,Ins_Tran_ID as Medical_ID,Ins_Name as Parameter, '' as Diagnosis from dbo.T0040_INSURANCE_MASTER IM
--							Left outer join ( select Medical_ID as Old_Medical_Id from T0090_Emp_Medical_Checkup 
--							where  cmp_Id =@cmp_ID and Emp_Id = @emp_ID and For_Date = @for_date)qry on Qry.Old_Medical_Id = IM.Ins_Tran_ID

--							where Cmp_ID = @cmp_ID and Type = 'Medical' and isnull(Old_Medical_Id,0) = 0
--				 )a	

create table #Medical_Table
(
	Emp_ID numeric(18,0),
	For_Date datetime,
	Medical_ID numeric(18,0),
	col  varchar(25),
	val  varchar(max)
)
declare @cur_SR_NO as numeric(18,0)
declare @cur_Emp_ID as numeric(18,0)
declare @cur_For_date as datetime
declare @ColumnName as varchar(20)	
declare @Prev_ColumnName varchar(20)


declare @Cur_Medical_ID numeric(18,0)
declare @Cur_Description varchar(max)
declare @Exists tinyint
Declare @Previous_Date datetime
Declare @Previous_Emp_ID datetime
Declare @intFlagMain numeric(18,0)


declare @Count numeric(18,0)
set @Count = 0

set @Previous_Date = Null

declare curEmpMedicalData Cursor For select EMC.EMP_ID,For_Date
						 from dbo.T0090_Emp_Medical_Checkup EMC WITH (NOLOCK) inner join #Emp_Cons ec on EC.Emp_Id = EMC.Emp_Id
						   where For_Date >= @From_Date and For_Date <=@To_Date and cmp_Id = @Company_Id
						  Group by EMC.Emp_ID,EMC.For_Date

Open curEmpMedicalData
FETCH NEXT FROM curEmpMedicalData INTO @cur_Emp_ID,@cur_For_date
		WHILE @@FETCH_STATUS = 0      
			BEGIN   
					IF @cur_For_date <> @Previous_Date  or @Previous_Date is null 				
									set @Count = @Count + 1
					
					insert into #Medical_Table(Medical_ID,For_Date,Emp_ID,col,val)
						 select Ins_Tran_ID,@cur_For_date,@cur_Emp_ID,'Diagnosis_'  + cast(@Count as varchar(10)),'' from dbo.T0040_INSURANCE_MASTER WITH (NOLOCK) where Cmp_ID = @Company_Id and Type = 'Medical'
							
							
						  
						  set @Previous_Date = @cur_For_date
			FETCH NEXT FROM curEmpMedicalData INTO @cur_Emp_ID,@cur_For_date
			End
			
close curEmpMedicalData
deallocate curEmpMedicalData

declare curEmpMedicalData Cursor For select EMC.EMP_ID,For_Date,Medical_ID,Description
						 from dbo.T0090_Emp_Medical_Checkup EMC WITH (NOLOCK) inner join #Emp_Cons ec on EC.Emp_Id = EMC.Emp_Id
						   where For_Date >= @From_Date and For_Date <=@To_Date and cmp_Id = @Company_Id
Open curEmpMedicalData
FETCH NEXT FROM curEmpMedicalData INTO @cur_Emp_ID,@cur_For_date,@Cur_Medical_ID,@Cur_Description
		WHILE @@FETCH_STATUS = 0      
			BEGIN   
					
						update  #Medical_Table set val = @Cur_Description 
						where Medical_ID = @Cur_Medical_ID and For_Date = @cur_For_date and Emp_ID = @cur_Emp_ID	
					
			FETCH NEXT FROM curEmpMedicalData INTO @cur_Emp_ID,@cur_For_date,@Cur_Medical_ID,@Cur_Description
			End
			
close curEmpMedicalData
deallocate curEmpMedicalData

select ROW_NUMBER() over (Partition by EMP_ID,For_date order by Medical_ID) as SR_NO, * into #t3  
From #Medical_Table order by Emp_ID,For_Date,Medical_ID

If exists(select 1 from sys.objects  where name = 't2')
drop table t2


set @Query = 
'select EMP_ID,For_date,Medical_ID,Ins_Name as Description,' + @colsDiagnosis + ' into t2  from
(
	select SR_NO,EMP_ID,For_Date,Medical_ID,Ins_Name,Col,Val 
	from #t3 t Inner join dbo.T0040_Insurance_Master IM WITH (NOLOCK) on IM.Ins_Tran_ID = t.Medical_ID 
	
)d	
PIVOT
(
  min(val)
  for col in ( ' + @colsDiagnosis + ')
) piv;
'

exec(@Query)	


if exists (select 1 from sys.objects where name = '#t2')
	drop table #t2

If not exists( select 1 from sys.objects where name ='t2')	
return
 
select * into #t2 from  t2
	

	
set @Previous_Date = null
set @Previous_Emp_ID = 0
set @intFlagMain = 1


WHILE (@intFlagMain <= @Diagnosis_Count)
  BEGIN

		declare curDiag cursor for select EMP_ID,For_date from #t2 Group by Emp_ID,For_date order by For_date asc
		Open curDiag
			FETCH NEXT FROM curDiag INTO @Cur_Emp_ID,@Cur_For_date
				WHILE @@FETCH_STATUS = 0      
					BEGIN   	
								set @intFlag = 1
								if (@Cur_For_date <> @Previous_Date  or @Cur_Emp_ID	<> @Previous_Emp_ID)  and @intFlagMain = 1
									begin
										Insert into #t2(Emp_ID,For_Date,Medical_ID,Description) 
										values(@Cur_Emp_ID,@Cur_For_Date,0,'Date')			
									end
											
								if @Cur_Emp_ID	<> @Previous_Emp_ID 
									set @Previous_Date = null
									
								WHILE (@intFlag <= @Diagnosis_Count)
									BEGIN
														
													
										 set @ColumnName = QUOTENAME('Diagnosis_' + cast(@intFlag as varchar(10)))	
										 If @Previous_Date is not null
										  begin
											  declare curInnerDiag  cursor for select Medical_ID from #t2 where For_date = @cur_For_date and Emp_ID = @cur_Emp_ID 
											  open curInnerDiag	
											  FETCH NEXT FROM curInnerDiag INTO @cur_Medical_ID
													WHILE @@FETCH_STATUS = 0      
														BEGIN   
															 set @Query =  'Update  #t2 set ' + @ColumnName + ' =  colum  from 
															 (
																select ' + @ColumnName + ' as colum  from #t2 where ' + @ColumnName + ' is not null 
																and For_date = ''' + CAST(@Cur_For_date as varchar(25)) + ''' and emp_Id = ' + CAST(@cur_Emp_ID as varchar(10)) + '
																and Medical_ID = '+ CAST(@Cur_Medical_ID as varchar(10))  +'
															 ) a
															 where For_date = '''+ CAST(@Previous_Date as varchar(25)) + ''' 
															 and emp_Id = ' + CAST(@cur_Emp_ID as varchar(10))+ '
															 and Medical_ID = '+ CAST(@Cur_Medical_ID as varchar(10))  +' ' 
															
															 exec(@query) 
																
																
																
															FETCH NEXT FROM curInnerDiag INTO @cur_Medical_ID
														End
												close curInnerDiag
												deallocate 	 curInnerDiag			
										  end
										 
										 SET @intFlag = @intFlag + 1
									END  
									
									set @Previous_Date = @Cur_For_date  
									set @Previous_Emp_ID = @cur_Emp_ID		
									
						FETCH NEXT FROM curDiag INTO @Cur_Emp_ID,@Cur_For_date
					End
		close curDiag
		deallocate curDiag
		 set @intFlagMain = @intFlagMain + 1
end


set @intFlagMain = 1
Declare @intNextColumn numeric(18,0)
set @intNextColumn = 1

WHILE (@intFlagMain <= @Diagnosis_Count)
	BEGIN
		declare CurDateUpdate cursor for  select EMP_ID,For_date from #t2 Group by Emp_ID,For_date order by EMP_ID,For_date asc 
			open CurDateUpdate
					FETCH NEXT FROM CurDateUpdate INTO @Cur_Emp_ID,@Cur_For_date
				WHILE @@FETCH_STATUS = 0      
					BEGIN  
							set @intFlag = 1
							set @intNextColumn = 1
							WHILE (@intFlag <= @Diagnosis_Count)
									BEGIN
									
											IF @cur_emp_ID <> @Previous_Emp_ID
											  set @Previous_Date = null
											  
											If @intFlag = 1
												begin
														
													set @ColumnName = QUOTENAME('Diagnosis_' + cast(@intFlag as varchar(10)))	
												
													   set @Query = 'Update #t2 set ' + @ColumnName + ' = ''' + REPLACE(CONVERT(VARCHAR(11),@cur_For_date,103), ' ','/') + '''
														where Emp_ID = ' + cast(@cur_emp_ID as varchar(10))+' and For_date = ''' + cast(@cur_For_date as varchar(25)) + '''
														and Medical_ID = 0 and ' + @ColumnName + ' is null '		
														exec(@Query)
												end
											 
													IF @Previous_Date <> @cur_For_date 
													 begin
													 
															  set @ColumnName = QUOTENAME('Diagnosis_' + cast(@intFlag as varchar(10)))	
																
																 SET @intNextColumn = @intFlag + 1
																
																	if @intNextColumn  <= @Diagnosis_Count
																		begin	
																		     
																				set @Prev_ColumnName = QUOTENAME('Diagnosis_' + cast( @intNextColumn as varchar(10)))
																				set @Query = 'Update #t2 set ' + @Prev_ColumnName + ' = colum from
																				(
																					select ' + @ColumnName + ' as colum  from #t2 where ' + @ColumnName + ' is not null 
																					and For_date = ''' + CAST(@Cur_For_date as varchar(25)) + ''' 
																					and emp_Id = ' + CAST(@cur_Emp_ID as varchar(10)) + '
																					and Medical_ID = 0 
																				) a
																				where Emp_ID = ' + cast(@cur_emp_ID as varchar(10))+' and For_date = ''' + cast(@Previous_Date as varchar(25)) + '''
																				and Medical_ID = 0 '		
																				exec(@Query)
																				
																		end
													 end
										
										set @intFlag = @intFlag  + 1		
									end
							
							set @Previous_Date = @cur_For_date
							set @Previous_Emp_ID = @cur_Emp_ID
							
						FETCH NEXT FROM CurDateUpdate INTO @Cur_Emp_ID,@Cur_For_date
					end							
			close CurDateUpdate
		deallocate CurDateUpdate

	set @intFlagMain = @intFlagMain + 1
End

If exists (select 1 from sys.objects where name='#t4')
	drop table #t4
		
If exists (select 1 from sys.objects where name='#Final')
	drop table #Final


select row_Number() over( partition by Emp_ID order by For_Date) as row_ID,Emp_ID,For_Date into #t4 
from #t2 group by Emp_ID,For_Date

select row_number() over( Partition by Emp_ID order by emp_ID,For_Date,Medical_ID) as Row_ID,* into #Final from #t2 
order by Emp_ID,For_Date,Medical_ID
		 
		 
		 
	set @Query = 'SELECT row_number() over( Partition by temp.Emp_ID order by temp.emp_ID,temp.For_Date,temp.Medical_ID) as SR_No,  
				 case when temp.Row_ID = 1 then ''="'' +  E.Alpha_Emp_Code + ''"'' else Null end as EMP_CODE,
				 case when temp.Row_ID = 1 then E.Emp_Full_Name else Null end as EMPlOYEE_NAME,
				 case when temp.Row_ID = 1 then B.Branch_Name else Null end as BRANCH,
				 case when temp.ROW_ID = 1 then G.Grd_Name else Null end as GRADE,
				 case when temp.ROW_ID = 1 then D.dept_name else Null end as DEPARTMENT,
				 case when temp.ROW_ID = 1 then DD.Desig_Name else Null end as DESIGNATION,
				 case when temp.ROW_ID = 1 then T.Type_Name else Null end as TYPE,
				 case when temp.Row_ID = 1 then E.Emp_Mark_Of_Identification else Null end as MARK_IDENTIFICATION,
				 temp.Description as Description,' + @colsDiagnosis  + ',Inc_Qry.Branch_ID    
				 FROM dbo.T0080_EMP_MASTER E WITH (NOLOCK) Inner join #Emp_Cons EC on E.Emp_ID = EC.Emp_ID Inner join       
				 (   select I.Emp_Id,I.Branch_ID,Type_ID ,Grd_ID,Dept_ID,Desig_Id
					 from dbo.T0095_INCREMENT I WITH (NOLOCK) inner join       
					 (		select max(Increment_ID) as Increment_ID, Emp_ID from dbo.T0095_INCREMENT WITH (NOLOCK)
								where Increment_effective_Date <= ''' + cast(@To_Date as varchar(25)) + '''      
								and Cmp_ID = ' + cast(@Company_Id as varchar(10)) + '  group by emp_ID 
					  ) Qry on I.Emp_ID = Qry.Emp_ID and i.Increment_ID   = Qry.Increment_ID	       
						where Cmp_ID = ' + cast(@Company_Id as varchar(10)) + ' 
					) Inc_Qry on e.Emp_ID = Inc_Qry.Emp_ID  Inner Join 
						T0030_Branch_Master B WITH (NOLOCK) On Inc_Qry.Branch_Id = B.Branch_Id Left Outer join
						T0040_Grade_Master G WITH (NOLOCK) on Inc_Qry.Grd_Id = G.Grd_Id Left Outer Join
						T0040_DEPARTMENT_MASTER D WITH (NOLOCK) on Inc_Qry.Dept_Id = D.Dept_Id Left Outer Join
						T0040_Designation_Master DD WITH (NOLOCK) on Inc_Qry.Desig_Id = DD.Desig_Id Left Outer Join
						T0040_Type_Master T WITH (NOLOCK) on Inc_Qry.Type_Id = T.Type_Id
					Inner join #Final temp on e.Emp_ID = temp.Emp_ID 
					inner join #t4 temp2 on temp2.Emp_ID = temp.emp_ID and temp2.For_date = temp.For_Date and temp2.row_ID = 1
				  WHERE E.Cmp_ID = ' + cast(@Company_Id as varchar(10)) + ' 
				 Order by temp.emp_ID,temp.For_Date,temp.medical_ID'
		exec(@query)	
		
		
		
		--added branch_id jimit 24042015
		
 
END

