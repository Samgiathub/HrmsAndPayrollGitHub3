using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140LoanTransaction
{
    public decimal LoanTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoanId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LoanOpening { get; set; }

    public decimal LoanIssue { get; set; }

    public decimal LoanReturn { get; set; }

    public decimal LoanClosing { get; set; }

    public decimal IsLoanInterestFlag { get; set; }

    public decimal SubsidyAmount { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0040LoanMaster Loan { get; set; } = null!;
}
