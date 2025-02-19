  
  
  
  
  ---21/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[Get_Emp_Geneology_Chart_for_competent]  
 @cmpid as numeric(18,0)  
 ,@condition varchar(800)=''  
 ,@format int = 1 --added on 29/11/2017  
AS

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

BEGIN  

 if @condition=''  
  begin  
   set @condition='1=1'  
  end  
   
 create table #final  
(  
     empid numeric(18,0)  
    ,rid  numeric(18,0)  
    ,rname varchar(max)  
    ,ename varchar(max)  
    --,desig numeric(18,0)  
    --,deptid numeric(18,0)   
     ,cmpid numeric(18,0)  
)  
  
declare @emp_id as numeric(18,0)  
declare @rname as varchar(max)  
declare @ename as varchar(max)  
declare @rid as numeric(18,0)  
declare @desig as numeric(18,0)  
declare @deptid as numeric(18,0)  
declare @cid as numeric(18,0)  
  
  
  
--select e.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,ER.Effect_Date,ER.R_Emp_ID,re.Emp_Full_Name,re.Alpha_Emp_Code,RE.Cmp_ID  
--e.Alpha_Emp_Code+'-'+e.Emp_Full_Name ename,re.Alpha_Emp_Code+'-'+re.Emp_Full_Name Emp_Full_Name  
--,('<table width="100%" style="font-family:verdana;font-size:10px;color:#FFFFFF;font-weight:bold;">' +  
-- '<tr><td align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px" style="background-color:#F5F5F5;border-radius:50px;"/><hr></td></tr>'+  -- '<tr><td align="left"> Employee Name :'+ e.Alpha_Emp_Code +'-'+ e.Emp_Full_Name +'</td></tr>'+  -- '<tr><td align="left"> Branch :'+ isnull(BME.Branch_Name,'') +'</td></tr><tr><td align="left"> Designation :'+DGE.Desig_Name+'</td></tr>'+  -- '<tr><td align="left"> Department :'+isnull(DME.Dept_Name,'')+'</td></tr></table>') tooltip    
declare @query as varchar(max)  
  
if @format = 2  
 begin   
  set @query ='  
  Select e.Emp_ID,  
  (''<table width="100%" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:''+ case when e.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr> ''+   
  '' <td class="chart-node" data-title="<table width=100% style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;background-color:#f0f8ff;>''+   
     ''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60p
x height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+  
     ''<tr><td bgcolor=#bfbfbf height=0.5%></td></tr>''+  
     ''<tr><td align=left><b>Employee Name :</b>''+ e.Alpha_Emp_Code+''-''+e.Emp_Full_Name +''</td></tr>''+  
     ''<tr><td align=left><b>Branch  :</b>''+  isnull(BME.Branch_Name,'''') +''</td></tr>''+  
     ''<tr><td align=left><b>Designation  :</b>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+  
     ''<tr><td align=left><b>Department  :</b>''+  isnull(DME.Dept_Name,'''') +''</td></tr></table>">''   
   + e.Alpha_Emp_Code+''-''+e.Emp_Full_Name +''</td></tr></table>'')as ename  
  ,(''<table width="100%" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:''+ case when re.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr> ''+  
  '' <td class="chart-node" data-title="<table width=100% style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;background-color:#f0f8ff;>''+  
     ''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=
60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+  
     ''<tr><td bgcolor=#bfbfbf height=0.5%></td></tr>''+  
     ''<tr><td align=left><b>Employee Name :</b>''+ re.Alpha_Emp_Code+''-''+re.Emp_Full_Name +''</td></tr>''+  
     ''<tr><td align=left><b>Branch  :</b>''+  isnull(BMER.Branch_Name,'''') +''</td></tr>''+  
     ''<tr><td align=left><b>Designation  :</b>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+  
     ''<tr><td align=left><b>Department  :</b>''+  isnull(DMER.Dept_Name,'''') +''</td></tr></table>">''  
   + re.Alpha_Emp_Code+''-''+re.Emp_Full_Name +''</td></tr></table>'')as Emp_Full_Name  
  ,RE.Cmp_ID,ER.R_Emp_Id,IER.branch_id,IER.Dept_ID,IER.Grd_ID,IER.DESIG_ID  
  from T0080_EMP_MASTER E WITH (NOLOCK) left JOIN  
  T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) on er.Emp_ID = e.Emp_ID INNER JOIN  
   (select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID   
    from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK)  inner JOIN  
    (select max(Effect_Date)Effect_Date,Emp_ID    
      from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
     where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and Effect_Date <= getdate()  
    GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID  
   where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +'   
   GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID  INNER JOIN  
   T0080_EMP_MASTER RE WITH (NOLOCK) on re.Emp_ID = ER.R_Emp_ID Inner JOIN  
   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID  
      FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN  
        (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID  
         FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN  
          (  
            SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID   
            FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +' GROUP BY EMP_ID  
          ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID  
         WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +'  
         GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID  
      where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'  
    )IE on ie.Emp_ID = e.Emp_ID inner JOIN  
   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID  
      FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN  
        (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID  
         FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN  
          (  
            SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID   
            FROM T0095_INCREMENT WITH (NOLOCK)  
            --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'  
            GROUP BY EMP_ID  
          ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID  
         --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'  
         GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID  
        -- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'  
    )IER on IER.Emp_ID = RE.Emp_ID left JOIN  
    T0040_DESIGNATION_MASTER DGE WITH (NOLOCK) on DGE.Desig_ID = IE.Desig_Id left JOIN  
    T0040_DEPARTMENT_MASTER DME WITH (NOLOCK) on DME.Dept_Id = IE.Dept_ID left JOIN  
    T0030_BRANCH_MASTER BME WITH (NOLOCK) on BME.Branch_ID = IE.Branch_ID left JOIN  
    T0040_DESIGNATION_MASTER DGER WITH (NOLOCK) on DGER.Desig_ID = IER.Desig_Id left JOIN  
    T0040_DEPARTMENT_MASTER DMER WITH (NOLOCK) on DMER.Dept_Id = IER.Dept_ID left JOIN  
    T0030_BRANCH_MASTER BMER WITH (NOLOCK) on BMER.Branch_ID = IER.Branch_ID   
  where E.Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and E.Emp_Left<>''Y'' '  
 END  
ELSE IF @format = 1  
 BEGIN  
 SET @query ='SELECT e.Emp_ID,  
     ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+   
     ''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60p
x height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+  
     ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+  
     ''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+e.Emp_Full_Name +''</td></tr>''+       
     ''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+  
     ''</table>'' as ename,      
    ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+  
     ''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=
60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+  
     ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+  
     ''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+re.Emp_Full_Name +''</td></tr>''+       
     ''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+  
     ''</table>'' as Emp_Full_Name       
  ,RE.Cmp_ID,ER.R_Emp_Id,IER.branch_id,IER.Dept_ID,IER.Grd_ID,IER.DESIG_ID  
  FROM  T0080_EMP_MASTER E WITH (NOLOCK) left JOIN  
  T0090_EMP_REPORTING_DETAIL ER WITH (NOLOCK) on er.Emp_ID = e.Emp_ID INNER JOIN  
   (select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID   
    from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) inner JOIN  
    (select max(Effect_Date)Effect_Date,Emp_ID    
      from T0090_EMP_REPORTING_DETAIL WITH (NOLOCK) 
     where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and Effect_Date <= getdate()  
    GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID  
   where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +'   
   GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID  INNER JOIN  
   T0080_EMP_MASTER RE WITH (NOLOCK) on re.Emp_ID = ER.R_Emp_ID Inner JOIN  
   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID  
      FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN  
        (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID  
         FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN  
          (  
            SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID   
            FROM T0095_INCREMENT WITH (NOLOCK) WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +' GROUP BY EMP_ID  
          ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID  
         WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +'  
         GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID  
      where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'  
    )IE on ie.Emp_ID = e.Emp_ID inner JOIN  
   (SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID  
      FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN  
        (SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID  
         FROM T0095_INCREMENT WITH (NOLOCK) Inner JOIN  
          (  
            SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID   
            FROM T0095_INCREMENT WITH (NOLOCK)  
            --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'  
            GROUP BY EMP_ID  
          ) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID  
         --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'  
         GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID  
        -- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'  
    )IER on IER.Emp_ID = RE.Emp_ID left JOIN  
    T0040_DESIGNATION_MASTER DGE WITH (NOLOCK) on DGE.Desig_ID = IE.Desig_Id left JOIN  
    T0040_DEPARTMENT_MASTER DME WITH (NOLOCK) on DME.Dept_Id = IE.Dept_ID left JOIN  
    T0030_BRANCH_MASTER BME WITH (NOLOCK) on BME.Branch_ID = IE.Branch_ID left JOIN  
    T0040_DESIGNATION_MASTER DGER WITH (NOLOCK) on DGER.Desig_ID = IER.Desig_Id left JOIN  
    T0040_DEPARTMENT_MASTER DMER WITH (NOLOCK) on DMER.Dept_Id = IER.Dept_ID left JOIN  
    T0030_BRANCH_MASTER BMER WITH (NOLOCK) on BMER.Branch_ID = IER.Branch_ID   
  where E.Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and E.Emp_Left<>''Y'' '  
 END  
print @query  
----''<tr><td align=left>Branch  :''+  isnull(BME.Branch_Name,'''') +''</td></tr>''+  
--''<tr><td align=left>Department  :''+  isnull(DME.Dept_Name,'''') +''</td></tr>  
--''<tr><td align=left>Branch  :''+  isnull(BMER.Branch_Name,'''') +''</td></tr>''+  
--''<tr><td align=left>Department  :''+  isnull(DMER.Dept_Name,'''') +''</td></tr>  
exec (@query + ' and ' + @condition)  
END  
----------------------------------------------------------------------------------------------------------  
--create table #empdetails  
--(  
-- emp_id  numeric(18,0)  
--)   
  
--declare @query as varchar(max)  
--set @query=  
--select E.emp_id from   
--T0080_EMP_MASTER E inner JOIN  
--T0095_INCREMENT I on i.Emp_ID = e.Emp_ID and I.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=e.emp_id and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=e.Emp_ID)) left JOIN  
--T0040_DESIGNATION_MASTER Dg on Dg.Desig_ID = i.Desig_Id left JOIN  
--T0040_DEPARTMENT_MASTER D on d.Dept_Id = i.Dept_ID left JOIN  
--T0030_BRANCH_MASTER B on b.Branch_ID = i.Branch_ID  
--Where e.cmp_id=' + cast(@cmpid as varchar(18)) + ' and Emp_Left<>''Y'''  
  
  
--insert into #empdetails  
--EXEC (@query + ' and ' +@condition)  
  
  
--DECLARE @rcondition  VARCHAR(800)  
--set @rcondition = REPLACE(@condition,'i.','ir.')  
  
  
  
--declare cur cursor  
--for   
-- select Emp_ID from #empdetails   
--open cur  
--fetch next from cur into @emp_id  
--while @@fetch_status=0  
-- begin   
--  if Not exists(select 1 from T0090_EMP_REPORTING_DETAIL where Emp_ID=@emp_id)  
--   BEGIN      
--    INSERT into #final  
--    select E.Emp_ID,0,'',('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')as Emp_Full_Name,@cmpid   
--    FROM T0080_EMP_MASTER E inner Join   
--      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   
--      I.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=@emp_id and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=@emp_id))left JOIN  
--      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  
--      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID  
--    WHERE  E.Emp_ID = @emp_id  
--   END  
--  Else  
--   BEGIN  
--    --SELECT @rid=R_Emp_ID  from T0090_EMP_REPORTING_DETAIL where Emp_ID= @emp_id  
--    --and Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=@emp_id)  
--    set @query =''  
--    --INSERT into #final  
--    set @query ='select E.Emp_ID,R.R_Emp_ID,(''<table width="100%" style="background-color:''+ case when er.cmp_id <>' + cast(@cmpid  as varchar(18)) +'then ''#E6DAF1'' else '''' end +''"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/'' +(case when er.image_name = ''0.jpg'' then case when er.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(er.image_name,''Emp_default.png'') end) +''" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>'' + case when er.cmp_id = ' + cast(@cmpid  as varchar(18)) +' then '''' else Cr.cmp_name end  + ''</b><br/><b>''+er.alpha_emp_code+''-''+er.Emp_Full_Name + ''</b><br/><b>Desig:</b>'' + dr.desig_name + '' </td></tr></table>'')as Emp_Full_Name,  
--     (''<table width="100%" style="background-color:''+ case when e.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +''" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>'' + case when e.cmp_id = ' + cast(@cmpid  as varchar(18)) +' then '''' else C.cmp_name end  + ''</b><br/><b>''+e.alpha_emp_code+''-''+e.Emp_Full_Name + ''</b><br/><b>Desig:</b>'' + d.desig_name + '' </td></tr></table>'')as Emp_Full_Name,' + cast(@cmpid  as varchar(18)) +'  
--    FROM T0080_EMP_MASTER E inner Join  
--      T0090_EMP_REPORTING_DETAIL R on R.Emp_ID = E.Emp_ID AND   --      R.Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=' + cast(@emp_id  as varchar(18)) +') inner JOIN  --      T0080_EMP_MASTER ER on ER.Emp_ID = R.R_Emp_ID and Er.Emp_Left <> ''Y'' inner Join   --      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   --      I.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=' + cast(@emp_id  as varchar(18)) +' and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=' + cast(@emp_id  as varchar(18)) +')) inner JOIN  
--      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  --      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID inner Join        
--       T0095_INCREMENT IR on IR.Emp_ID = ER.Emp_ID and   
--       IR.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=ER.emp_id and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=ER.emp_id)) left join  
--      T0040_DESIGNATION_MASTER DR on DR.Desig_ID = IR.Desig_Id inner JOIN  
--      T0010_COMPANY_MASTER CR on CR.Cmp_Id = ER.Cmp_ID  
--    WHERE CR.is_GroupOFCmp=1 and c.is_GroupOFCmp=1 and E.Emp_ID ='+ cast(@emp_id as varchar(18))  
      
      
--     INSERT into #final      
--     exec(@query + 'and' + @condition + 'or' +  @rcondition)  
--   END  
--  if EXISTS(select 1 from T0090_EMP_REPORTING_DETAIL where R_Emp_ID=@emp_id and Cmp_ID <> @cmpid)  
--   BEGIN  
--    set @query =''     
--    set @query ='select E.Emp_ID,R.R_Emp_ID,(''<table width="100%" style="background-color:''+ case when er.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/'' +(case when er.image_name = ''0.jpg'' then case when er.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(er.image_name,''Emp_default.png'') end) +''" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>'' + case when er.cmp_id = ' + cast(@cmpid  as varchar(18)) +' then '''' else Cr.cmp_name end  + ''</b><br/><b>''+er.alpha_emp_code+''-''+er.Emp_Full_Name + ''</b><br/><b>Desig:</b>'' + dr.desig_name + '' </td></tr></table>'')as Emp_Full_Name,  --    (''<table width="100%" style="background-color:''+ case when e.cmp_id <>' + cast(@cmpid  as varchar(18)) +'then ''#E6DAF1'' else '''' end +''"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +''" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>'' + case when e.cmp_id =' + cast(@cmpid  as varchar(18)) +' then '''' else c.cmp_name end  + ''</b><br/><b>''+e.alpha_emp_code+''-''+e.Emp_Full_Name + ''</b><br/><b>Desig:</b>'' + d.desig_name + '' </td></tr></table>'')as Emp_Full_Name,e.Cmp_ID   
--    FROM T0080_EMP_MASTER E inner Join  --      T0090_EMP_REPORTING_DETAIL R on R.Emp_ID = E.Emp_ID AND   
--      R.Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=e.Emp_ID) inner JOIN  
--      T0080_EMP_MASTER ER on ER.Emp_ID = R.R_Emp_ID and Er.Emp_Left <> ''Y'' inner Join   
--      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   
--      I.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=' + cast(@emp_id  as varchar(18)) +' and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=' + cast(@emp_id  as varchar(18)) +')) inner JOIN  --      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  --      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID inner Join        
--      T0095_INCREMENT IR on IR.Emp_ID = ER.Emp_ID and   --       IR.Increment_ID = (select max(Increment_ID) from T0095_INCREMENT where emp_id=ER.emp_id and Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where emp_id=ER.emp_id)) inner JOIN  
--      T0040_DESIGNATION_MASTER DR on DR.Desig_ID = IR.Desig_Id inner JOIN  
--      T0010_COMPANY_MASTER CR on CR.Cmp_Id = ER.Cmp_ID  
--     WHERE CR.is_GroupOFCmp=1 and c.is_GroupOFCmp=1 and ER.Emp_ID ='+ cast(@emp_id as varchar(18))  
     
       
--     INSERT into #final        
--     exec(@query + 'and' + @condition + 'or' +  @rcondition)  
--   END  
--  fetch next from cur into @emp_id  
-- end   
--close cur  
--deallocate cur  
  
  
  
--select empid,ename as ename,rname as emp_full_name,cmpid from #final  
  
  
--set @query =select empid,ename as ename,rname as emp_full_name,cmpid    
--  from #final Ef inner Join T0095_INCREMENT i on i.Emp_ID = ef.empid  
--   and i.Increment_Effective_Date =(select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID = ef.empid)'  
--print(@query +' where '+ @condition)  
  
--EXEC(@query)  
  
--drop TABLE #empdetails  
--drop TABLE #final  
  
  
  
------------------------------------------------------  
--declare cur  cursor  
-- for  
--   select  e.emp_id,  
--    --('<img src="../App_File/EMPIMAGES/' + (case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) + '" width="100px" height="100px"/><br/><b>Emp Name:</b> '+e.alpha_emp_code+'-'+e.Emp_Full_Name + '<br/> <b>Desig:</b> ' + d.desig_name) as Emp_Full_Name,i.desig_id   --    ('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')as Emp_Full_Name,i.desig_id       
--        ,i.dept_id,@cmpid  --   from T0080_EMP_MASTER e left join t0095_increment i on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = e.emp_id)  
--   inner join t0040_designation_master d on d.desig_id = i.desig_id   
--   inner join T0010_COMPANY_MASTER c on c.Cmp_Id=e.Cmp_ID  
--   where e.cmp_id=@cmpid   and  Emp_Left<>'Y'  --  
--   order by e.emp_id  
--  open cur  
--  Fetch Next From cur into @empid,@ename,@desig,@deptid,@cid  
--  WHILE @@FETCH_STATUS = 0  
--   begin              
--    if Not exists (select 1 from T0090_EMP_REPORTING_DETAIL where Emp_ID=@empid)  
--     begin  
--      insert into #final (empid,rid,rname,ename,desig,deptid,cmpid)  
--      values (@empid,0,'',@ename,@desig,@deptid,@cmpid)  
--     End      
--    Else  
--     begin  
--      --select top 1 @rid = R_Emp_ID from T0090_EMP_REPORTING_DETAIL where Emp_ID = @empid and Reporting_Method='direct'  
--      select  @rid = R_Emp_ID,@rname= Emp_Full_Name from T0090_EMP_REPORTING_DETAIL   
--      inner join t0080_emp_master e on e.emp_id = R_Emp_ID  
--      where T0090_EMP_REPORTING_DETAIL.Emp_ID = @empid --and Reporting_Method='direct'  
--      and effect_date = (select max(effect_date) from T0090_EMP_REPORTING_DETAIL where emp_id=@empid)  
--      insert into #final (empid,rid,rname,ename,desig,deptid,cmpid)  
--      values (@empid,@rid,@rname,@ename,@desig,@deptid,@cmpid)  
        
--      ---added for cross cmpny check  
--      if exists(select 1 from T0080_EMP_MASTER where Emp_ID = @rid and Cmp_ID<>@cmpid and emp_left<>'Y')  
--       begin   
--        declare @tempid  numeric(18,0)  
--        select @tempid= r_emp_id from T0090_EMP_REPORTING_DETAIL where emp_id = @rid   
--         and effect_date = (select max(effect_date) from T0090_EMP_REPORTING_DETAIL where emp_id=@rid)  
          
--        if exists(select 1 from T0080_EMP_MASTER where Emp_ID = @tempid and Cmp_ID=@cmpid and emp_left<>'Y')  
--         begin   
--          declare @tempcmp_id numeric(18,0)  
--          select @rname=('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')  
--          ,@tempcmp_id= e.Cmp_ID  
--          from t0080_emp_master e   
--          left join t0095_increment i on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = @rid)  
--          inner join t0040_designation_master d on d.desig_id = i.desig_id   
--          inner join T0010_COMPANY_MASTER c on c.Cmp_Id=e.Cmp_ID  
--          where e.Emp_ID=@rid  
               
                                 
--          insert into #final (empid,rid,rname,ename,desig,deptid,cmpid)  
--          select  @rid,R_Emp_ID, emp_full_name,@rname,            
--          i.Desig_ID,i.Dept_ID,@tempcmp_id    
--          from T0090_EMP_REPORTING_DETAIL   
--          inner join t0080_emp_master e on e.emp_id = R_Emp_ID  
--          left join t0095_increment i on i.emp_id = e.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = e.emp_id)  
--          inner join t0040_designation_master d on d.desig_id = i.desig_id   
--          inner join T0010_COMPANY_MASTER c on c.Cmp_Id=e.Cmp_ID  
--          where T0090_EMP_REPORTING_DETAIL.Emp_ID = @rid --and Reporting_Method='direct'  
--          and effect_date = (select max(effect_date) from T0090_EMP_REPORTING_DETAIL where emp_id=@rid)  
--         end  
--       end  
--     End  
--    Fetch Next From cur into @empid,@ename,@desig,@deptid,@cid  
--   end  
--  close cur  
-- deallocate cur  
   
   
-- declare @query as varchar(max)  
-- set @query =''  
-- declare @query1 as varchar(max)  
-- set @query1 =''  
   
-- set @query = '( SELECT   e1.empid  ,  
--                            e1.ename  ,  
--                            (''<table width="100%" style="background-color:''+ case when e2.cmp_id <>' + CAST(@cmpid as varchar(18)) + 'then ''#E6DAF1'' else '''' end +''"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/'' +(case when e2.image_name = ''0.jpg'' then case when e2.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e2.image_name,''Emp_default.png'') end) +''" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>'' + case when e2.cmp_id = '+ CAST(@cmpid as varchar(18)) +' then '''' else c.cmp_name end  + ''</b><br/><b>''+e2.alpha_emp_code+''-''+e2.Emp_Full_Name + ''</b><br/><b>Desig:</b>'' + d.desig_name + '' </td></tr></table>'')as Emp_Full_Name,i.desig_id     --                         ,e1.cmpid    
--                   FROM     #final e1  --                            LEFT JOIN t0080_emp_master e2 ON e1.rid = e2.emp_id   
--                            inner join t0095_increment i on i.emp_id = e2.emp_id and i.increment_id = (select max(increment_id)  from t0095_increment where emp_id = e2.emp_id)  
--       inner join t0040_designation_master d on d.desig_id = i.desig_id  
--       inner join T0010_COMPANY_MASTER c on c.Cmp_Id=e2.Cmp_ID'  
                   
--  set @query1=  'SELECT  ''[''  
--                + STUFF((SELECT '',{"id":'' + CAST(empid AS VARCHAR(MAX))  
--                                + '',"Ename":"'' + ename + ''"'' + '',"Manager":"''  
--                                + CAST(rname AS VARCHAR(MAX)) + ''"'' + ''}''  
--                         FROM   #final t1  
--                FOR     XML PATH('''') ,  
--                            TYPE  
--    ).value(''.'', ''varchar(max)''), 1, 1, '''') + '']'' as hier'  
  
  
--exec (@query + ' where ' + @condition +')'+ @query1 )  
  
  
--drop table #final  
  
----declare cur cursor  
----for   
---- select Emp_ID from T0080_EMP_MASTER where Cmp_ID = @cmpid and Emp_Left<>'Y'  
----open cur  
----fetch next from cur into @emp_id  
----while @@fetch_status=0  
---- begin  
----  if Not exists(select 1 from T0090_EMP_REPORTING_DETAIL where Emp_ID=@emp_id)  
----   BEGIN  
----    INSERT into #final  
----    select E.Emp_ID,0,'',('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')as Emp_Full_Name,@cmpid   
----    FROM T0080_EMP_MASTER E inner Join   
----      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   
----      i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =@emp_id)inner JOIN  
----      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  
----      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID  
----    WHERE  E.Emp_ID = @emp_id  
----   END  
----  Else  
----   BEGIN  
----    --SELECT @rid=R_Emp_ID  from T0090_EMP_REPORTING_DETAIL where Emp_ID= @emp_id  
----    --and Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=@emp_id)  
----    INSERT into #final  
----    select E.Emp_ID,R.R_Emp_ID,('<table width="100%" style="background-color:'+ case when er.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when er.image_name = '0.jpg' then case when er.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(er.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when er.cmp_id = @cmpid then '' else Cr.cmp_name end  + '</b><br/><b>'+er.alpha_emp_code+'-'+er.Emp_Full_Name + '</b><br/><b>Desig:</b>' + dr.desig_name + ' </td></tr></table>')as Emp_Full_Name,  
----     ('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else C.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')as Emp_Full_Name,@cmpid   
----    FROM T0080_EMP_MASTER E inner Join  
----      T0090_EMP_REPORTING_DETAIL R on R.Emp_ID = E.Emp_ID AND   
----      R.Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=@emp_id) inner JOIN  
----      T0080_EMP_MASTER ER on ER.Emp_ID = R.R_Emp_ID and Er.Emp_Left <> 'Y' inner Join   
----      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   
----      i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =@emp_id)inner JOIN  
----      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  
----      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID inner Join        
----       T0095_INCREMENT IR on IR.Emp_ID = ER.Emp_ID and   
----      IR.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =ER.emp_id)inner JOIN  
----      T0040_DESIGNATION_MASTER DR on DR.Desig_ID = IR.Desig_Id inner JOIN  
----      T0010_COMPANY_MASTER CR on CR.Cmp_Id = ER.Cmp_ID  
----    WHERE  E.Emp_ID = @emp_id  
----   END  
----  if EXISTS(select 1 from T0090_EMP_REPORTING_DETAIL where R_Emp_ID=@emp_id and Cmp_ID <> @cmpid)  
----   BEGIN  
----    INSERT into #final  
----    select E.Emp_ID,R.R_Emp_ID,('<table width="100%" style="background-color:'+ case when er.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when er.image_name = '0.jpg' then case when er.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(er.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when er.cmp_id = @cmpid then '' else Cr.cmp_name end  + '</b><br/><b>'+er.alpha_emp_code+'-'+er.Emp_Full_Name + '</b><br/><b>Desig:</b>' + dr.desig_name + ' </td></tr></table>')as Emp_Full_Name,  
----    ('<table width="100%" style="background-color:'+ case when e.cmp_id <> @cmpid then '#E6DAF1' else '' end +'"><tr valign="top"><td width="30%" align="center"><img src="../App_File/EMPIMAGES/' +(case when e.image_name = '0.jpg' then case when e.gender ='F' then 'Emp_Default_Female.png' else 'Emp_default.png' end else isnull(e.image_name,'Emp_default.png') end) +'" width="60px" height="50px"/></td> </tr><tr><td style="font-size:9px;font-family:Verdana;color:Black;" align="left"><b>' + case when e.cmp_id = @cmpid then '' else c.cmp_name end  + '</b><br/><b>'+e.alpha_emp_code+'-'+e.Emp_Full_Name + '</b><br/><b>Desig:</b>' + d.desig_name + ' </td></tr></table>')as Emp_Full_Name,e.Cmp_ID   
----    FROM T0080_EMP_MASTER E inner Join  
----      T0090_EMP_REPORTING_DETAIL R on R.Emp_ID = E.Emp_ID AND   
----      R.Effect_Date = (select max(Effect_Date) from T0090_EMP_REPORTING_DETAIL where emp_id=e.Emp_ID) inner JOIN  
----      T0080_EMP_MASTER ER on ER.Emp_ID = R.R_Emp_ID and Er.Emp_Left <> 'Y' inner Join   
----      T0095_INCREMENT I on I.Emp_ID = E.Emp_ID and   
----      i.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =e.emp_Id)inner JOIN  
----      T0040_DESIGNATION_MASTER D on D.Desig_ID = I.Desig_Id inner JOIN  
----      T0010_COMPANY_MASTER C on C.Cmp_Id = E.Cmp_ID inner Join        
----      T0095_INCREMENT IR on IR.Emp_ID = ER.Emp_ID and   
----      IR.Increment_Effective_Date = (select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID =ER.emp_id)inner JOIN  
----      T0040_DESIGNATION_MASTER DR on DR.Desig_ID = IR.Desig_Id inner JOIN  
----      T0010_COMPANY_MASTER CR on CR.Cmp_Id = ER.Cmp_ID  
----     WHERE  ER.Emp_ID = @emp_id  
----   END  
----  fetch next from cur into @emp_id  
---- end   
----close cur  
----deallocate cur  
  
----declare @query as varchar(max)  
---- set @query =''  
  
----set @query ='select empid,ename as ename,rname as emp_full_name,cmpid    
----  from #final Ef inner Join T0095_INCREMENT i on i.Emp_ID = ef.empid  
----   and i.Increment_Effective_Date =(select max(Increment_Effective_Date) from T0095_INCREMENT where Emp_ID = ef.empid)'  
------print(@query +' where '+ @condition)  
  
----EXEC(@query +' where '+ @condition)  
  
----drop TABLE #final  
  
  