using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020InterestDeductionFnf
{
    public decimal TranId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoanId { get; set; }

    public decimal? LoanAprId { get; set; }

    public decimal? LoanAmount { get; set; }

    public decimal? LoanInterestAmount { get; set; }

    public decimal? IsFirstDeductionFlag { get; set; }

    public decimal? IsDeductionFlag { get; set; }
}
