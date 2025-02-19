


---27/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[P0011_GET_ADMIN_LOGIN_DETAILS]
@Cmp_ID as numeric
as
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON
	--declare @Max_Date as datetime
	
	
	
			SELECT EPD.PRIVILEGE_ID,LG.LOGIN_ID, LG.LOGIN_NAME,LG.IS_ACTIVE,LG.Is_Default FROM T0011_LOGIN LG WITH (NOLOCK)  -- Added By Gadriwala 12022014
					INNER JOIN T0090_EMP_PRIVILEGE_DETAILS EPD WITH (NOLOCK) 
								ON LG.LOGIN_ID = EPD.LOGIN_ID
					INNER JOIN (SELECT MAX(FROM_DATE) FROM_DATE,LOGIN_ID FROM T0090_EMP_PRIVILEGE_DETAILS WITH (NOLOCK) WHERE CMP_ID = @Cmp_ID GROUP BY LOGIN_ID) QRY
								ON QRY.LOGIN_ID = EPD.LOGIN_ID AND QRY.FROM_DATE = EPD.FROM_DATE 
					WHERE EMP_ID IS NULL AND BRANCH_ID IS NULL AND LOGIN_RIGHTS_ID IS NULL AND LG.CMP_ID= @Cmp_ID 
								--AND ( LOGIN_NAME NOT LIKE 'Admin@%' )--AND LOGIN_NAME NOT LIKE 'HR%')
					Order by LG.Login_Name
	
	--SELECT top 1 @Max_Date= max(EPD.From_Date)
	--	FROM T0011_LOGIN L INNER JOIN
 --            T0090_EMP_PRIVILEGE_DETAILS EPD ON L.Login_ID = EPD.Login_Id
 --                     where Emp_ID is null and Branch_ID is null and Login_Rights_ID is null and L.Cmp_ID=@Cmp_ID
 --                    group by EPD.From_Date
 --                    order by EPD.From_Date desc

	--SELECT EPD.Privilege_Id,L.Login_ID, L.Login_Name,L.Is_Active
	--		FROM T0011_LOGIN L INNER JOIN
 --                     T0090_EMP_PRIVILEGE_DETAILS EPD ON L.Login_ID = EPD.Login_Id
 --                     where Emp_ID is null and Branch_ID is null and Login_Rights_ID is null and L.Cmp_ID=@Cmp_ID
 --                    and From_Date =@Max_Date
 --                   group by login_name, EPD.Privilege_Id,
 --                    EPD.From_Date, L.Login_ID, L.Login_Name, 
 --                     L.Emp_ID, L.Branch_ID, L.Login_Rights_ID,L.Is_Active
 --                    order by From_Date desc
	
return




