
  --exec Emp_Details_Form_V @Company_Id=119,@From_Date='2020-12-26 00:00:00',@To_Date='2021-01-25 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='14371',@Report_Type='ESIC'   
--exec Emp_Details_Form_V @Company_Id=119,@From_Date='2020-12-26 00:00:00',@To_Date='2021-01-25 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='13960#14372#14371#24676#14365',@Report_Type='ESIC' 
--exec Emp_Details_Form_V @Company_Id=119,@From_Date='2020-12-26 00:00:00',@To_Date='2021-01-25 00:00:00',@Branch_ID='',@Cat_ID='',@Grade_ID='',@Type_ID='',@Dept_ID='',@Desig_ID='',@Emp_ID=0,@Constraint='13960',@Report_Type='ESIC'  
CREATE  PROCEDURE [dbo].[Emp_Details_Form_V]      
  @Company_Id NUMERIC        
 ,@From_Date  DATETIME      
 ,@To_Date   DATETIME     
 ,@Branch_ID  VarChar       
 ,@Cat_ID   VarChar    
 ,@Grade_ID   VarChar      
 ,@Type_ID   VarChar      
 ,@Dept_ID   VarChar      
 ,@Desig_ID   VarChar      
 ,@Emp_ID   NUMERIC      
 ,@Constraint VARCHAR(MAX)      
 ,@Report_Type varchar(50)    
     
AS 
begin
SET NOCOUNT ON       
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED      
SET ARITHABORT ON      
  
  IF @Branch_ID = '0' or @Branch_ID = ''    
  SET @Branch_ID = NULL    
    
 IF @Cat_ID = '0' or  @Cat_ID = ''    
  SET @Cat_ID = NULL    
       
 IF @Type_ID = '0' or @Type_ID = ''    
  SET @Type_ID = NULL    
 IF @Dept_ID = '0' or @Dept_ID = ''    
  SET @Dept_ID = NULL    
 IF @Grade_ID = '0' or @Grade_ID = ''    
  SET @Grade_ID = NULL    
    
     
 IF @Desig_ID = '0' or @Desig_ID = ''    
  SET @Desig_ID = NULL    
     
 IF @Branch_ID= '0' OR @Branch_ID=''  --Added By Jaina 21-09-2015    
  SET @Branch_ID = NULL    
 IF @Constraint= '0' OR @Constraint=''  --Added By Jaina 21-09-2015    
  SET @Constraint = NULL    
     
  CREATE table #Emp_Cons     
 (          
  Emp_ID NUMERIC ,         
  Branch_ID NUMERIC,    
  Increment_ID NUMERIC    
 )     
  exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Company_Id,@From_Date,@To_Date,@Branch_Id,@Cat_ID,@Grade_ID,@Type_ID,@Dept_ID,@Desig_ID,@Emp_ID,@Constraint,0,0,0,0,0,0,0,0,0,0,0,0  --Check and verify the above parameter    
     
 IF @Constraint <> ''      
  BEGIN      
   INSERT INTO #Emp_Cons(Emp_ID)      
   SELECT  CAST(DATA  AS NUMERIC) FROM dbo.Split (@Constraint,'#')       
  END    
  IF @Constraint <> ''   
  begin  
                   IF OBJECT_ID(N'tempdb..#tp1') IS NOT NULL
										DROP TABLE #tp1
				   IF OBJECT_ID(N'tempdb..#tmpI1') IS NOT NULL
														DROP TABLE #tmpI1
                  IF OBJECT_ID(N'tempdb..#tmpD1') IS NOT NULL
														DROP TABLE #tmpD1

					--  drop table if exists #tp1
				 -- drop table if exists #tmpI1
					--drop table if exists #tmpD1
				SELECT ROW_NUMBER() OVER (ORDER BY E.emp_id asc)as Sno, E.emp_id,ca.ColName, ca.ColValue
					into #tp1
				  FROM T0080_EMP_MASTER E
				    inner join #Emp_Cons ec on ec.Emp_ID=E.Emp_ID
				   INNER JOIN (SELECT i.Emp_ID,i.Inc_Bank_AC_No
					   FROM   t0095_increment I 
							  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= Getdate() AND cmp_id = @Company_Id 
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
										  )Q_I 
					ON Ec.emp_id = Q_I.emp_id 
				  inner join T0040_DESIGNATION_MASTER D on D.Desig_ID=E.Desig_Id
				  inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID  
				   left join MONTHLY_EMP_BANK_PAYMENT as m on m.Emp_ID=E.Emp_ID  
				CROSS APPLY (
					  Values
						 ('Emp_Name' , Concat(Emp_First_Name,' ',Emp_Last_Name)),
						 ('Father/Spouse_name' , Father_name),
						 ('Designation',D.Desig_Name),
						 ('UAN_No'     , UAN_No ),
						  ('Bank_Account_No',Inc_Bank_AC_No),
						 ('Wage_Period',concat(DATENAME(mm, Ms.Month_End_Date),' ',datepart(yy,Month_End_Date))),
						 ('Total_Attendance/Unit_of_Work_Done',cast(ms.Present_Days as varchar(50))),
						 ('Over_Time_Wages',cast(Ms.OT_Amount as varchar(50))),
						 ('Gross_Wages_Payable',cast(Gross_Salary as varchar(50))),
						 ('Net_Wages Paid:',cast(ms.Net_Amount as varchar(50))),
						 ('Date_of_Payment',cast(M.Payment_Date as varchar(50)))
						 
				  ) as CA (ColName, ColValue)
				   where ms.Month_St_Date=@From_Date and ms.Month_End_Date=@To_Date

  					 --where CONVERT(VARCHAR(50), ms.Month_St_Date, 20)=@From_Date and CONVERT(VARCHAR(50), ms.Month_End_Date, 20)=@To_Date
                    declare @a int=(select max(sno) from #tp1)

					 select ROW_NUMBER() OVER (ORDER BY Ma.emp_id asc)+@a as Sno,Ma.emp_id,Ad.AD_NAME,cast(Ad.AD_AMOUNT as varchar(50))as AD_AMOUNT 
					 into #tmpI1 from T0210_MONTHLY_AD_DETAIL MA
					 	  inner join #Emp_Cons ec on ec.Emp_ID=MA.Emp_ID
					  inner join T0050_AD_MASTER AD on Ad.AD_ID=MA.AD_ID 
					  where  For_Date between cast(@From_Date as varchar(50)) and cast(@To_Date as varchar(50)) and AD_FLAG='I'
				
					    declare @b int=(select max(sno) from #tmpI1)
					  --select * from #tmp1 t1 left join #tmpI t2 on t1.Emp_ID = t2.Emp_ID
					  select ROW_NUMBER() OVER (ORDER BY Ma.emp_id asc)+@b as Sno,Ma.emp_id,Ad.AD_NAME,cast(Ad.AD_AMOUNT as varchar(50))as AD_AMOUNT into #tmpD1 from T0210_MONTHLY_AD_DETAIL MA
					   inner join #Emp_Cons ec on ec.Emp_ID=MA.Emp_ID
					  inner join T0050_AD_MASTER AD on Ad.AD_ID=MA.AD_ID 
					  where  For_Date between cast(@From_Date as varchar(50)) and cast(@To_Date as varchar(50)) and AD_FLAG='D'
					

					
					select  Sno as RNumber,ColName As EmpDetail,ColValue as EmpValue from (
					 select  distinct Sno,Emp_id,Colname,ColValue from #tp1 where #tp1.Sno<7
					  union all
					  select  distinct 7 as Sno,Emp_id,AD_NAME as Colname,AD_AMOUNT as ColValue from  #tmpI1 
					  union all
					   
					  select  distinct 8 as Sno,Emp_id,Colname,ColValue from #tp1 where #tp1.sno=7
					  union all
					   select  distinct 9 as Sno,Emp_id,Colname,ColValue from #tp1 where #tp1.sno=8
					  union all
					    select  distinct 10 as Sno,Emp_id,Colname,ColValue from #tp1 where #tp1.sno=9
					  union all
					  select distinct 11 as Sno,Emp_id,AD_NAME as colname,AD_AMOUNT as ColValue  from  #tmpD1
					   union all
					  select  distinct 12 as Sno,Emp_id,Colname,ColValue from #tp1 where #tp1.sno =10
					  )as T

					
	
				   --  select Distinct Emp_ID,ColName,ColValue from #tp1 
					  --union 
					  --select Emp_id,AD_NAME as Colname,AD_AMOUNT as ColValue from  #tmpI1 
					  --union  
					  --select Emp_id,AD_NAME as colname,AD_AMOUNT as ColValue  from  #tmpD1
				   --order by #tp1.Emp_ID--#tp1.ColName
  end  
 ELSE         
BEGIN    
          IF OBJECT_ID(N'tempdb..#tp1') IS NOT NULL
										DROP TABLE #tp1
				   IF OBJECT_ID(N'tempdb..#tmpI1') IS NOT NULL
														DROP TABLE #tmpI1
                  IF OBJECT_ID(N'tempdb..#tmpD1') IS NOT NULL
														DROP TABLE #tmpD1
     
  --   drop table if exists #tmp1
  --drop table if exists #tmpI
  --  drop table if exists #tmpD
			SELECT ROW_NUMBER() OVER (ORDER BY E.emp_id asc)as Sno,E.emp_id,ca.ColName, ca.ColValue
				into #tmp1
			  FROM T0080_EMP_MASTER E
			  INNER JOIN (SELECT i.Emp_ID,i.Inc_Bank_AC_No
					   FROM   t0095_increment I 
							  INNER JOIN (SELECT Max(increment_effective_date) AS For_Date, emp_id 
										  FROM   t0095_increment 
										  WHERE  increment_effective_date <= Getdate() AND cmp_id = @Company_Id 
										  GROUP  BY emp_id) Qry 
										  ON I.emp_id = Qry.emp_id AND I.increment_effective_date = Qry.for_date
										  )Q_I 
					ON E.emp_id = Q_I.emp_id 
			  inner join T0040_DESIGNATION_MASTER D on D.Desig_ID=E.Desig_Id
			  inner join T0200_MONTHLY_SALARY as MS on E.Emp_ID=MS.Emp_ID  
			  left join MONTHLY_EMP_BANK_PAYMENT as m on m.Emp_ID=E.Emp_ID  
			CROSS APPLY (
				  Values
					 ('Emp_Name' , Concat(Emp_First_Name,' ',Emp_Last_Name)),
					 ('Father/Spouse_name' , Father_name),
					 ('Designation',D.Desig_Name),
					 ('UAN_No'     , UAN_No ),
					 ('Bank_Account_No',Inc_Bank_AC_No),
					 ('Wage_Period',concat(DATENAME(mm, Ms.Month_End_Date),' ',datepart(yy,Month_End_Date))),
					 ('Total_Attendance/Unit_of_Work_Done',cast(ms.Present_Days as varchar(50))),
					 ('Over_Time_Wages',cast(Ms.OT_Amount as varchar(50))),
					 ('Gross_Wages_Payable',cast(Gross_Salary as varchar(50))),
					 ('Net_Wages Paid:',cast(ms.Net_Amount as varchar(50))),
					 ('Date_of_Payment',cast(M.Payment_Date as varchar(50)))
			  ) as CA (ColName, ColValue)
			  --Select CONVERT(varchar,@Existingdate,20) as [YYYY-MM-DD HH:MM:SS]
			  --CONVERT(VARCHAR(50), Getdate(), 20) AS [OutputFormat]
			   where ms.Month_St_Date=@From_Date and ms.Month_End_Date=@To_Date
  				-- where  CONVERT(VARCHAR(50), ms.Month_St_Date, 20)=@From_Date and CONVERT(VARCHAR(50), ms.Month_End_Date, 20)=@To_Date
                declare @r int=(select max(sno) from #tmp1)
				 select ROW_NUMBER() OVER (ORDER BY Ma.emp_id asc)+@r as Sno,Ma.emp_id,Ad.AD_NAME,cast(Ad.AD_AMOUNT as varchar(50))as AD_AMOUNT into #tmpI from T0210_MONTHLY_AD_DETAIL MA
				  inner join T0050_AD_MASTER AD on Ad.AD_ID=MA.AD_ID 
				  where MA.emp_id=@Emp_ID and MA.Cmp_ID=@Company_Id and For_Date between cast(@From_Date as varchar(50)) and cast(@To_Date as varchar(50)) and AD_FLAG='I'

				  --select * from #tmp1 t1 left join #tmpI t2 on t1.Emp_ID = t2.Emp_ID
				  declare @m int=(select max(sno) from #tmpI)
				  select ROW_NUMBER() OVER (ORDER BY Ma.emp_id asc)+@m as Sno,Ma.emp_id,Ad.AD_NAME,cast(Ad.AD_AMOUNT as varchar(50))as AD_AMOUNT into #tmpD from T0210_MONTHLY_AD_DETAIL MA
				  inner join T0050_AD_MASTER AD on Ad.AD_ID=MA.AD_ID 
				  where  MA.Cmp_ID=@Company_Id and For_Date between cast(@From_Date as varchar(50)) and cast(@To_Date as varchar(50)) and AD_FLAG='D'

	            
					select  Sno as RNumber,ColName As EmpDetail,ColValue as EmpValue from (
					 select  distinct Sno,Emp_id,Colname,ColValue from #tmp1 where #tmp1.Sno<7
					  union all
					  select  distinct 7 as Sno,Emp_id,AD_NAME as Colname,AD_AMOUNT as ColValue from  #tmpI 
					  union all
					   
					  select  distinct 8 as Sno,Emp_id,Colname,ColValue from #tmp1 where #tmp1.sno=7
					  union all
					   select  distinct 9 as Sno,Emp_id,Colname,ColValue from #tmp1 where #tmp1.sno=8
					  union all
					    select  distinct 10 as Sno,Emp_id,Colname,ColValue from #tmp1 where #tmp1.sno=9
					  union all
					  select distinct 11 as Sno,Emp_id,AD_NAME as colname,AD_AMOUNT as ColValue  from  #tmpD
					   union all
					  select  distinct 12 as Sno,Emp_id,Colname,ColValue from #tmp1 where #tmp1.sno =10
					  )as T




				  --select Distinct Emp_ID,ColName,ColValue from #tmp1 
				  --union all
				  --select Emp_id,AD_NAME as Colname,AD_AMOUNT as ColValue from  #tmpI 
				  --union all 
				  --select Emp_id,AD_NAME as colname,AD_AMOUNT as ColValue  from  #tmpD

				  end
END 
