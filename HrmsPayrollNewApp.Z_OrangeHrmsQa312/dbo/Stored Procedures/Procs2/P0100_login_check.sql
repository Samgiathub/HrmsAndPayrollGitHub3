

-- Created By rohit for update default setting to all company on 31012013
CREATE PROCEDURE [dbo].[P0100_login_check]        
@login_name as varchar(100) = null
AS        
SET NOCOUNT ON  
begin

--select lower(L.Login_Name) as login_name
--,case WHEN SE.Setting_Value = 0 then 999 else SE.Setting_Value - isnull(cnt,0) end as cnt
--from t0011_login L LEFT JOIN 
--(select COUNT(1) as cnt, l.Login_id from T0100_Login_Detail_History l 
-- INNER JOIN (select login_id, Max(tran_id) As Tran_ID from T0100_Login_Detail_History l1 
--			WHERE l1.status=1  GROUP BY l1.Login_id) l1 ON (l.Login_id=l1.Login_id AND l.Tran_Id>l1.Tran_Id)
--			OR NOT EXISTS(SELECT 1 FROM T0100_Login_Detail_History L2 WHERE l2.status=1 and L2.Login_id = L.login_id)
--where l.system_date >= CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 103), 103) GROUP BY l.Login_id) LDH
--on  L.Login_ID = LDH.Login_id 
--left JOIN T0040_SETTING SE ON L.Cmp_ID = SE.Cmp_ID and SE.Setting_Name='InActive User After No of wrong Login'
--where L.Login_Name=isnull(@login_name,L.Login_Name)
--union

--select lower(L.Login_alias) as login_name
--,case WHEN SE.Setting_Value = 0 then 999 else SE.Setting_Value - isnull(cnt,0) end as cnt
--from t0011_login L LEFT JOIN 
--(select COUNT(1) as cnt, l.Login_id from T0100_Login_Detail_History l 
-- INNER JOIN (select login_id, Max(tran_id) As Tran_ID from T0100_Login_Detail_History l1 
--			WHERE l1.status=1  GROUP BY l1.Login_id) l1 ON (l.Login_id=l1.Login_id AND l.Tran_Id>l1.Tran_Id)
--			OR NOT EXISTS(SELECT 1 FROM T0100_Login_Detail_History L2 WHERE l2.status=1 and L2.Login_id = L.login_id)
--where l.system_date >= CONVERT(datetime, CONVERT(varchar(10), GETDATE(), 103), 103) GROUP BY l.Login_id) LDH
--on  L.Login_ID = LDH.Login_id 
--left JOIN T0040_SETTING SE ON L.Cmp_ID = SE.Cmp_ID and SE.Setting_Name='InActive User After No of wrong Login'
--where L.Login_alias=isnull(@login_name,L.Login_alias)
--and isnull(L.Login_Alias,'')<>''


 ;WITH CTE (Tran_Id,Cmp_id,Emp_id,Login_id,User_name,Password,system_date,status,Ip_address)
 as
 (
 select * from T0100_Login_Detail_History WITH (NOLOCK) 
 where System_Date >= CONVERT(Datetime, CONVERT(Varchar(10), GETDATE(), 103), 103)  and status = 0
 )
 
select lower(L.Login_Name) as login_name
,case WHEN SE.Setting_Value = 0 then 999 else SE.Setting_Value - isnull(cnt,0) end as cnt
from t0011_login L  WITH (NOLOCK)LEFT JOIN 
(SELECT COUNT(l1.tran_id) as cnt,L1.Login_id from CTE L1
left JOIN (SELECT MAX(Tran_Id) as Tran_Id , Login_id FROM T0100_Login_Detail_History WITH (NOLOCK) where status = 1 and System_Date >= CONVERT(Datetime, CONVERT(Varchar(10), GETDATE(), 103), 103) GROUP BY Login_id,Emp_id) L2 on 
L1.Tran_Id > L2.Tran_Id AND L1.Login_id = L2.Login_id 
GROUP BY L1.Emp_id,L1.Login_id) as TRL ON L.Login_ID = TRL.login_id 
left JOIN T0040_SETTING SE  WITH (NOLOCK) ON L.Cmp_ID = SE.Cmp_ID and SE.Setting_Name='InActive User After No of wrong Login'
where L.Login_Name=isnull(@login_name,L.Login_Name)

Union 

select lower(L.Login_alias) as login_name
,case WHEN SE.Setting_Value = 0 then 999 else SE.Setting_Value - isnull(cnt,0) end as cnt
from t0011_login L WITH (NOLOCK) LEFT JOIN 
(SELECT COUNT(l1.tran_id) as cnt,L1.Login_id from CTE L1
left JOIN (SELECT MAX(Tran_Id) as Tran_Id , Login_id FROM T0100_Login_Detail_History WITH (NOLOCK) where status = 1 and System_Date >= CONVERT(Datetime, CONVERT(Varchar(10), GETDATE(), 103), 103) GROUP BY Login_id,Emp_id) L2 on 
L1.Tran_Id > L2.Tran_Id AND L1.Login_id = L2.Login_id 
GROUP BY L1.Emp_id,L1.Login_id) as TRL ON L.Login_ID = TRL.login_id 
left JOIN T0040_SETTING SE WITH (NOLOCK) ON L.Cmp_ID = SE.Cmp_ID and SE.Setting_Name='InActive User After No of wrong Login'
where L.Login_alias=isnull(@login_name,L.Login_alias)
and isnull(L.Login_Alias,'')<>''

end

