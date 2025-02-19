

 
 -- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	exec Get_EmpReferral_Geneology_Chart 9,2202,2202
-- exec Get_EmpReferral_Geneology_Chart 9,2087,2087
-- exec Get_EmpReferral_Geneology_Chart 9,null,2202
---23/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[Get_EmpReferral_Geneology_Chart]
  @cmpid as numeric(18,0)
  ,@emp_id as numeric(18,0)=null
  ,@r_id as numeric(18,0)=null
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON



 create table #emp
(
	empid numeric(18,0)
	,rid numeric(18,0)
	,rname varchar(800)
	,ename varchar(800)
) 
  
 declare @col numeric(18,0)
  
insert into #emp
	SELECT r.emp_id,R_Emp_ID,
	--,emp_full_name,''
	('<table width="100%"><tr valign="top"><td width="28%"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="75px" height="75px"/></td> <td style="font-size:9px;font-family:Verdana;color:Black;"><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="../image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="../image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name
	,''
    FROM T0090_EMP_REFERENCE_DETAIL r WITH (NOLOCK) inner join
    T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = r.R_Emp_ID inner join t0095_increment i WITH (NOLOCK) on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment WITH (NOLOCK) where emp_id = e.emp_id)
			inner join t0040_designation_master d WITH (NOLOCK) on d.desig_id = i.desig_id 
			Left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = i.Dept_ID
    WHERE (r.R_Emp_ID = isnull(@r_id,r.R_Emp_ID) or r.emp_id = isnull(@emp_id,r.emp_id)) and source_type=2 
		and not EXISTS (select Old_Emp_Id from T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) where Old_Emp_Id = r.Emp_ID)

declare cur  cursor
	for
		select empid from #emp --where empid<>@emp_id
	open cur
		Fetch Next From cur into @col
		WHILE @@FETCH_STATUS = 0		
			begin 			
					if @col <> @emp_id
						begin 
							insert into #emp  
							select r.emp_id,r.R_Emp_Id,
							--,Emp_Full_Name
							('<table width="100%"><tr valign="top"><td width="28%"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="75px" height="75px"/></td> <td style="font-size:9px;font-family:Verdana;color:Black;"><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="../image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="../image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name
							,''
							FROM T0090_EMP_REFERENCE_DETAIL r WITH (NOLOCK) inner join
							T0080_EMP_MASTER e WITH (NOLOCK) on e.Emp_ID = r.r_Emp_ID inner join t0095_increment i WITH (NOLOCK) on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment WITH (NOLOCK) where emp_id = e.emp_id)
									inner join t0040_designation_master d WITH (NOLOCK) on d.desig_id = i.desig_id 
									Left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = i.Dept_ID
							where r.R_Emp_ID = @col and source_type=2  
									and not EXISTS (select Old_Emp_Id from T0095_EMP_COMPANY_TRANSFER WITH (NOLOCK) where Old_Emp_Id = r.Emp_ID) 
						end
					
					
					update #emp
					set ename = f.emp_full_name 
					from 
						(select 
						('<table width="100%"><tr valign="top"><td width="28%"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="75px" height="75px"/></td> <td style="font-size:9px;font-family:Verdana;color:Black;"><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="../image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="../image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name
						 from T0080_EMP_MASTER e WITH (NOLOCK)
							inner join t0095_increment i WITH (NOLOCK) on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment WITH (NOLOCK) where emp_id = e.emp_id)
							inner join t0040_designation_master d WITH (NOLOCK) on d.desig_id = i.desig_id 
							Left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = i.Dept_ID
						where e.Emp_ID = @col)f
					Where empid= @col
					
				Fetch Next From cur into @col			
			end
	close cur
deallocate cur

select x.empid, x.ename,x.rname
from #emp x

drop table #emp



--------------------------------commented on 2 Nov 2015-----------------

--	create table #final
--(
--     empid numeric(18,0)
--    ,rid  numeric(18,0)
--    ,rname varchar(max)
--    ,ename varchar(max)
--    ,desig numeric(18,0)
--    ,dept numeric(18,0)
--)

--declare @empid as numeric(18,0)
--declare @rname as varchar(max)
--declare @ename as varchar(max)
--declare @rid as numeric(18,0)
--declare @desig as numeric(18,0)
--declare @dept as numeric(18,0)

--declare @a_ename as varchar(max)
--declare @a_desig as numeric(18,0)



--declare cur  cursor
--	for
--			select  e.emp_id,
--			('<table width="100%"><tr valign="top"><td width="28%"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="75px" height="75px"/></td> <td style="font-size:9px;font-family:Verdana;color:Black;"><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="../image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="../image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name,i.desig_id	,i.Dept_id				
--			from T0080_EMP_MASTER e inner join t0095_increment i on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = e.emp_id)
--			inner join t0040_designation_master d on d.desig_id = i.desig_id 
--			Left outer join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id = i.Dept_ID
--			left join T0090_EMP_REFERENCE_DETAIL r on r.Emp_ID = e.emp_id
--			where e.cmp_id=@cmpid   --and Emp_Left<>'Y'  
--				and (r.R_Emp_ID = isnull(@r_id,r.R_Emp_ID) or e.emp_id = isnull(@emp_id,e.emp_id))
		
--		open cur
--		Fetch Next From cur into @empid,@ename,@desig,@dept
--		WHILE @@FETCH_STATUS = 0		
--			begin				
--				select  @rid = R_Emp_ID,@rname= Emp_Full_Name from T0090_EMP_REFERENCE_DETAIL 
--				inner join t0080_emp_master e on e.emp_id = R_Emp_ID
--				where T0090_EMP_REFERENCE_DETAIL.Emp_ID = @empid and source_type=2 
--				insert into #final (empid,rid,rname,ename,desig,dept)
--				values (@empid,@rid,@rname,@ename,@desig,@dept)				
--		Fetch Next From cur into @empid,@ename,@desig,@dept
--	end
--close cur
--deallocate cur
	
	
		
--  ( SELECT   e1.empid  ,
--                            e1.ename  ,
--                            ('<table width="100%"><tr valign="top"><td width="28%"><img src="../App_File/EMPIMAGES/' +(case when e2.image_name = '0.jpg' then case when e2.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else case when e2.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e2.image_name,'Emp_default.png') end end) +'" width="75px" height="75px"/></td> <td style="font-size:9px;font-family:Verdana;color:Black;"><b>Code:</b>'+ e2.alpha_emp_code +'<br/><b>Name:</b>'+e2.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e2.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="../image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="../image_new/bstop.jpg" /></td>'  end )+'</tr></table>')as Emp_Full_Name,i.desig_id,i.Dept_id				

--                   FROM     #final e1
--                            LEFT JOIN t0080_emp_master e2 ON e1.rid = e2.emp_id 
--                            inner join t0095_increment i on i.emp_id = e2.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = e2.emp_id)
--							inner join t0040_designation_master d on d.desig_id = i.desig_id
--							Left outer join T0040_DEPARTMENT_MASTER DM on DM.Dept_Id = i.Dept_ID
--                 )
  
--drop table #final



END


