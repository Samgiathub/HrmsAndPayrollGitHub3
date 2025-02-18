using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100MonthlyLoanSkipApproval
{
    public decimal TranId { get; set; }

    public decimal? RequestAprId { get; set; }

    public decimal? RequestId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoanAprId { get; set; }

    public decimal? LoanId { get; set; }

    public decimal? OldInstallAmount { get; set; }

    public decimal? NewInstallAmount { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? RptLevel { get; set; }

    public byte? FinalApproval { get; set; }
}
