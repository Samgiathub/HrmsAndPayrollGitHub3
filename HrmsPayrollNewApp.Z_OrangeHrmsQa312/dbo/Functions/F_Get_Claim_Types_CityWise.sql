  
CREATE FUNCTION [dbo].[F_Get_Claim_Types_CityWise]  
(  
 @Emp_ID  numeric,  
 @Cmp_ID  numeric,  
 @For_Date DATETIME,  
 @Claim_Type numeric(3)   
   
)    
RETURNS @RtnValue table   
(  
 Claim_ID numeric,  
 Claim_Name nvarchar(500),  
 CLAIM_ALLOW_BEYOND_LIMIT numeric(3),  
 Claim_Type numeric(3),  
 Attach_Mandatory numeric(3)
 --,  
 --Sorting_no numeric  
)   
AS    
BEGIN   
 declare @dob numeric,  
 @gradeid numeric = 0,  
 @desigid numeric = 0,  
 @branchid numeric = 0,  
 @genflag char  
   
 select @dob = dbo.F_GET_AGE(Date_Of_Birth,GETDATE(),'Y','Y')  from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  
 select @gradeid = Grd_ID,@desigid = Desig_Id,@branchid = Branch_ID from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  
 Select @genflag =  Gender from T0080_EMP_MASTER where Emp_ID = @Emp_ID and Cmp_ID = @Cmp_ID  
    
  
 IF EXISTS(SELECT 1 FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
			  INNER JOIN	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
					Where Effective_Date<=GETDATE() And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
					GROUP BY emp_ID) Qry on      
					ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
			  INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id AND Leave <> '0')
		BEGIN
				INSERT INTO @RtnValue 
				select Final.Claim_ID,Final.Claim_Name,Final.CLAIM_ALLOW_BEYOND_LIMIT,Final.Claim_Type,Final.Attach_Mandatory from (
				SELECT DISTINCT CM.Claim_ID,CM.Claim_Name ,CM.CLAIM_ALLOW_BEYOND_LIMIT,CM.Claim_Type,CM.Attach_Mandatory,CM.Sorting_no FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
                left join T0040_CLAIM_MASTER cml on CM.Claim_ID = cml.Claim_Id 
				and  cml.Claim_Max_Limit>0
				inner join T0041_CLAIM_MAXLIMIT_DESIGN cla on CM.Claim_ID = cla.Claim_Id 
				where 
				(cla.Grade_ID = @gradeid or cla.Desig_ID = @desigid or cla.Branch_ID = @branchid)
				and (cla.Max_Limit_Km > 0 
				or cla.Max_Unit > 0)
				and (cm.Desig_Wise_Limit = 1 or cm.Branch_Wise_Limit = 1 or cm.Grade_Wise_Limit = 1 or
				cm.Age_Wise_Limit = 1 or cm.Grade_Age_Limit = 1 or cm.Basic_Salary_Wise = 1 or cm.Gross_Salary_Wise = 1
				or cm.Claim_Max_Limit = 1 or CM.Desig_City_Wise_Limit= 1 or CM.Grade_City_Wise_Limit= 1 or CM.HQ_City_Wise_Limit = 1 )
				and (cm.For_Gender = @genflag or isnull(cm.For_Gender,'') = '')
				and CM.CMP_ID=@Cmp_ID AND cm.Claim_ID IN (SELECT CAST(DATA AS NUMERIC)FROM DBO.Split(STUFF((SELECT '#' + SD.Leave FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
				Inner Join	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
								Where Effective_Date<=@For_Date And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
								GROUP BY emp_ID) Qry on      
								ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
				INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id 
				FOR XML PATH('')), 1, 1, ''),'#')) 
				UNION
				SELECT DISTINCT CM.Claim_ID,CM.Claim_Name ,CM.CLAIM_ALLOW_BEYOND_LIMIT,CM.Claim_Type,CM.Attach_Mandatory,CM.Sorting_no FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
				inner join T0041_Claim_Maxlimit_Age cma on cm.Claim_ID = cma.Claim_Id
				where 
				cma.GradeId = @gradeid
				and cma.Age_Amount > 0
				and @dob between cma.Age_Min and cma.Age_Max
				and (cm.Desig_Wise_Limit = 1 or cm.Branch_Wise_Limit = 1 or cm.Grade_Wise_Limit = 1 or
				cm.Age_Wise_Limit = 1 or cm.Grade_Age_Limit = 1 or cm.Basic_Salary_Wise = 1 or cm.Gross_Salary_Wise = 1
				or cm.Claim_Max_Limit = 1 )
				--and cm.For_Gender = @genflag
				and CM.CMP_ID=@Cmp_ID AND cm.Claim_ID IN (SELECT CAST(DATA AS NUMERIC)FROM DBO.Split(STUFF((SELECT '#' + SD.Leave FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
				Inner Join	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
								Where Effective_Date<=@For_Date And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
								GROUP BY emp_ID) Qry on      
								ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
				INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id 
				FOR XML PATH('')), 1, 1, ''),'#'))
				UNION
				 SELECT DISTINCT CM.Claim_ID,CM.Claim_Name,CM.CLAIM_ALLOW_BEYOND_LIMIT,CM.Claim_Type,CM.Attach_Mandatory,CM.Sorting_no 
					FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)  
				    INNER JOIN T0041_Claim_Maxlimit_GradeDesig_CityWise CLM WITH (NOLOCK) ON CLM.Claim_ID= CM.Claim_ID 
					where   
					(CM.Desig_Wise_Limit = 1 or CM.Branch_Wise_Limit = 1 or CM.Grade_Wise_Limit = 1 or  
				    CM.Age_Wise_Limit = 1 or CM.Grade_Age_Limit = 1 or CM.Basic_Salary_Wise = 1 or CM.Gross_Salary_Wise = 1  
				    or CM.Claim_Max_Limit = 1 or CM.Desig_City_Wise_Limit= 1 or CM.Grade_City_Wise_Limit= 1 or CM.HQ_City_Wise_Limit= 1 )  
				    and cm.Claim_Limit_Type= @Claim_Type  
				    and (cm.For_Gender = @genflag or isnull(cm.For_Gender,'') = '')  
				    and 
					CM.CMP_ID=@Cmp_ID AND CM.Claim_ID IN (SELECT CAST(DATA AS NUMERIC)FROM DBO.Split(STUFF((SELECT '#' + SD.Leave FROM T0095_EMP_SCHEME ES WITH (NOLOCK)  
				    Inner Join (Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)  
				        Where Effective_Date<=@For_Date And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID  
				        GROUP BY emp_ID) Qry on        
				        ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'  
				    INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id   
				    FOR XML PATH('')), 1, 1, ''),'#'))   
 

                UNION
				SELECT DISTINCT CM.Claim_ID,CM.Claim_Name,CM.CLAIM_ALLOW_BEYOND_LIMIT,CM.Claim_Type,CM.Attach_Mandatory,CM.Sorting_no  FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
				--inner join T0041_Claim_Maxlimit_Age cma on cm.Claim_ID = cma.Claim_Id
				where 
			cm.Claim_Max_Limit>0 and CM.Cmp_ID=@Cmp_ID
		    AND cm.Claim_ID IN (SELECT CAST(DATA AS NUMERIC)FROM DBO.Split(STUFF((SELECT '#' + SD.Leave FROM T0095_EMP_SCHEME ES WITH (NOLOCK)
			Inner Join	(Select MAX(Effective_Date) as For_Date, Emp_ID from T0095_EMP_SCHEME WITH (NOLOCK)
								Where Effective_Date<=@For_Date And Type='Claim' AND Emp_ID=@Emp_ID AND Cmp_ID=@Cmp_ID
								GROUP BY emp_ID) Qry on      
								ES.Emp_ID = Qry.Emp_ID and ES.Effective_Date = Qry.For_Date And Type='Claim'
				INNER JOIN T0050_Scheme_Detail SD WITH (NOLOCK) ON ES.Scheme_ID=SD.Scheme_Id 
				FOR XML PATH('')), 1, 1, ''),'#'))
			)Final order by Final.Sorting_no asc

		END
	ELSE
		BEGIN
			INSERT INTO @RtnValue 
			select T.Claim_ID,T.Claim_Name,T.CLAIM_ALLOW_BEYOND_LIMIT,T.Claim_Type,T.Attach_Mandatory from (
			SELECT DISTINCT CM.Claim_ID,CM.Claim_Name,CM.CLAIM_ALLOW_BEYOND_LIMIT,CM.Claim_Type,CM.Attach_Mandatory,CM.Sorting_no			
			 FROM T0040_CLAIM_MASTER CM WITH (NOLOCK)
			INNER JOIN T0095_EMP_SCHEME ES WITH (NOLOCK) ON CM.CMP_ID=ES.CMP_ID AND Type='Claim' 
			WHERE  CM.CMP_ID=@Cmp_ID and es.Emp_ID=@Emp_ID	 )T
			order by T.Sorting_no asc
		END
 
 Return  
END