using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0140LoanTransaction
{
    public string? LoanName { get; set; }

    public decimal LoanTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoanId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LoanOpening { get; set; }

    public decimal LoanIssue { get; set; }

    public decimal LoanReturn { get; set; }

    public decimal LoanClosing { get; set; }
}
