using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0220PfChallan
{
    public decimal PfChallanId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal BankId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public DateTime PaymentDate { get; set; }

    public string ECode { get; set; } = null!;

    public string AccGrNo { get; set; } = null!;

    public string PaymentMode { get; set; } = null!;

    public string ChequeNo { get; set; } = null!;

    public decimal TotalSubScriber { get; set; }

    public decimal TotalWagesDue { get; set; }

    public decimal? TotalChallanAmount { get; set; }

    public string? BranchName { get; set; }

    public string? BranchIdMulti { get; set; }

    public string? BranchNameMulti { get; set; }
}
