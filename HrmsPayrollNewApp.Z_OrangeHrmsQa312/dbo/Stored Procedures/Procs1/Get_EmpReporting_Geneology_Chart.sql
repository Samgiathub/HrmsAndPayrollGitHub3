

---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_EmpReporting_Geneology_Chart]
  @cmpid as numeric(18,0)
  ,@emp_id as numeric(18,0)=null
  ,@r_id as numeric(18,0)=null
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


BEGIN

	create table #final
(
     empid numeric(18,0)
    ,rid  numeric(18,0)
    ,rname varchar(max)
    ,ename varchar(max)
    ,desig numeric(18,0)
    ,dept numeric(18,0)
)

declare @empid as numeric(18,0)
declare @rname as varchar(max)
declare @ename as varchar(max)
declare @rid as numeric(18,0)
declare @desig as numeric(18,0)
declare @dept as numeric(18,0)
declare @a_ename as varchar(max)
declare @a_desig as numeric(18,0)

declare cur  cursor
	for		
			SELECT  e.emp_id,
			('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td><img src="App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="60px" height="50px"/></td></tr><tr> <td style="font-size:8pt;font-family: Muli , sans-serif !important;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name,i.desig_id	,i.Dept_id
			FROM  T0080_EMP_MASTER E WITH (NOLOCK)
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = E.Emp_ID
			INNER JOIN (
							SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK)
							INNER JOIN (
											SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
											FROM T0095_INCREMENT WITH (NOLOCK)
											GROUP BY Emp_ID
										)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
							GROUP BY T0095_INCREMENT.Emp_ID
						)I1 on i1.Increment_ID = I.Increment_ID
			LEFT JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) on D.Desig_ID = I.Desig_Id 
			LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_ID
			LEFT JOIN T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) ON ER.Emp_ID = E.Emp_ID
			LEFT JOIN (
				SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
				FROM  T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
				INNER JOIN (
								SELECT MAX(Effect_Date)Effect_Date,Emp_ID
								FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
								GROUP BY Emp_ID
							)ER2 ON ER2.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
				GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
			)ER1 ON ER1.Row_ID = ER.Row_ID
			INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=E.Cmp_ID
			WHERE E.Cmp_ID = @cmpid AND (E.Emp_ID = @emp_id)
			UNION ALL	
			SELECT  EER.emp_id,
			('<table width="100%" style="background-color:'+ case when EER.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td><img src="App_File/EMPIMAGES/' +(case when EER.image_name = '0.jpg' then case when EER.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when EER.image_name='' then case when EER.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(EER.image_name,'Emp_default.png') end end) +'" width="60px" height="50px"/></td></tr><tr> <td style="font-size:8pt;font-family: Muli , sans-serif !important;color:Black;" align="left"><b>' + case when EER.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>Code:</b>'+ EER.alpha_emp_code +'<br/><b>Name:</b>'+EER.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,EER.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name,i.desig_id	,i.Dept_id
			FROM T0090_EMP_REPORTING_DETAIL RE WITH (NOLOCK)
			INNER JOIN (
					SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
					FROM T0090_EMP_REPORTING_DETAIL	WITH (NOLOCK)
					INNER JOIN (
									SELECT MAX(Effect_Date)Effect_Date,Emp_ID
									FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
									GROUP BY Emp_ID
								)RE2 ON RE2.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
					GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
			)RE1 ON RE1.Row_ID = RE.Row_ID 
			LEFT JOIN T0080_EMP_MASTER EER WITH (NOLOCK) ON EER.Emp_ID = RE.Emp_ID
			INNER JOIN T0095_INCREMENT I WITH (NOLOCK) ON I.Emp_ID = RE.Emp_ID
			INNER JOIN (
							SELECT MAX(Increment_ID)Increment_ID,T0095_INCREMENT.Emp_ID
							FROM T0095_INCREMENT WITH (NOLOCK)
							INNER JOIN (
											SELECT MAX(Increment_Effective_Date)Increment_Effective_Date,Emp_ID
											FROM T0095_INCREMENT WITH (NOLOCK)
											GROUP BY Emp_ID
										)I2 ON I2.Emp_ID = T0095_INCREMENT.Emp_ID
							GROUP BY T0095_INCREMENT.Emp_ID
						)I1 on i1.Increment_ID = I.Increment_ID
			LEFT JOIN T0040_DESIGNATION_MASTER D WITH (NOLOCK) on D.Desig_ID = I.Desig_Id 
			LEFT JOIN T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = I.Dept_ID
			INNER JOIN T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=EER.Cmp_ID
			WHERE  (RE.R_Emp_ID = @emp_id)
				AND EER.Emp_Left <> 'Y'
			union all	
			select   R_Emp_ID,('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td><img src="App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else  case when e.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end end) +'" width="60px" height="50px"/></td></tr><tr> <td style="font-size:8pt;font-family: Muli , sans-serif !important;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>Code:</b>'+ e.alpha_emp_code +'<br/><b>Name:</b>'+e.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="image_new/bstop.jpg" /></td>' end )+'</tr></table>')as Emp_Full_Name,i.desig_id	,i.Dept_id
			from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
				inner join t0080_emp_master e WITH (NOLOCK) on e.emp_id = R_Emp_ID
				inner join t0095_increment i WITH (NOLOCK) on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment WITH (NOLOCK) where emp_id = e.emp_id)
				inner join t0040_designation_master d WITH (NOLOCK) on d.desig_id = i.desig_id 
				Left  join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = i.Dept_ID
				inner join T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=e.Cmp_ID
			where T0090_EMP_REPORTING_DETAIL.emp_id = @emp_id  
				and effect_date = (select max(effect_date) from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) where emp_id=@emp_id)
		open cur
		Fetch Next From cur into @empid,@ename,@desig,@dept
		WHILE @@FETCH_STATUS = 0		
			begin		
				set @rid = null		
				SET @rname = NULL
				--select  @rid = R_Emp_ID,@rname= Emp_Full_Name from T0090_EMP_REPORTING_DETAIL 
				--left	 join t0080_emp_master e on e.emp_id = R_Emp_ID
				--where T0090_EMP_REPORTING_DETAIL.Emp_ID = @empid  --and reporting_method='Direct'
				-- and effect_date=(select MAX(Effect_Date) from T0090_EMP_REPORTING_DETAIL where Emp_ID=@empid)
				
				SELECT  @rid = R_Emp_ID,@rname= Emp_Full_Name 
				FROM T0090_EMP_REPORTING_DETAIL  RE WITH (NOLOCK)
				INNER JOIN (
						SELECT MAX(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID
						FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
						INNER JOIN (
										SELECT MAX(Effect_Date)Effect_Date,Emp_ID
										FROM T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)
										GROUP BY Emp_ID
									)Re2 on Re2.Emp_ID = T0090_EMP_REPORTING_DETAIL.Emp_ID
						GROUP BY T0090_EMP_REPORTING_DETAIL.Emp_ID
					)RE1 on 	re1.Row_ID = re.Row_ID
				INNER  JOIN T0080_EMP_MASTER e WITH (NOLOCK) on e.emp_id = R_Emp_ID
				where re.Emp_ID = @empid 
				
				insert into #final (empid,rid,rname,ename,desig,dept)
				values (@empid,@rid,@rname,@ename,@desig,@dept)				
		Fetch Next From cur into @empid,@ename,@desig,@dept
	end
close cur
deallocate cur
	
	
				  SELECT  e1.empid  ,
                            e1.ename  ,
                            ('<table width="100%" style="background-color:'+ case when e2.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td><img src="App_File/EMPIMAGES/' +(case when e2.image_name = '0.jpg' then case when e2.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else case when e2.image_name='' then case when gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e2.image_name,'Emp_default.png') end end) +'" width="60px" height="50px"/></td></tr><tr> <td style="font-size:8pt;font-family: Muli , sans-serif !important;color:Black;" align="left"><b>' + case when e2.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>Code:</b>'+ e2.alpha_emp_code +'<br/><b>Name:</b>'+e2.Emp_Full_Name + '<br/><b>Date Of Join:</b>'+ REPLACE(REPLACE(CONVERT(VARCHAR,e2.Date_Of_Join,106), ' ','-'), ',','') + '<br/><b>Designation:</b>' + d.desig_name + '<br/><b>Department:</b>' + ISNULL(DM.Dept_Name,'NA') + ' </td>'+ (case when emp_left = 'Y' then  '<td width="1%" valign="top"><img src="image_new/bstop.jpg" tooltip="Left Employee" /></td>'  else  '<td width="1%" style="display:none;" valign="top"><img src="image_new/bstop.jpg" /></td>'  end )+'</tr></table>')as Emp_Full_Name,i.desig_id,i.Dept_id				
				     	
                   FROM     #final e1
                            LEFT JOIN t0080_emp_master e2 WITH (NOLOCK) ON e1.rid = e2.emp_id 
                            LEFT join t0095_increment i WITH (NOLOCK) on i.emp_id = e2.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment WITH (NOLOCK) where emp_id = e2.emp_id)
							LEFT join t0040_designation_master d WITH (NOLOCK) on d.desig_id = i.desig_id
							Left outer join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = i.Dept_ID
							LEFT join T0010_COMPANY_MASTER c WITH (NOLOCK) on c.Cmp_Id=e2.Cmp_ID             
 
 
drop table #final
--declare @query as varchar(max)

--SET @query ='SELECT e.Emp_ID,
--				 ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+ 
--					''<tr><td align=center><img src=/App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
--					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
--					''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+e.Emp_Full_Name +''</td></tr>''+					
--					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
--					''</table>'' as ename,				
--				''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+
--					''<tr><td align=center><img src=/App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
--					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
--					''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+re.Emp_Full_Name +''</td></tr>''+					
--					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
--					''</table>'' as Emp_Full_Name					
--		,RE.Cmp_ID,ER.R_Emp_Id,IER.branch_id,IER.Dept_ID,IER.Grd_ID,IER.DESIG_ID
--		FROM  T0080_EMP_MASTER E INNER JOIN
--		--#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN
--		T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID and er.r_emp_id='+ cast(@emp_id as VARCHAR) +' INNER JOIN
--			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID 
--			 from T0090_EMP_REPORTING_DETAIL  inner JOIN
--				(select max(Effect_Date)Effect_Date,Emp_ID  
--				  from T0090_EMP_REPORTING_DETAIL
--				 where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and Effect_Date <= getdate()
--				GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID
--			where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' 
--			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID  INNER JOIN
--			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN
--			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--						FROM T0095_INCREMENT I INNER JOIN
--								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--								 FROM T0095_INCREMENT Inner JOIN
--										(
--												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--												FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +' GROUP BY EMP_ID
--										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--								 WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +'
--								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID
--						where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'
--				)IE on ie.Emp_ID = e.Emp_ID inner JOIN
--			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
--						FROM T0095_INCREMENT I INNER JOIN
--								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
--								 FROM T0095_INCREMENT Inner JOIN
--										(
--												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
--												FROM T0095_INCREMENT 
--												--WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'
--												GROUP BY EMP_ID
--										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
--								 --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'
--								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
--					   -- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'
--				)IER on IER.Emp_ID = RE.Emp_ID left JOIN
--				T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN
--				T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN
--				T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN
--				T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN
--				T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN
--				T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID 
--		where E.Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and E.Emp_Left<>''Y'' and er.r_emp_id='+ cast(@emp_id as VARCHAR) +' '
--		PRINT @query
--		exec (@query)

END

