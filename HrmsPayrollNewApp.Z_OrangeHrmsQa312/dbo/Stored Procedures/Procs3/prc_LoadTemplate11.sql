

-- exec prc_LoadTemplate
-- drop proc prc_LoadTemplate
CREATE proc [dbo].[prc_LoadTemplate11]
as
begin
	select E.Emp_Full_Name,E.Date_Of_Join,C.Cmp_Name,E.Street_1 from T0080_EMP_MASTER E
	INNER JOIN T0010_COMPANY_MASTER C ON E.Cmp_ID = C.Cmp_Id	
end
