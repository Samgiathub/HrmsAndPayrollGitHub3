
CREATE  PROCEDURE [dbo].[Get_Emp_Geneology_Chart]    
@cmpid as numeric(18,0)    
,@condition varchar(800)=''    
,@format int = 1 --added on 29/11/2017    
,@Branch_ID varchar(2000)=''    
,@Desig_ID varchar(2000)=''    
,@Grd_ID varchar(2000)=''    
,@Dept_ID varchar(2000)=''
,@Category_ID VARCHAR(2000)=''
,@Search_Emp_ID int = 0    
AS    
BEGIN    
SET NOCOUNT ON;    
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;    
SET ARITHABORT ON;    
if @condition=''    
begin    
set @condition=' 1=1'    
end    
CREATE table #Emp_Cons    
(    
Emp_ID NUMERIC ,    
Branch_ID NUMERIC,    
Increment_ID NUMERIC    
)    
DECLARE @fromdate as datetime    
set @fromdate=getdate()    
exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @cmpid,@fromdate,@fromdate,@Branch_ID,'',@Grd_ID,'',@Dept_ID,@Desig_ID,@Search_Emp_ID,'',0,0,'','','','',0,0,0,'0',0,0 --Change By Jaina 1-10-2015    
-- create table #final    
--(    
-- empid numeric(18,0)    
-- ,rid numeric(18,0)    
-- ,rname varchar(max)    
-- ,ename varchar(max)    
-- --,desig numeric(18,0)    
-- --,deptid numeric(18,0)    
-- ,cmpid numeric(18,0)    
--)    
declare @emp_id as numeric(18,0)    
declare @rname as varchar(max)    
declare @ename as varchar(max)    
declare @rid as numeric(18,0)    
declare @desig as numeric(18,0)    
declare @deptid as numeric(18,0)    
declare @cid as numeric(18,0)    
--select e.Emp_ID,E.Emp_Full_Name,E.Alpha_Emp_Code,ER.Effect_Date,ER.R_Emp_ID,re.Emp_Full_Name,re.Alpha_Emp_Code,RE.Cmp_ID    
--e.Alpha_Emp_Code+'-'+e.Emp_Full_Name ename,re.Alpha_Emp_Code+'-'+re.Emp_Full_Name Emp_Full_Name    
--,('' + '+ '+ '+    
-- '"50px" style="background-color:#F5F5F5;border-radius:50px;"/>    
-- 'Employee Name :'+ e.Alpha_Emp_Code +'-'+ e.Emp_Full_Name +'    
-- 'Branch :'+ isnull(BME.Branch_Name,'') +'Designation :'+DGE.Desig_Name+'    
-- 'Department :'+isnull(DME.Dept_Name,'')+'') tooltip    
declare @query as varchar(max)    
DECLARE @columns VARCHAR(MAX)    
DECLARE @queryUpdate VARCHAR(MAX)    
CREATE table #Emp_Details    
(    
Emp_ID INT ,    
Emp_Name VARCHAR(200),    
Sup_ID INT,    
Sup_Name VARCHAR(MAX),    
Emp_Group VARCHAR(MAX),    
Row_ID INT,    
Group_Length INT,    
Emp_Desig VARCHAR(200),    
Sup_Desig VARCHAR(200),    
dept_id INT,    
desig_id int,    
branch_Id int,    
Grd_Id int,    
Sup_dept_id INT,    
Sup_desig_id int,    
Sup_branch_Id int,    
Sup_Grd_Id int    
)    
if @format = 2    
begin    
--set @query ='    
--Select e.Emp_ID,    
--('' ''+    
--'' ''    
--+ e.Alpha_Emp_Code+''-''+ Replace(e.Emp_Full_Name,char(39),'''') +''    
--'')as ename    
--,('' ''+    
--'' ''    
--+ re.Alpha_Emp_Code+''-''+ Replace(re.Emp_Full_Name,char(39),'''') +''    
--'')as Emp_Full_Name,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,    
--RE.Cmp_ID,ER.R_Emp_Id,IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID    
--from T0080_EMP_MASTER E INNER JOIN    
--#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
--T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
--(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
--from T0090_EMP_REPORTING_DETAIL inner JOIN    
--(select max(Effect_Date)Effect_Date,Emp_ID    
--from T0090_EMP_REPORTING_DETAIL    
--where Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and Effect_Date <= getdate()    
--GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
--where Cmp_ID = ' + cast(@cmpid as VARCHAR) +'    
--GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
--T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
--(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
--FROM T0095_INCREMENT I INNER JOIN    
--(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
--FROM T0095_INCREMENT Inner JOIN    
--(    
--SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
--FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +' GROUP BY EMP_ID    
--) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
--GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
--where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
--)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
--(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
--FROM T0095_INCREMENT I INNER JOIN    
--(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
--FROM T0095_INCREMENT Inner JOIN    
--(    
--SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
--FROM T0095_INCREMENT    
----WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
--GROUP BY EMP_ID    
--) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
----WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
--GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
---- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
--)IER on IER.Emp_ID = RE.Emp_ID left JOIN    
--T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN    
--T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN    
--T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
--T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
--T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN    
--T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID    
--where E.Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and E.Emp_Left<>''Y'' ' 

set @query ='
		Select e.Emp_ID,
		(''<table width="100%" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:''+ case when e.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr> ''+ 
		'' <td class="chart-node" data-title="<table width=100% style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;background-color:#f0f8ff;>''+ 
					''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td bgcolor=#bfbfbf height=0.5%></td></tr>''+
					''<tr><td align=left><b>Employee Name :</b>''+ e.Alpha_Emp_Code+''-''+ Replace(e.Emp_Full_Name,char(39),'''') +''</td></tr>''+
					''<tr><td align=left><b>Branch  :</b>''+  isnull(BME.Branch_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Designation  :</b>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Department  :</b>''+  isnull(DME.Dept_Name,'''') +''</td></tr></table>">'' 
			+ e.Alpha_Emp_Code+''-''+ Replace(e.Emp_Full_Name,char(39),'''') +''</td></tr></table>'')as ename
		,(''<table width="100%" style="font-family:verdana;font-size:10px;color:#444444;font-weight:bold;background-color:''+ case when re.cmp_id <> ' + cast(@cmpid  as varchar(18)) +' then ''#E6DAF1'' else '''' end +''"><tr> ''+
		'' <td class="chart-node" data-title="<table width=100% style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;background-color:#f0f8ff;>''+
					''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td bgcolor=#bfbfbf height=0.5%></td></tr>''+
					''<tr><td align=left><b>Employee Name :</b>''+ re.Alpha_Emp_Code+''-''+ Replace(re.Emp_Full_Name,char(39),'''') +''</td></tr>''+
					''<tr><td align=left><b>Branch  :</b>''+  isnull(BMER.Branch_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Designation  :</b>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Department  :</b>''+  isnull(DMER.Dept_Name,'''') +''</td></tr></table>">''
			+ re.Alpha_Emp_Code+''-''+ Replace(re.Emp_Full_Name,char(39),'''') +''</td></tr></table>'')as Emp_Full_Name,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
		RE.Cmp_ID,ER.R_Emp_Id,IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID
		from T0080_EMP_MASTER E INNER JOIN
		#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN
		T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID 
			 from T0090_EMP_REPORTING_DETAIL  inner JOIN
				(select max(Effect_Date)Effect_Date,Emp_ID  
				  from T0090_EMP_REPORTING_DETAIL
				 where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and Effect_Date <= getdate()
				GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID
			where Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' 
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID  INNER JOIN
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
						FROM T0095_INCREMENT I INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
								 FROM T0095_INCREMENT Inner JOIN
										(
												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
												FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +' GROUP BY EMP_ID
										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
								 WHERE CMP_ID = ' + cast(@cmpid as VARCHAR)  +'
								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID        AND I.INCREMENT_ID = QRY.INCREMENT_ID
						where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'
				)IE on ie.Emp_ID = e.Emp_ID inner JOIN
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID
						FROM T0095_INCREMENT I INNER JOIN
								(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID
								 FROM T0095_INCREMENT Inner JOIN
										(
												SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID 
												FROM T0095_INCREMENT 
												--WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'
												GROUP BY EMP_ID
										) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID
								 --WHERE CMP_ID =  ' + cast(@cmpid as VARCHAR)  +'
								 GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID
					   -- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR)  +'
				)IER on IER.Emp_ID = RE.Emp_ID left JOIN
				T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN
				T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN
				T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN
				T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN
				T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN
				T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID 
		where E.Cmp_ID = ' + cast(@cmpid as VARCHAR)  +' and E.Emp_Left<>''Y'' '
		print @query

		
exec (@query)    
END    
ELSE IF @format = 1    
BEGIN    
--print 3333    -----mansi

--old Qry - Deepali - 18052023-Start 
SET @query ='SELECT e.Emp_ID,    
 ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+ 
''<tr><td align=center><img  src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' onerror ="this.src =../App_File/EMPIMAGES/Emp_Default.png" width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+    
    ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
	''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+REPLACE(e.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
					''</table>'' as ename,	
					''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+
					''<tr><td align=center><img  src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' onerror ="this.src =../App_File/EMPIMAGES/Emp_Default.png" width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
					''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+REPLACE(re.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
					''</table>'' as Emp_Full_Name					
		,RE.Cmp_ID,ER.R_Emp_Id,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
		IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID
 
			FROM T0080_EMP_MASTER E INNER JOIN    
			#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
			T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
			from T0090_EMP_REPORTING_DETAIL inner JOIN    
			(select max(Effect_Date)Effect_Date,Emp_ID    
			from T0090_EMP_REPORTING_DETAIL    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and Effect_Date <= getdate()    
			GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +' GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			-- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IER on IER.Emp_ID = RE.Emp_ID left JOIN    
			T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN    
			T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
			T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN    
			T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID    
			where E.Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and E.Emp_Left<>''Y'' ' 
 --print @query

 --End-18052023

 print @query
print @condition
  
exec (@query + ' and ' + @condition)    


END    
ELSE IF @format = 3    
begin    
--select * from #Emp_Cons    
INSERT INTO #Emp_Details    
Select DISTINCT e.Emp_ID,ISNULL(E.Emp_First_Name,'') +' '+ ISNULL(E.Emp_Second_Name,'')+' '+ ISNULL(E.Emp_Last_Name,'') +'-'+ ISNULL(CM.Cat_Name,''),ER.R_Emp_Id,    
ISNULL(RE.Emp_First_Name,'') +' '+ ISNULL(RE.Emp_Second_Name,'')+' '+ ISNULL(RE.Emp_Last_Name,'') +'-'+ ISNULL(CMER.Cat_Name,'') ,'',    
ROW_NUMBER() OVER(Partition by ER.R_Emp_Id ORDER BY E.Emp_ID),    
1,DGE.Desig_Name,DGER.Desig_Name,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,    
IER.Dept_ID,IER.Desig_Id,IER.Branch_ID,IER.Grd_ID    
from T0080_EMP_MASTER E INNER JOIN    
#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID and er.cmp_id=e.cmp_id INNER JOIN    
(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
from T0090_EMP_REPORTING_DETAIL inner JOIN    
(select max(Effect_Date)Effect_Date,Emp_ID    
from T0090_EMP_REPORTING_DETAIL    
where Cmp_ID = @cmpid and Effect_Date <= getdate()    
GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
where Cmp_ID =@cmpid    
GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID AND RE.CMP_ID=ER.CMP_ID INNER JOIN    
T0095_INCREMENT IE ON IE.Emp_ID=E.Emp_ID AND IE.Increment_ID=E.Increment_ID INNER JOIN    
T0095_INCREMENT IER ON IER.Emp_ID=RE.Emp_ID AND IER.Increment_ID=RE.Increment_ID left JOIN    
T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN    
T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN    
T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN    
T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID left JOIN    
T0030_CATEGORY_MASTER CMER on CMER.Cat_ID = IER.Cat_ID LEFT JOIN    
T0030_CATEGORY_MASTER CM on CM.Cat_ID = IE.Cat_ID    
where E.Cmp_ID =@cmpid and E.Emp_Left<> 'Y' --AND E.Emp_ID IN(109,75,73,131,99) --ORDER by R_Emp_Id    
--SELECT * from #Emp_Details    
--select COUNT(Emp_ID)as ctr from #Emp_Details --ORDER by Emp_ID    
UPDATE ED    
SET Emp_Group= (STUFF((SELECT ',' + REPLACE(REPLACE(REPLACE(Emp_Name , CHAR(10), ' '), CHAR(13), ''),char(39),'')    
FROM #Emp_Details ED1    
WHERE ED1.Sup_ID=ED.Sup_ID    
AND NOT EXISTS(SELECT 1 FROM #Emp_Details ED2 WHERE ED1.Emp_ID=ED2.Sup_ID)    
GROUP by ED1.Emp_Name --ED1.Emp_Desig,    
FOR XML Path('')),1,1,'')    
)    
FROM #Emp_Details ED where ED.Row_ID=1    
UPDATE ED    
SET Group_Length=MemberCount    
FROM #Emp_Details ED    
INNER JOIN (SELECT ED2.Sup_ID, COUNT(1) AS MemberCount    
FROM #Emp_Details ED2    
--WHERE NOT EXISTS(SELECT 1 FROM #Emp_Details ED WHERE ED2.Emp_ID=ED.Sup_ID)    
GROUP BY Sup_ID) ED2 ON ED2.Sup_ID=ED.Sup_ID    
SELECT CASE WHEN ED.Group_Length > 1 Then ED.Emp_Group Else ED.Emp_Name End As Display_Name, *    
INTO #FINAL    
FROM #Emp_Details ED    
WHERE ED.Row_ID=1    
ORDER BY ED.Emp_ID    
--select * from #FINAL    
--select 112,* from #FINAL    
INSERT INTO #FINAL --insert employee who is superior,his team exist    
SELECT DISTINCT Emp_Name, F1.Emp_ID,EMp_name,Sup_ID,Sup_Name,Emp_Group,Row_ID,Group_Length,Emp_Desig,    
Sup_desig,Dept_ID,Desig_ID,Branch_ID,Grd_ID,Sup_dept_id,Sup_desig_id,Sup_branch_Id,Sup_Grd_Id    
FROM #Emp_Details F1    
WHERE --NOT EXISTS(SELECT 1 FROM #FINAL F2 WHERE F1.Emp_ID=F2.Emp_ID )    
EXISTS(SELECT 1 FROM #FINAL F2 WHERE F1.Emp_ID=F2.Sup_ID )AND    
Group_Length > 1 --and F1.Emp_ID=564    
--Update #Final    
--Set Display_Name = Replace(Display_Name,Sup_Name,'')    
--From #Final F Inner    
--select DISTINCT Emp_ID from #FINAL-- ORDER by sup_id    
set @query ='select DISTINCT replace(Display_Name,char(39),'''') as Display_Name,    
REPLACE(Sup_Name,char(39),''''),Sup_ID,Dept_ID,Desig_Id,Branch_ID,Grd_ID,Sup_dept_id,Sup_desig_id,Sup_branch_Id,Sup_Grd_Id,Group_Length--,Group_Length,Row_ID,    
from #FINAL ORDER BY SUP_id'    
--print @query    
exec (@query)    
--SELECT sum(CASE WHEN ED.Group_Length = 0 THEN 1 ELSE ED.Group_Length END) from #FINAL ED --Where ED.Row_ID=1    
SELECT DISTINCT * FROM #Emp_Details    
--select @count_emp1 + @count_emp2    
END    
ELSE IF @format = 4    
begin    
INSERT INTO #Emp_Details    
Select e.Emp_ID,REPLACE(E.Emp_Full_Name,char(39),''),ER.R_Emp_Id,REPLACE(RE.Emp_Full_Name,char(39),''),'',    
ROW_NUMBER() OVER(Partition by ER.R_Emp_Id ORDER BY E.Emp_ID),    
1,DGE.Desig_Name,DGER.Desig_Name,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID    
from T0080_EMP_MASTER E left JOIN    
T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
from T0090_EMP_REPORTING_DETAIL inner JOIN    
(select max(Effect_Date)Effect_Date,Emp_ID    
from T0090_EMP_REPORTING_DETAIL    
where Cmp_ID = @cmpid and Effect_Date <= getdate()    
GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
where Cmp_ID =@cmpid    
GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
FROM T0095_INCREMENT I INNER JOIN    
(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
FROM T0095_INCREMENT Inner JOIN    
(    
SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
FROM T0095_INCREMENT WHERE CMP_ID = @cmpid GROUP BY EMP_ID    
) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
WHERE CMP_ID =@cmpid    
GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
where I.Cmp_ID=@cmpid    
)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
FROM T0095_INCREMENT I INNER JOIN    
(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
FROM T0095_INCREMENT Inner JOIN    
(    
SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
FROM T0095_INCREMENT    
GROUP BY EMP_ID    
) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
)IER on IER.Emp_ID = RE.Emp_ID left JOIN    
T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN    
T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN    
T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN    
T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID    
where E.Cmp_ID =@cmpid and E.Emp_Left<> 'Y' --AND E.Emp_ID IN(79,817,552,1035,1146,178) --ORDER by R_Emp_Id    
--SELECT * FROM #Emp_Details    
--GROUP BY SUP_ID,Emp_Desig    
--SELECT ',' + REPLACE(REPLACE(ED2.Emp_Name , CHAR(10), ' '), CHAR(13), '')    
--FROM #Emp_Details ED2    
--inner join    
--(SELECT EMP_NAME FROM #Emp_Details    
--GROUP BY SUP_ID,Emp_Desig) ED3 ON ED2.Sup_ID=ED3.Sup_ID    
UPDATE ED    
SET Emp_Group= (STUFF((SELECT ',' + REPLACE(REPLACE(REPLACE(Emp_Name , CHAR(10), ' '), CHAR(13), ''),CHAR(39), '')    
FROM #Emp_Details ED1    
WHERE ED1.Sup_ID=ED.Sup_ID    
AND NOT EXISTS(SELECT 1 FROM #Emp_Details ED2 WHERE ED1.Emp_ID=ED2.Sup_ID)    
GROUP by ED1.Emp_Name --ED1.Emp_Desig,    
FOR XML Path('')),1,1,'')    
)    
FROM #Emp_Details ED where ED.Row_ID=1    
--set @queryUpdate ='    
--UPDATE ED    
--SET Emp_Group= '''' + char(149) + replace((STUFF((SELECT '',''+REPLACE(REPLACE(Emp_Name , CHAR(10), '' ''), CHAR(13), '''') FROM #Emp_Details ED1    
-- WHERE ED1.Sup_ID=ED.Sup_ID GROUP by ED1.Emp_Desig,ED1.Emp_Name    
-- FOR XML Path('''')),1,1,'''')), '','',''''+char(149)) + char(149) +''''    
--FROM #Emp_Details ED    
--where ED.Row_ID=1'    
--exec(@queryUpdate)    
--select * from #Emp_Details    
UPDATE ED    
SET Group_Length=MemberCount    
FROM #Emp_Details ED    
INNER JOIN (SELECT ED2.Sup_ID, COUNT(1) AS MemberCount    
FROM #Emp_Details ED2    
WHERE NOT EXISTS(SELECT 1 FROM #Emp_Details ED WHERE ED2.Emp_ID=ED.Sup_ID)    
GROUP BY Sup_ID) ED2 ON ED2.Sup_ID=ED.Sup_ID    
--select * from #Emp_Details    
--UPDATE ED    
--SET Sup_Name=ED2.Emp_Group    
--FROM #Emp_Details ED    
-- INNER JOIN (SELECT ED2.Emp_Group,ED2.Sup_ID    
-- FROM #Emp_Details ED2    
-- WHERE ED2.Sup_Name    
-- in(SELECT data FROM dbo.Split(ISNULL(Emp_Group, '0'), ',')    
-- WHERE data <> '') FOR XML path(''))ED2 ON ED2.Sup_ID=ED.Sup_ID    
--(SELECT ED.Emp_Group FROM #Emp_Details ED WHERE ED2.Emp_ID=ED.Sup_ID)    
--)    
--SELECT    
-- *    
-- FROM #Emp_Details ED    
-- LEFT OUTER JOIN (SELECT 1 As HasSup FROM #Emp_Details ED1) ED1 ON    
--Where ED.Group_Length < 3 OR ED.Row_ID=1    
--order by ED.Sup_ID,eD.Emp_ID    
SELECT CASE WHEN ED.Group_Length < 3 Then REPLACE(ED.Emp_Name,char(39),'') Else REPLACE(ED.Emp_Group,char(39),'') End As Display_Name, *    
INTO #FINAL1    
FROM #Emp_Details ED    
WHERE ED.Group_Length < 3 OR ED.Row_ID=1 ORDER BY ED.Emp_ID    
INSERT INTO #FINAL1 --insert employee whose superior not exist    
SELECT DISTINCT REPLACE(F1.Emp_Name,char(39),''), F1.Emp_ID,REPLACE(F1.Emp_Name,char(39),''),Sup_ID,Sup_Name,  
--REPLACE(ED.Emp_Group,char(39),''),  
Row_ID,Group_Length,Emp_Desig,Sup_desig,Dept_ID,Desig_ID,Branch_ID,Grd_ID    
FROM #Emp_Details F1    
WHERE NOT EXISTS(SELECT 1 FROM #FINAL1 F2 WHERE F1.Emp_ID=F2.Emp_ID)    
and EXISTS(SELECT 1 FROM #FINAL1 F2 WHERE F1.Emp_ID=F2.Sup_ID)    
and Group_Length > 1    
SELECT * FROM #FINAL1 ORDER BY emp_id    
--set @query ='select Display_Name as Display_Name ,    
--'''' + Sup_Name +''''+ '''' + Sup_desig + '''' as Sup_Name,Emp_ID,Sup_ID,Group_Length,Row_ID,Dept_ID,Desig_Id,Branch_ID,Grd_ID    
--from #FINAL ORDER BY emp_id'    
--print @query    
--exec (@query)    
--UPDATE ED    
--SET Sup_Name=(SELECT ED2.Display_Name    
-- FROM #FINAL ED2    
-- WHERE ISNULL(ED2.Display_Name,'') <> '' and ED2.Sup_name    
-- in(SELECT data FROM dbo.Split(ISNULL(ED.Display_Name, ''), ',')WHERE data <> '') FOR XML path(''))    
--FROM #FINAL ED    
--INNER JOIN (SELECT ED2.Emp_Group,ED2.Sup_ID    
-- FROM #Emp_Details ED2    
-- WHERE ED2.Sup_Name    
-- in(SELECT data FROM dbo.Split(ISNULL(Emp_Group, '0'), ',')    
-- WHERE data <> '') FOR XML path(''))ED2 ON ED2.Sup_ID=ED.Sup_ID    
--SELECT * FROM #FINAL order by sup_id    
--select Case When ED.Group_Length < 3 Then ED.Emp_Name Else ED.Emp_Group End As Display_Name, *    
--from #Emp_Details ED    
--Where (ED.Group_Length < 3 OR ED.Row_ID=1 )    
-- AND ED.Sup_ID=100    
--UPDATE ED    
--SET Sup_Name=ED.Emp_Group    
--FROM #Emp_Details ED    
----where Sup_Name exists((select Data from dbo.Split(@P_Branch, '#') B)    
--INNER JOIN (SELECT ED2.Sup_ID, COUNT(1) AS MemberCount    
-- FROM #Emp_Details ED2    
-- GROUP BY Sup_ID) ED2 ON ED2.Sup_ID=ED.Sup_ID    
--set @query ='select Case When ED.Group_Length < 3 Then ED.Emp_Name Else ED.Emp_Group End As Display_Name ,    
--'''' + Sup_Name +''''+ '''' + Sup_desig + '''' as Sup_Name,Emp_ID,Sup_ID,Group_Length,Row_ID,Dept_ID,Desig_Id,Branch_ID,Grd_ID    
--from #Emp_Details ED Where ED.Group_Length < 3 OR ED.Row_ID=1'    
--exec (@query + ' and ' + @condition)    
SELECT SUM(ED.Group_Length)total_Count from #Emp_Details ED Where ED.Row_ID=1    
END    


---Added Format 11,12,13 -Deepali 02052023
ELSE IF @format = 6    
BEGIN    

SET @query ='SELECT e.Emp_ID,    
 ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+ 
''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+    
    ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
		''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSE.vertical_Name,'''') +''</td></tr>''+						
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DME.dept_Name,'''') +''</td></tr>''+	
					''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+REPLACE(e.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Grade  :</b><br/>''+  isnull(GME.Grd_Name,'''') +''</td></tr>''+
					''</table>'' as ename,	
					''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+
					''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
					''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSER.vertical_Name,'''') +''</td></tr>''+	
					
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DMER.dept_Name,'''') +''</td></tr>''+		
					
					''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+REPLACE(re.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Grade  :</b><br/>''+  isnull(GMER.Grd_Name,'''') +''</td></tr>''+
					''</table>'' as Emp_Full_Name					
		,RE.Cmp_ID,ER.R_Emp_Id,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
		IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID
 
			FROM T0080_EMP_MASTER E INNER JOIN    
			#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
			T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
			from T0090_EMP_REPORTING_DETAIL inner JOIN    
			(select max(Effect_Date)Effect_Date,Emp_ID    
			from T0090_EMP_REPORTING_DETAIL    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and Effect_Date <= getdate()    
			GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +' GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			-- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IER on IER.Emp_ID = RE.Emp_ID left JOIN    
			T0040_Vertical_Segment  VSE on VSE.Vertical_ID = E.vertical_id  left JOIN
			T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN
			T0040_GRADE_MASTER  GME on GME.Grd_Id = IE.Grd_Id  left JOIN
			T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN   			
			T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
			
			T0040_Vertical_Segment  VSER on VSER.Vertical_ID = E.vertical_id  left JOIN			
			T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID  left JOIN
			T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN  
			T0040_GRADE_MASTER  GMER on GMER.Grd_Id = IER.Grd_Id 


			where E.Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and E.Emp_Left<>''Y'' ' 
--print @query
exec (@query + ' and ' + @condition)    
END  

ELSE IF @format = 5   
BEGIN    
--print 3333    -----mansi

---Changes In Format 1,2,3 -Deepali 02052023
SET @query ='SELECT e.Emp_ID,    
 ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+ 
''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+    
    ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
		''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSE.vertical_Name,'''') +''</td></tr>''+						
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DME.dept_Name,'''') +''</td></tr>''+		
					''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+REPLACE(e.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
					''</table>'' as ename,	
					''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+
					''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
						''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSER.vertical_Name,'''') +''</td></tr>''+						
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DMER.dept_Name,'''') +''</td></tr>''+	
					
					''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+REPLACE(re.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
				
					''</table>'' as Emp_Full_Name					
		,RE.Cmp_ID,ER.R_Emp_Id,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
		IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID
 
			FROM T0080_EMP_MASTER E INNER JOIN    
			#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
			T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
			from T0090_EMP_REPORTING_DETAIL inner JOIN    
			(select max(Effect_Date)Effect_Date,Emp_ID    
			from T0090_EMP_REPORTING_DETAIL    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and Effect_Date <= getdate()    
			GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +' GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			-- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IER on IER.Emp_ID = RE.Emp_ID left outer JOIN    
			
			T0040_Vertical_Segment  VSE on VSE.Vertical_ID = E.vertical_id  left outer JOIN
			T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left outer JOIN
			T0040_GRADE_MASTER  GME on GME.Grd_Id = IE.Grd_Id  left JOIN
			T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN   			
			T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
			
			T0040_Vertical_Segment  VSER on VSER.Vertical_ID = E.vertical_id  left outer JOIN			
			T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID  left JOIN
			T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN  
			T0040_GRADE_MASTER  GMER on GMER.Grd_Id = IER.Grd_Id 
			
			where E.Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and E.Emp_Left<>''Y'' ' 
--print @query
exec (@query + ' and ' + @condition)    
END  

ELSE IF @format = 7  
BEGIN    
--print 3333    -----mansi

SET @query ='SELECT  e.Emp_ID,    
 ''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+ 
''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when e.image_name = ''0.jpg'' then case when e.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(e.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+    
    ''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
					
					''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSE.vertical_Name,'''') +''</td></tr>''+			
	
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DME.dept_Name,'''') +''</td></tr>''+							
				
					''<tr><td align=left><b>Employee Name :</b><br/>''+ e.Alpha_Emp_Code+''-''+REPLACE(e.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGE.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Grade  :</b><br/>''+  isnull(GME.Grd_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Yrs Of Exp.  :</b><br/>''+ cast((select (sum(cast((dbo.F_GET_EXP(St_Date,End_Date,''Y'',''M'') ) as numeric(18,2) ))) + (select sum(cast((dbo.F_GET_EXP(Date_OF_Join,GETDATE(),''Y'',''M'') ) as numeric(18,2)))   from T0080_EMP_MASTER where emp_id =  e.emp_id)   from T0090_EMP_EXPERIENCE_DETAIL where emp_id = e.emp_id) as varchar )+''</td></tr>''+
						
					''</table>'' as ename,	
					''<table style=font-family:verdana;font-size:10px;color:#444444;font-weight:normal;height:auto;width:120px;>''+
					''<tr><td align=center><img src=../App_File/EMPIMAGES/'' +(case when re.image_name = ''0.jpg'' then case when re.gender =''F'' then ''Emp_Default_Female.png'' else ''Emp_default.png'' end else isnull(re.image_name,''Emp_default.png'') end) +'' width=60px height=50px style=background-color:#F5F5F5;border-radius:50px;/></td></tr>''+
					''<tr><td class="" style="border-top:1px solid #838687"></td></tr>''+
					''<tr><td align=left><b>Vertical  :</b><br/>''+  isnull(VSER.vertical_Name,'''') +''</td></tr>''+						
	
					''<tr><td align=left><b>Department  :</b><br/>''+  isnull(DMER.dept_Name,'''') +''</td></tr>''+							
					''<tr><td align=left><b>Employee Name :</b><br/>''+ re.Alpha_Emp_Code+''-''+REPLACE(re.Emp_Full_Name,char(39),'''') +''</td></tr>''+					
					''<tr><td align=left><b>Designation  :</b><br/>''+  isnull(DGER.Desig_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Grade  :</b><br/>''+  isnull(GMER.Grd_Name,'''') +''</td></tr>''+
					''<tr><td align=left><b>Yrs Of Exp.  :</b><br/>''+ cast (isnull((select (sum(cast((dbo.F_GET_EXP(St_Date,End_Date,''Y'',''M'') ) as numeric(18,2) ))) + (select sum(cast((dbo.F_GET_EXP(Date_OF_Join,GETDATE(),''Y'',''M'') ) as numeric(18,2)))   from T0080_EMP_MASTER where emp_id =  re.emp_id)   from T0090_EMP_EXPERIENCE_DETAIL where emp_id = re.emp_id),0) as varchar )+''</td></tr>''+
					''</table>'' as Emp_Full_Name					
		,RE.Cmp_ID,ER.R_Emp_Id,IE.Dept_ID,IE.Desig_Id,IE.Branch_ID,IE.Grd_ID,
		IER.branch_id as Sup_branch_id,IER.Dept_ID as Sup_dept_id,IER.Grd_ID as Sup_Grd_ID,IER.DESIG_ID as Sup_DESIG_ID
 
			FROM T0080_EMP_MASTER E INNER JOIN    
			#Emp_Cons EC ON E.Emp_ID=EC.Emp_ID left JOIN    
			T0090_EMP_REPORTING_DETAIL ER on er.Emp_ID = e.Emp_ID INNER JOIN    
			(select max(Row_ID)Row_ID,T0090_EMP_REPORTING_DETAIL.Emp_ID    
			from T0090_EMP_REPORTING_DETAIL inner JOIN    
			(select max(Effect_Date)Effect_Date,Emp_ID    
			from T0090_EMP_REPORTING_DETAIL    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and Effect_Date <= getdate()    
			GROUP by Emp_ID)ER2 on er2.Effect_Date = T0090_EMP_REPORTING_DETAIL.Effect_Date and er2.Emp_ID=T0090_EMP_REPORTING_DETAIL.Emp_ID    
			where Cmp_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP by T0090_EMP_REPORTING_DETAIL.Emp_ID)ER1 on ER1.Row_ID=ER.Row_ID INNER JOIN    
			T0080_EMP_MASTER RE on re.Emp_ID = ER.R_Emp_ID Inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +' GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IE on ie.Emp_ID = e.Emp_ID inner JOIN    
			(SELECT I.EMP_ID,I.DESIG_ID,I.BRANCH_ID,I.Grd_ID,I.[Type_ID],I.Dept_ID    
			FROM T0095_INCREMENT I INNER JOIN    
			(SELECT MAX(INCREMENT_ID) AS INCREMENT_ID,T0095_INCREMENT.EMP_ID    
			FROM T0095_INCREMENT Inner JOIN    
			(    
			SELECT MAX(Increment_Effective_Date) AS Increment_Effective_Date , EMP_ID    
			FROM T0095_INCREMENT    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY EMP_ID    
			) inqry on inqry.Emp_ID = T0095_INCREMENT.Emp_ID    
			--WHERE CMP_ID = ' + cast(@cmpid as VARCHAR) +'    
			GROUP BY T0095_INCREMENT.EMP_ID) QRY ON I.EMP_ID = QRY.EMP_ID AND I.INCREMENT_ID = QRY.INCREMENT_ID    
			-- where I.Cmp_ID= ' + cast(@cmpid as VARCHAR) +'    
			)IER on IER.Emp_ID = RE.Emp_ID left JOIN  
			
			T0040_Vertical_Segment  VSE on VSE.Vertical_ID = E.vertical_id  left JOIN
			T0040_DESIGNATION_MASTER DGE on DGE.Desig_ID = IE.Desig_Id left JOIN
			T0040_GRADE_MASTER  GME on GME.Grd_Id = IE.Grd_Id  left JOIN
			T0040_DEPARTMENT_MASTER DME on DME.Dept_Id = IE.Dept_ID left JOIN   			
			T0030_BRANCH_MASTER BME on BME.Branch_ID = IE.Branch_ID left JOIN    
			
			T0040_Vertical_Segment  VSER on VSER.Vertical_ID = E.vertical_id  left JOIN			
			T0030_BRANCH_MASTER BMER on BMER.Branch_ID = IER.Branch_ID  left JOIN
			T0040_DESIGNATION_MASTER DGER on DGER.Desig_ID = IER.Desig_Id left JOIN    
			T0040_DEPARTMENT_MASTER DMER on DMER.Dept_Id = IER.Dept_ID left JOIN  
			T0040_GRADE_MASTER  GMER on GMER.Grd_Id = IER.Grd_Id 
			
			where E.Cmp_ID = ' + cast(@cmpid as VARCHAR) +' and E.Emp_Left<>''Y'' ' 
print @query
exec (@query + ' and ' + @condition)    
END  

END
