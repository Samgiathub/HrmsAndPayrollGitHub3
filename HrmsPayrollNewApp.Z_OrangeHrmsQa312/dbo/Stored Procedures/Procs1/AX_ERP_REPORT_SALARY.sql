

---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_ERP_REPORT_SALARY]
	  @Cmp_Id	numeric output	 
	 ,@From_Date  datetime
	 ,@To_Date  datetime
	 ,@Flag Char = 'C'
	 ,@AD_id_Pass Numeric = 0
	 ,@Cost_Center	varchar(MAX) =''     --Added by Ramiz 18/05/2018 
	 ,@Business_Segment	varchar(MAX) =''
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON


	Declare @AX Table
	(
	
	DOCDT	Datetime,
	COCODE	varchar(50),
	EMPNAME	varchar(500),
	VOUDT	Datetime,
	BUSIUNIT varchar(50),	
	COSTCENT varchar(50),		
	DEPTCODE varchar(50),		
	BANKCODE varchar(50),		
	JOURTYPE varchar(50),		
	JOURNAME varchar(50),		
	OFFSETAC varchar(50),			
	ACCODE1	 varchar(50),			
	ACCTTYPE varchar(50),				
	ACCDDR	varchar(50)	,		
	PAYREFNO varchar(50),				
	PAYREFDT varchar(50),				
	AMOUNT	numeric(18,2),
	Transaction_Text nvarchar(500)	,
	CURRENCY varchar(50),					
	CUREXGRT varchar(50),						
	RECTNAME varchar(50),						
	VOUMONTH varchar(50),						
	EMPIND varchar(50),
	Cmp_id numeric(18,0),
	ad_id numeric(18,0),
	Dept_id numeric(18,0),
	cc_id numeric(18,0),
	ad_flag char(1),
	loan_id numeric(18,0),
	voucher_Flag Char(1),
	vender_Code Varchar(50),
	Sorting_No numeric(18,0),
	Bank_id numeric(18,0),
	Is_Highlight TINYINT default 0 not null,
	BackColor VARCHAR(20) default '', 
	forecolor VARCHAR(20) default ''
)
DECLARE @VOU_DT	DATETIME
DECLARE @DOC_DT	DATETIME
SET @VOU_DT	= DATEADD(DD,-(DAY(@TO_DATE)),@TO_DATE)
SET @DOC_DT = @TO_DATE

	IF ISNULL(@Cost_Center,'') = '' OR ISNULL(@Cost_Center,'') = '0'
				SELECT	@Cost_Center=COALESCE(@Cost_Center + '#','') + CAST(Center_ID AS VARCHAR(10))
				FROM	T0040_COST_CENTER_MASTER WITH (NOLOCK)
				WHERE	Cmp_ID=@Cmp_Id
			SET @Cost_Center = @Cost_Center + '#0'
			
IF @AD_id_Pass = 0
		BEGIN

			if @Flag = 'A'
				begin
					insert into @AX
					select @Doc_DT ,AX_Head.Cmp_Code,Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
					@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code , AX_Head.Sorting_no , AX_Head.Bank_Id , AX_Head.Is_Highlight , AX_Head.backcolor , AX_Head.forecolor
					from
					(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																					 when Month_Year =0 then Head_Name End) as [Transaction Text],
																					 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No , CM.Cmp_Code , ax.Bank_id , AX.Is_Highlight , Ax.backcolor , AX.forecolor
					FROM         T9999_Ax_Mapping ax left join 
					T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
					left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
					 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id=1015 ) as AX_Head

					cross join  

					(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as Center_ID ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,Emp_Full_Name,BM.Bank_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
					inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,I.Bank_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
										( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_Id
										group by emp_ID  ) Qry on
										I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
					inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
					left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
					left join T0040_BANK_MASTER BM WITH (NOLOCK) on INC.bank_id = BM.Bank_ID
					where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'
					group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Emp_Full_Name,bank_code  ) as group1

					order by Dept_Code, AX_Head.Sorting_no

				end
			else if @Flag = 'S'
				begin
					insert into @AX
					select @Doc_DT ,AX_Head.Cmp_Code, Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,Bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
					@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code , AX_Head.Sorting_no , AX_Head.Bank_Id , AX_Head.Is_Highlight , AX_Head.backcolor , AX_Head.forecolor
					from
					(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																					 when Month_Year =0 then Head_Name End) as [Transaction Text],
																					 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No , CM.Cmp_Code , ax.Bank_Id , AX.Is_Highlight , Ax.backcolor , AX.forecolor
					FROM         T9999_Ax_Mapping ax left join 
					T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
					left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
					 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id in ('1003','1040','1050','1051')) as AX_Head

					cross join  

					(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as center_id ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,Emp_Full_Name,Bank_code  from T0080_EMP_MASTER EM WITH (NOLOCK)
					inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,i.Bank_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
										( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										where Increment_Effective_date <= @To_Date
										and Cmp_ID = @Cmp_Id
										group by emp_ID  ) Qry on
										I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
					inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
					left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
					LEFT JOIN T0040_BANK_MASTER BM WITH (NOLOCK) ON INC.bank_id = BM.bank_id
					where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'-- and inc.Emp_ID=608
					group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Emp_Full_Name,bank_code  ) as group1
					order by Dept_Code, AX_Head.Sorting_no
				end
			else
				begin
			
					insert into @AX
					SELECT @Doc_DT ,AX_Head.Cmp_Code,'',@vou_DT, '',group1.Center_Code,'','','0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
						@Cmp_Id,AX_Head.Ad_id,0,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',AX_Head.vender_code, AX_Head.Sorting_no , AX_Head.Bank_Id , AX_Head.Is_Highlight , AX_Head.backcolor , AX_Head.forecolor
					FROM
						(
							SELECT   ax.Ad_id, Sorting_no, Account, 
								(
									case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
										when Month_Year =0 then Head_Name 
									End
								) as [Transaction Text],
								 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No , CM.Cmp_Code , AX.Bank_Id , AX.Is_Highlight , Ax.backcolor , AX.forecolor
						FROM         T9999_Ax_Mapping AX 
					LEFT JOIN T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
					LEFT JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id where ax.Cmp_id = @Cmp_Id) as AX_Head

					CROSS JOIN  

					(SELECT DISTINCT CCM.Center_Code ,CCM.Cost_Element , ISNULL(CCM.Center_ID,0) as CENTER_ID   
						 FROM T0080_EMP_MASTER EM WITH (NOLOCK)
							INNER JOIN 
								(SELECT I.Emp_Id,i.Center_ID 
								 FROM T0095_Increment I WITH (NOLOCK)
									INNER JOIN T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID 
									INNER JOIN 
											(	SELECT MAX(INCREMENT_ID) AS INCREMENT_ID, EMP_ID 
												FROM T0095_INCREMENT WITH (NOLOCK)
												WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE AND CMP_ID = @CMP_ID
												GROUP BY EMP_ID  
											) QRY ON I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id
								) as INC on INC.Emp_ID = EM.Emp_ID
							LEFT OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
							INNER JOIN (SELECT CAST(DATA AS NUMERIC) AS Center_ID
										FROM	dbo.Split(@Cost_Center, '#') T
										Where	Data <> '') T  ON IsNull(INC.Center_ID,0)=T.Center_ID
						WHERE  EM.CMP_ID = @CMP_ID 
						GROUP BY CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID ) as group1
						ORDER BY  group1.Center_Code, AX_Head.Sorting_no
				
			
			End	
		END
ELSE
		BEGIN
			insert into @AX
				select @Doc_DT ,AX_Head.Cmp_Code,Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
				@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code , AX_Head.Sorting_no , AX_Head.Bank_Id , AX_Head.Is_Highlight , AX_Head.backcolor , AX_Head.forecolor
				from
				(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																				 when Month_Year =0 then Head_Name End) as [Transaction Text],
																				 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No , CM.Cmp_Code , ax.Bank_Id , AX.Is_Highlight , Ax.backcolor , AX.forecolor
				FROM         T9999_Ax_Mapping ax left join 
				T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
				left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
				 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id=@AD_id_Pass  ) as AX_Head

				cross join  

				(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as center_id ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,(Initial + ' ' + Emp_First_Name + ' '+ Emp_Second_Name + ' '+ Emp_Last_Name) as Emp_Full_Name,BM.Bank_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
				inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,I.Bank_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
									( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK)--Changed by Hardik 10/09/2014 for Same Date Increment
									where Increment_Effective_date <= @To_Date
									and Cmp_ID = @Cmp_Id
									group by emp_ID  ) Qry on
									I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
				inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
				left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
				left join T0040_BANK_MASTER BM WITH (NOLOCK) on INC.bank_id = BM.Bank_ID
				where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'
				group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Initial ,Emp_First_Name ,Emp_Second_Name , Emp_Last_Name,bank_code  ) as group1
				order by Dept_Code, AX_Head.Sorting_no
		END


	DECLARE @CUR_CMP_ID AS NUMERIC(18,0)
	DECLARE @CUR_DEPT_ID AS NUMERIC(18,0)  
	DECLARE @CUR_CENTER_ID AS NVARCHAR(50)
	DECLARE @CUR_AD_ID AS NUMERIC(18,0)
	DECLARE @CUR_AD_FLAG AS CHAR(1)
	DECLARE @CUR_LOAN_ID AS NUMERIC(18,0)
	DECLARE @CUR_BUS_AREA AS NVARCHAR(50)
	DECLARE @AD_DEF_ID AS NUMERIC(18,0)
	DECLARE @ALPHA_EMP_CODE AS NVARCHAR(200)
	DECLARE @BANK_ID AS NUMERIC(18,0)
	DECLARE @VENDOR_CODE AS VARCHAR(50)
	
	DECLARE CUR_AX CURSOR FOR
		SELECT CMP_ID,CC_ID,AD_ID,AD_FLAG,LOAN_ID,BUSIUNIT ,BANK_ID , VENDER_CODE FROM @AX WHERE CMP_Id = @Cmp_Id and Sorting_No < 100 --AND COSTCENT = 570101
	OPEN CUR_AX
	FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID, @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA , @Bank_id , @VENDOR_CODE
	While @@fetch_Status = 0
		begin
			
			declare @sum_amt as numeric(18,2) 
			
			declare @sum_amt_Sett as numeric(18,2)
			set @sum_amt_Sett=0 
			
			set @sum_amt = 0
			
				
			If @CUR_AD_ID = 1002 -- Gross
				BEGIN
					SELECT @SUM_AMT = (isnull(SUM(MS.Gross_Salary),0) - (Isnull(Sum(MS.Leave_Salary_Amount),0) + ISNULL(Sum(Ms.Gratuity_Amount),0) + ISNULL(Sum(Qry2.M_AD_Amount),0))) FROM  T0200_MONTHLY_SALARY MS 
						INNER JOIN 
							(SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
								INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
								INNER JOIN 
									(
										SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID 
									) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						--LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, MAD.M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE AD.AD_DEF_ID = @BONUS_DEF_ID AND MAD.FOR_FNF = 1
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--	) QRY1 on Qry1.Emp_ID = MS.Emp_ID and MONTH(Qry1.To_date) = MONTH(@TO_DATE) and YEAR(Qry1.To_date) = YEAR(@TO_DATE)
						LEFT OUTER JOIN 
							(
								SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
								INNER JOIN T0050_AD_MASTER AD WITH (NOLOCK) ON MAD.AD_ID = AD.AD_ID
								WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
								AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
								GROUP BY MAD.Emp_ID , MAD.TO_DATE
							) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE)
						
						--AND ISNULL(MS.IS_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						
					UPDATE @AX SET AMOUNT = @SUM_AMT,VOUCHER_FLAG ='D',JOURNAME='JVPD'  WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID
					--and Dept_ID = @CUR_DEPT_ID	and BUSIUNIT =  @CUR_BUS_AREA
	
				END
				
			ELSE if @CUR_AD_ID = 1003 and @Flag <> 'S' -- Net Amount
				BEGIN
					
					SELECT @SUM_AMT = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						INNER JOIN (SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
						INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
						INNER JOIN 
									( 
										SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID
									) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 --and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
					
					UPDATE @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and  cc_id = @CUR_CENTER_ID
					--AND Dept_ID = @CUR_DEPT_ID and BUSIUNIT =  @CUR_BUS_AREA
					
				end
				
			else if @CUR_AD_ID = 1006 -- LWF
				BEGIN
									
					SELECT @SUM_AMT = isnull(SUM(MS.LWF_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						INNER JOIN 
							(SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
								INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
								INNER JOIN 
									(
										SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID 
									) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID  and cc_id = @CUR_CENTER_ID
				end
				
			else if @CUR_AD_ID = 1001 -- PT
				BEGIN
				
				SELECT @sum_amt = isnull(SUM(MS.PT_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						INNER JOIN (SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
									INNER JOIN 
										( 
											SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
											WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
											GROUP BY EMP_ID
										) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						
					UPDATE @AX set Amount = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and cc_id = @CUR_CENTER_ID
					--and Dept_ID = @CUR_DEPT_ID 	and BUSIUNIT =  @CUR_BUS_AREA
					
				end
				
			--else if @CUR_AD_ID = 1020 -- Notice Recovery
			--	begin
					
			--	SELECT @sum_amt = isnull(SUM(MS.Short_Fall_Dedu_Amount),0) FROM  T0200_MONTHLY_SALARY MS 
			--			inner join T0095_INCREMENT i on  ms.Increment_ID = i.Increment_ID
			--			inner join T0100_LEFT_EMP LE on i.Emp_ID = LE.Emp_ID
			--			where i.Dept_ID = @CUR_DEPT_ID and i.Center_ID =@CUR_CENTER_ID
			--			and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and LE.Is_Terminate = 0 and MS.Is_FNF = 1
						
			--		update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID		
					
			--	end
			
			else if @CUR_AD_ID = 1015 and @Flag <> 'A'-- Advance
				BEGIN
				
					INSERT INTO @AX
					SELECT @Doc_DT , CM.Cmp_Code , (Initial + ' ' + Emp_First_Name + ' '+ Emp_Second_Name + ' '+ Emp_Last_Name) ,@vou_DT, BS.Segment_Code , CCM.Center_Code , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' ,  
					Round(ISNULL(MS.Advance_Amount,0) ,0) as Advance_Amonut  , 
					(EM.Initial + ' ' + EM.Emp_First_Name + ' '+ EM.Emp_Second_Name + ' '+ EM.Emp_Last_Name) + ' ' + 'Advance' , 'INR' , '' , '' , ''  , '' , em.Cmp_ID ,  @CUR_AD_ID , 0 , INC.Center_ID , 'D' , 0 , 'D', EM.Dealer_Code , 20 , 0 , 0 , '' , ''
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								INNER JOIN 
									(
										SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code , I.Segment_ID FROM T0095_INCREMENT I WITH (NOLOCK)
											INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID
											INNER JOIN 
												( 
													SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT
													WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
													AND CMP_ID = @CMP_ID 
													GROUP BY EMP_ID
												) QRY ON
										I.EMP_ID = QRY.EMP_ID AND I.Increment_Id = QRY.Increment_Id
									) AS INC ON INC.EMP_ID = MS.EMP_ID
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								Inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
								Left OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = INC.Segment_ID
								Left OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
								Left Outer JOin T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) on AP.Emp_ID = EM.Emp_ID and AP.For_Date = DATEADD(DAY , 1 , @TO_date)
							WHERE INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and MS.Sal_Cal_Days <> 0 and MS.Advance_Amount <> 0 
								and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 
								
				--SELECT @sum_amt = isnull(SUM(MS.Advance_Amount),0) FROM  T0200_MONTHLY_SALARY MS 
				--		inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID INNER JOIN 
				--					( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
				--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
				--					AND CMP_ID = @CMP_ID 
				--					GROUP BY EMP_ID  ) QRY ON
				--					I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
				--		inner JOIN T0080_EMP_MASTER EM ON ms.emp_id = EM.Emp_ID
				--		where INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID and MS.Sal_Cal_Days <> 0 
				--		and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
				--		--and EM.Dealer_Code = @CUR_BUS_AREA
						
					--update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  
					--where AD_ID = @CUR_AD_ID and cc_id = @CUR_CENTER_ID	--and BUSIUNIT =  @CUR_BUS_AREA and Dept_ID = @CUR_DEPT_ID
					
				end
				
			else if @CUR_AD_ID = 1030 -- lEAVE Encashment
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MS.Leave_Salary_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) -- and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--and BUSIUNIT =  @CUR_BUS_AREA
					
				end
				
			else if @CUR_AD_ID = 1040  and @Flag <> 'S' -- Net Salary MD
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID , Center_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID  ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'MD'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--and BUSIUNIT =  @CUR_BUS_AREA
					
				end
			
			else if @CUR_AD_ID = 1050  and @Flag <> 'S' -- Net Salary DI
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID , Center_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'DI'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--and BUSIUNIT =  @CUR_BUS_AREA
					
				end
					
			else if @CUR_AD_ID = 1051  and @Flag <> 'S' -- Net Salary Trainee
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID , Center_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'TR'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				
			else if @CUR_AD_ID = 1060 -- PF MD
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
						inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID , Center_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID and AM.AD_DEF_ID=2
						where INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') ='MD' --and mad.AD_ID = @CUR_AD_id  -- Comented by rohi for inducto. on 18022015
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				
			else if @CUR_AD_ID = 1070 -- PF Di
				BEGIN
					 
				SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( 
									SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID and AM.AD_DEF_ID=2
						where INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') ='DI' -- and mad.AD_ID = @CUR_AD_id  Commented by rohit on 18022015
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				
			else if @CUR_AD_ID = 2003 -- Basic Amount
				BEGIN
					
						SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
							--and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
					
					--select @sum_amt_Sett = isnull(sum(S_Salary_Amount),0) from T0201_MONTHLY_SALARY_SETT  
					--inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID INNER JOIN 
					--					( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
					--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
					--					AND CMP_ID = @CMP_ID 
					--					GROUP BY EMP_ID  ) QRY ON
					--					I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = T0201_MONTHLY_SALARY_SETT.EMP_ID
					--		 inner JOIN T0080_EMP_MASTER EM ON T0201_MONTHLY_SALARY_SETT.emp_id = EM.Emp_ID
					--		 where Month(@To_Date) = MONTH(s_Month_st_Date) and Year(@To_Date) = year(s_Month_st_Date)
					--		 and EM.Dealer_Code = @CUR_BUS_AREA and INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID 
					--		and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
				
								SELECT @sum_amt_Sett = isnull(SUM(MS.S_Salary_Amount),0) 
								FROM  T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID  ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(S_Eff_Date) = MONTH(@To_Date)  and YEAR(S_Eff_Date) = YEAR(@To_Date)--   and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
							
						set @sum_amt = @sum_amt + @sum_amt_Sett
					
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
						--and BUSIUNIT =  @CUR_BUS_AREA
				
					end
					
			else if @CUR_AD_ID = 2040 -- Basic Salary MD
				BEGIN
						
					SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID  ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
							--and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') = 'MD'
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
						--and BUSIUNIT =  @CUR_BUS_AREA
						
					end
					
			else if @CUR_AD_ID = 2050 -- Basic Salary DI
				BEGIN
					
						SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS  WITH (NOLOCK)
								inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
											( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
											WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
											GROUP BY EMP_ID  ) QRY ON
											I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
								inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
								and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
								--and EM.Dealer_Code = @CUR_BUS_AREA
								and isnull(Emp_Mark_Of_Identification,'') = 'DI'
							update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
							
					END	
				
			else if @CUR_AD_ID = 2051 -- Basic Salary Trainee		
				BEGIN
					
				SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'TR'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--and BUSIUNIT =  @CUR_BUS_AREA
					
				end	

			else if @CUR_AD_ID = 1015 and @Flag = 'A' -- Advance
				BEGIN
					
				SELECT @sum_amt = 
				isnull(SUM(MS.Adv_Amount),0) FROM  T0100_ADVANCE_PAYMENT MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code,E.Alpha_Emp_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(For_Date) = MONTH(@To_Date)  and YEAR(For_Date) = YEAR(@To_Date)  --and EM.Dealer_Code = @CUR_BUS_AREA --and Em.Alpha_Emp_Code =@alpha_Emp_Code
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='A',JOURNAME='ICBP'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
					
				end	
					
			else if @CUR_AD_ID = 1003 and @Flag = 'S' -- Net Amount
				BEGIN
				
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
						--and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')-- and Em.Alpha_Emp_Code =@alpha_Emp_Code
					
					
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	
					--and BUSIUNIT =  @CUR_BUS_AREA  and EMPCD = @alpha_Emp_Code
					
				end
						
			else if @CUR_AD_ID = 1040 and @Flag = 'S' -- Net Salary MD
				BEGIN
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID , Center_ID  ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) -- and isnull(ms.is_FNF,0)  = 0 
							--and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') = 'MD' --and Em.Alpha_Emp_Code =@alpha_Emp_Code
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='M'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
						--			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
						
					end
					
     		else if @CUR_AD_ID = 1050 and @Flag = 'S' -- Net Salary DI
				BEGIN
					
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID , Center_ID ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
							--and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') = 'DI' --and Em.Alpha_Emp_Code =@alpha_Emp_Code
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='D'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
						--			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
						
				END	
				
			else if @CUR_AD_ID = 1051 and @Flag = 'S' -- Net Salary Trainee
				BEGIN
					
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
										( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID , Center_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
										WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
										AND CMP_ID = @CMP_ID 
										GROUP BY EMP_ID , Center_ID ) QRY ON
										I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id AND I.Center_ID = QRY.Center_ID ) AS INC ON INC.EMP_ID = MS.EMP_ID
							inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
							where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
							and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  --and isnull(ms.is_FNF,0)  = 0 
							--and EM.Dealer_Code = @CUR_BUS_AREA
							and isnull(Emp_Mark_Of_Identification,'') = 'TR' --and Em.Alpha_Emp_Code =@alpha_Emp_Code
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='T'  
						where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
						--			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
						
				END			
					
			else if @CUR_AD_FLAG = 'I' --This will give you all Earnings
				BEGIN
					SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD  WITH (NOLOCK)
						inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id  ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						left join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
						where INC.Center_ID =@CUR_CENTER_ID AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id  --and isnull(ms.is_FNF,0)  = 0
						 --and EM.Dealer_Code = @CUR_BUS_AREA  
						--and Em.Alpha_Emp_Code =@alpha_Emp_Code
						and AM.AD_NOT_EFFECT_SALARY <>1
						
					set @sum_amt_Sett = 0
					
					select @sum_amt_Sett = isnull(sum(M_Ad_Amount),0)
					from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
					T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
					t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
					inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MAD.EMP_ID
					
					and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.emp_id = EM.Emp_ID
					where 
					MAD.Cmp_ID = @cmp_id and month(MSS.S_Eff_Date) =  month(@To_Date ) and Year(MSS.S_Eff_Date) = year(@To_Date ) and
					Ad_Active = 1 And sal_type=1 and mad.ad_id =@CUR_AD_id and INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID = @CUR_CENTER_ID --and  inc.Dealer_Code =  @CUR_BUS_AREA	
				and 1 = (case when  t0050_ad_master.AD_DEF_ID=2 and isnull(Emp_Mark_Of_Identification,'') in ('MD','DI') then 0 else 1 end )
				and t0050_ad_master.AD_NOT_EFFECT_SALARY <>1
				
					
				
					set @sum_amt = @sum_amt + @sum_amt_Sett		
						
					update @AX set Amount = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID
					--and BUSIUNIT =  @CUR_BUS_AREA	
					--AND  EMPCD =@alpha_Emp_Code		
				end
				
			else if @CUR_AD_FLAG = 'D'	--This will give you all Deduction
				BEGIN		
							
					SELECT @SUM_AMT = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						INNER JOIN (
									SELECT I.EMP_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
									INNER JOIN 
										( 
											SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
											GROUP BY EMP_ID
										) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						LEFT JOIN T0050_AD_MASTER Am WITH (NOLOCK) on  MAD.AD_ID = Am.AD_ID 
						where inc.Center_ID = @CUR_CENTER_ID AND MS.Sal_Cal_Days <> 0 AND MS.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id --and isnull(ms.is_FNF,0)  = 0 --and EM.Dealer_Code = @CUR_BUS_AREA 
						and 1 = (case when  AM.AD_DEF_ID=2 and isnull(Emp_Mark_Of_Identification,'') in ('MD','DI') then 0 else 1 end )
						and AM.AD_NOT_EFFECT_SALARY <> 1
						
					SET @SUM_AMT_SETT = 0
					
					SELECT @SUM_AMT_SETT = ISNULL(SUM(M_AD_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						INNER JOIN T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) ON MAD.SAL_TRAN_ID=MSS.SAL_TRAN_ID 
						INNER JOIN T0050_AD_MASTER WITH (NOLOCK) ON MAD.AD_ID = T0050_AD_MASTER.AD_ID
						INNER JOIN 
								(
									SELECT I.EMP_ID,I.CENTER_ID ,E.DEALER_CODE FROM T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
									INNER JOIN 
										(
											SELECT MAX(INCREMENT_ID) AS INCREMENT_ID , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
											WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
											GROUP BY EMP_ID
										) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.INCREMENT_ID = QRY.INCREMENT_ID 
								) AS INC ON INC.EMP_ID = MAD.EMP_ID
						
						AND MAD.CMP_ID = T0050_AD_MASTER.CMP_ID
						INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.EMP_ID = EM.EMP_ID
					WHERE MAD.CMP_ID = @CMP_ID AND MONTH(MSS.S_EFF_DATE) =  MONTH(@TO_DATE ) AND YEAR(MSS.S_EFF_DATE) = YEAR(@TO_DATE ) AND
					AD_ACTIVE = 1 AND SAL_TYPE=1 AND MAD.AD_ID =@CUR_AD_ID AND INC.CENTER_ID = @CUR_CENTER_ID --AND  INC.DEALER_CODE =  @CUR_BUS_AREA	
					AND 1 = (CASE WHEN  T0050_AD_MASTER.AD_DEF_ID=2 AND ISNULL(EMP_MARK_OF_IDENTIFICATION,'') IN ('MD','DI') THEN 0 ELSE 1 END )
					AND T0050_AD_MASTER.AD_NOT_EFFECT_SALARY <>1
				
					SET @SUM_AMT = @SUM_AMT + @SUM_AMT_SETT	
					
						
					UPDATE @AX SET AMOUNT = @SUM_AMT, VOUCHER_FLAG ='C', JOURNAME='JVPC'  
					WHERE AD_ID = @CUR_AD_ID  AND CC_ID = @CUR_CENTER_ID and LOAN_ID = 0 AND BANK_ID = 0 AND VENDER_CODE = ''
	
				END
			
			else if @CUR_AD_ID = 0 and @CUR_LOAN_ID <> 0		--This will Give you Loan Entries Employee Wise
				BEGIN
												
					INSERT into @AX
					SELECT @Doc_DT , CM.Cmp_Code , (Initial + ' ' + Emp_First_Name + ' '+ Emp_Second_Name + ' '+ Emp_Last_Name) ,@vou_DT, BS.Segment_Code , CCM.Center_Code , '' , '' , '' , '' , '' , '' , '' , '' , '' , '' ,  
					Round(ISNULL(MS.Loan_Amount,0) - ISNULL(AP.Adv_Amount,0) ,0) as Loan_Amount  , 
					(EM.Initial + ' ' + EM.Emp_First_Name + ' '+ EM.Emp_Second_Name + ' '+ EM.Emp_Last_Name) + ' ' + 'Loan' , 'INR' , '' , '' , ''  , '' , em.Cmp_ID ,  @CUR_AD_ID , 0 , INC.Center_ID , 'D' , LT.Loan_ID , 'D', EM.Dealer_Code , AX.Sorting_no , AX.Bank_Id ,AX.Is_Highlight , AX.backcolor , AX.forecolor
					FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
								INNER JOIN 
									(
										SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code , I.Segment_ID FROM T0095_INCREMENT I WITH (NOLOCK)
											INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID
											INNER JOIN 
												( 
													SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)
													WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
													AND CMP_ID = @CMP_ID 
													GROUP BY EMP_ID
												) QRY ON
										I.EMP_ID = QRY.EMP_ID AND I.Increment_Id = QRY.Increment_Id
									) AS INC ON INC.EMP_ID = MS.EMP_ID
								INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
								INNER JOIN T0140_LOAN_TRANSACTION LT WITH (NOLOCK) ON LT.Emp_ID = MS.Emp_ID and LT.For_Date = MS.Month_End_Date
								Inner JOIN T0010_COMPANY_MASTER CM WITH (NOLOCK) ON CM.Cmp_Id = EM.Cmp_ID
								Left OUTER JOIN T0040_Business_Segment BS WITH (NOLOCK) on BS.Segment_ID = INC.Segment_ID
								Left OUTER JOIN T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
								Left OUTER JOIN T9999_Ax_Mapping AX WITH (NOLOCK) on AX.Loan_id = @CUR_LOAN_ID
								Left Outer JOin T0100_ADVANCE_PAYMENT AP WITH (NOLOCK) on AP.Emp_ID = EM.Emp_ID and AP.For_Date = DATEADD(DAY , 1 , @TO_date)
							WHERE INC.Center_ID =@CUR_CENTER_ID and LT.Loan_ID = @CUR_LOAN_ID AND MS.Cmp_ID = @CUR_CMP_ID
								and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 
								--and isnull(ms.is_FNF,0)  = 0 			
					
						
				END
			ELSE IF @CUR_AD_ID = 2052	--This will Give you Interest of Loan Entries Consolidated
				BEGIN
				
					SELECT @SUM_AMT = ROUND(ISNULL(SUM(MS.LOAN_INTREST_AMOUNT),0),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
							INNER JOIN (
								SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK)
									INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID 
									INNER JOIN 
										( 
											SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
											WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
											AND CMP_ID = @CMP_ID 
											GROUP BY EMP_ID
										) QRY ON I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id) AS INC ON INC.EMP_ID = MS.EMP_ID
									INNER JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MS.EMP_ID = EM.EMP_ID
									WHERE INC.CENTER_ID =@CUR_CENTER_ID AND MS.Sal_Cal_Days <> 0 AND MS.Cmp_ID = @CUR_CMP_ID
									AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) -- AND ISNULL(MS.IS_FNF,0)  = 0 --AND EM.DEALER_CODE = @CUR_BUS_AREA
						
			
						UPDATE @AX SET AMOUNT = @SUM_AMT
						WHERE AD_ID = @CUR_AD_ID AND CC_ID = @CUR_CENTER_ID		
						
				END
			Else If @CUR_AD_ID = 0 and @Bank_id <> 0		--This will give Bank wise Summary
				BEGIN
		
						SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) --- (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0)) 
						from MONTHLY_EMP_BANK_PAYMENT MEB 
							Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
							Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
							LEFT JOIN T0040_BANK_MASTER BM WITH (NOLOCK) on BM.Bank_ID = @Bank_id
						WHERE I.Center_ID = @CUR_CENTER_ID And MEB.Emp_Bank_ID = @Bank_id  and 
						MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						GROUP BY I.Center_ID ,BM.Bank_Name	
						
						--Taking From Salary--
						--	SELECT @SUM_AMT = isnull(Sum(MS.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0)) from T0200_MONTHLY_SALARY MS
						--	Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--	LEFT JOIN T0040_BANK_MASTER BM on BM.Bank_ID = @Bank_id
						--	LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.Center_ID = @CUR_CENTER_ID And I.Bank_ID = @Bank_id
						--and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--GROUP BY I.Center_ID ,BM.Bank_Name	
						
				
						UPDATE @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC' 
						WHERE AD_ID = @CUR_AD_ID and  cc_id = @CUR_CENTER_ID and Bank_id = @Bank_id
				
					
				
				END
			
			Else If @CUR_AD_ID = 0 and @VENDOR_CODE = 'Cheque'	--This will give Cash Summary
				BEGIN
			
						SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) --- (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						from MONTHLY_EMP_BANK_PAYMENT MEB WITH (NOLOCK)
						Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
						Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
						WHERE I.CENTER_ID = @CUR_CENTER_ID AND MEB.PAYMENT_MODE = 'CHEQUE' 
						and MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) --AND ISNULL(MS.IS_FNF,0)  = 0 
						GROUP BY I.CENTER_ID
						
						
						----Taking from Salary--
						--SELECT @SUM_AMT = isnull(Sum(MS.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						--from T0200_MONTHLY_SALARY MS
						--Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.CENTER_ID = @CUR_CENTER_ID AND I.PAYMENT_MODE = 'CHEQUE'
						--AND MONTH(MONTH_END_DATE) = MONTH(@TO_DATE)  AND YEAR(MONTH_END_DATE) = YEAR(@TO_DATE) --AND ISNULL(MS.IS_FNF,0)  = 0 
						--GROUP BY I.CENTER_ID
				
						UPDATE @AX set AMOUNT = @SUM_AMT,vender_Code = 'Cheque'  
						WHERE AD_ID = @CUR_AD_ID and  CC_ID = @CUR_CENTER_ID AND vender_Code = 'Cheque'

				END
			Else If @CUR_AD_ID = 0 and @VENDOR_CODE = 'Cash'	--This will give Cash Summary
				BEGIN
			--Taking from Salary--
						--SELECT @SUM_AMT = isnull(Sum(Ms.Net_Amount),0) - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						--from T0200_MONTHLY_SALARY MS
						--Inner JOIN T0095_INCREMENT I on Ms.Increment_ID = I.Increment_ID
						--LEFT OUTER JOIN 
						--	(
						--		SELECT MAD.EMP_ID, ISNULL(SUM(MAD.M_AD_AMOUNT),0) AS M_AD_AMOUNT , MAD.TO_DATE FROM T0210_MONTHLY_AD_DETAIL MAD
						--		INNER JOIN T0050_AD_MASTER AD ON MAD.AD_ID = AD.AD_ID
						--		WHERE  AD.AD_NOT_EFFECT_SALARY  = 1 AND MAD.M_AD_NOT_EFFECT_SALARY = 0
						--		AND MONTH(MAD.To_date) = MONTH(@TO_DATE)  AND YEAR(MAD.To_date) = YEAR(@TO_DATE)
						--		GROUP BY MAD.Emp_ID , MAD.TO_DATE
						--	) QRY2 on Qry2.Emp_ID = MS.Emp_ID and MONTH(Qry2.To_date) = MONTH(@TO_DATE) and YEAR(Qry2.To_date) = YEAR(@TO_DATE)
						--WHERE I.Center_ID = @CUR_CENTER_ID and Payment_Mode = 'Cash'
						--and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						--GROUP BY I.Center_ID
				
				--Taking from Payment Process--
				SELECT @SUM_AMT = isnull(Sum(MEB.Net_Amount),0) -- - (isnull(Sum(Ms.Leave_Salary_Amount),0) + isnull(Sum(Ms.Gratuity_Amount),0) + isnull(Sum(QRY2.M_AD_AMOUNT),0))
						from MONTHLY_EMP_BANK_PAYMENT MEB
						Inner Join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on MEB.Emp_ID = MS.Emp_ID and MONTH(MEB.For_date) = MONTH(@TO_DATE)  AND YEAR(MEB.For_date) = YEAR(@TO_DATE)
						Inner JOIN T0095_INCREMENT I WITH (NOLOCK) on Ms.Increment_ID = I.Increment_ID
						WHERE I.Center_ID = @CUR_CENTER_ID and MEB.Payment_Mode = 'Cash' 
						and MEB.Process_Type = 'Salary' and MEB.Cmp_ID = @CUR_CMP_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) --and isnull(ms.is_FNF,0)  = 0 
						GROUP BY I.Center_ID
						
						UPDATE @AX set AMOUNT = @SUM_AMT,vender_Code = 'Cash' 
						WHERE AD_ID = @CUR_AD_ID and  CC_ID = @CUR_CENTER_ID AND vender_Code = 'Cash'

				END
				
			FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID, @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA , @Bank_id , @VENDOR_CODE
		end 
	close cur_ax
	Deallocate cur_ax
	
--select AMOUNT as AMT ,Sorting_No , CASE WHEN Sorting_No = (SELECT MAX(Sorting_No) from T9999_Ax_Mapping where Cmp_id = @Cmp_ID)
--					THEN 'X'
--					ELSE
--					''
--					END as [End Mark] from @AX
--Where COSTCENT = 520003-- order by Sorting_No

	--if @Flag in ( 'D','A','S')
	--	BEGIN 
	--		SELECT	REPLACE(CONVERT(NVARCHAR, DOCDT, 103), ' ', '/') AS DOCDT,EMPCD,EMPNAME,ROW_NUMBER() OVER (ORDER BY Sorting_No,COSTCENT DESC ) AS VOUNO, 
	--				REPLACE(CONVERT(NVARCHAR, VOUDT, 103), ' ', '/') AS VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1 AS 'ACCDDR',
	--				ACCTTYPE,ACCDDR AS 'ACCODECR',PAYREFNO,PAYREFDT,AMOUNT,TRANSACTION_TEXT AS 'DESC',CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND 
	--		FROM @AX  
	--		WHERE VOUCHER_FLAG = @FLAG AND AMOUNT > 0 
	--		ORDER BY COSTCENT
	--	END 
	--else
	--	BEGIN
	--		SELECT	REPLACE(CONVERT(NVARCHAR, DOCDT, 103), ' ', '/') AS DOCDT,EMPCD,EMPNAME,ROW_NUMBER() OVER (ORDER BY Sorting_No,COSTCENT DESC ) AS VOUNO, 
	--				REPLACE(CONVERT(NVARCHAR, VOUDT, 103), ' ', '/') AS VOUDT,COSTCENT,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1 AS ACCODECR,
	--				ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,AMOUNT,TRANSACTION_TEXT AS 'DESC',CURRENCY,CUREXGRT,VENDER_CODE AS 'VENDOR CODE'  ,RECTNAME,VOUMONTH,EMPIND 
	--		FROM @AX  
	--		WHERE  AMOUNT > 0 --and VOUCHER_FLAG = @FLAG
	--		ORDER BY COSTCENT
	--	END
	--SELECT AMOUNT,ACCODE1,COSTCENT,deptcode FROM @AX  where voucher_Flag = @Flag and AMOUNT>0 order BY ACCODE1,COSTCENT,deptcode 
	
	SELECT	Is_Highlight ,backcolor , forecolor,	--Default Fields for Highlight (Will Hide in Reports)
	CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN REPLACE(CONVERT(NVARCHAR, DOCDT, 103),'/','.')
				 ELSE ''
				 END AS DOCDT,
	CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN cocode
				 ELSE ''
				 END AS cocode,
	CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN REPLACE(CONVERT(NVARCHAR, DOCDT, 103),'/','.')
				 ELSE ''
				 END AS POSTDATE,
	CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN 'SALARY TO EMPLOYEE'
				 ELSE ''
				 END as text1 ,
	CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN 'SA'
				 ELSE ''
				 END as postkey01 , 
	(ROW_NUMBER() OVER (PARTITION BY COSTCENT ORDER BY COSTCENT , Sorting_No ASC ) * 10) AS [Item No], 
			CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002)
					THEN '40' 
				WHEN (vender_Code is Not NULL) AND ((ACCODE1 is Null) or ACCODE1 = '')
					THEN '39'
				 ELSE '50'
				 END as postkey01,
				 
				 ACCODE1 AS [GL A/C],
			CASE WHEN (ACCODE1 is NULL) and (vender_Code is NULL)
					THEN 'nil' 
				 ELSE vender_Code
				 END as Vendor ,cocode , '' as [tax code],TRANSACTION_TEXT AS 'text2',
				 BUSIUNIT as Business_Segment_code,COSTCENT as costcode,
			CASE WHEN (vender_Code is Not NULL) AND ((ACCODE1 is Null) or ACCODE1 = '')
					THEN 'L' 
				 ELSE '0'
				 END as splgl,
			CASE WHEN (AD_flag is NULL) AND (AD_ID = 1002) 
					THEN 'H' 
				 ELSE 'S'
				 END as [Dr/Cr],(ROW_NUMBER() OVER (PARTITION BY COSTCENT ORDER BY COSTCENT , Sorting_No ASC ) * 10) AS [Item No], 'INR' as Currency , 
				 AMOUNT as AMT,
				CASE WHEN Sorting_No = (SELECT MAX(Sorting_No) from @AX where Cmp_id = @Cmp_ID and AMOUNT > 0)
					THEN 'X'
					ELSE
					''
					END as [End Mark]				
			FROM @AX  T
			--WHERE  COSTCENT is NOT NULL AND Sorting_No < 100 --AND VOUCHER_FLAG = 'D'
			--		AND (AMOUNT > 0 OR (Bank_id > 0 AND EXISTS (SELECT 1 FROM @AX Where Bank_id= 0 AND AMOUNT > 0)))
			--ORDER BY COSTCENT
			WHERE  COSTCENT is NOT NULL AND Sorting_No < 100 --AND VOUCHER_FLAG = 'D'
			AND (AMOUNT > 0 OR (Bank_id > 0 AND EXISTS (SELECT 1 FROM @AX T1 Where T1.Bank_id= 0 AND T1.AMOUNT > 0 AND T1.COSTCENT=T.COSTCENT)))
			ORDER BY COSTCENT



RETURN


