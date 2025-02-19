


CREATE VIEW [dbo].[V0010_Get_Max_Reporting_manager]
AS
		select RD.Emp_ID,RD.R_Emp_ID,RD.effect_date	--Replace(Replace(STUFF((SELECT ',' + QUOTENAME(RD.Emp_ID) As Emp_ID
		from	T0090_EMP_REPORTING_DETAIL RD WITH (NOLOCK) inner join 
		(
			select max(Effect_Date) as effect_date,Emp_ID 
			from T0090_EMP_REPORTING_DETAIL  WITH (NOLOCK) 
			Where Effect_Date <= GETDATE()
			group by Emp_ID
		) as Emp_sup
		on RD.Emp_ID = Emp_sup.Emp_ID and Rd.Effect_Date = Emp_sup.effect_date
		----WHERE RD.R_Emp_ID = 13960 
		--group by RD.Emp_ID 
		--order by RD.Emp_ID  
		--FOR XML PATH(''),Type).value('.', 'NVARCHAR(MAX)') ,1,1,''),']',''),'[','') as Emp_ID




