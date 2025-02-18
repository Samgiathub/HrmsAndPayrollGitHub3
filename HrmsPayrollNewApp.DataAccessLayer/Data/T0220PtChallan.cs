using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0220PtChallan
{
    public decimal ChallanId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? BranchId { get; set; }

    public decimal Month { get; set; }

    public decimal Year { get; set; }

    public DateTime? PaymentDate { get; set; }

    public decimal? BankId { get; set; }

    public string? BankName { get; set; }

    public decimal TaxAmount { get; set; }

    public decimal TaxReturnAmount { get; set; }

    public decimal InterestAmount { get; set; }

    public decimal PenaltyAmount { get; set; }

    public decimal OtherAmount { get; set; }

    public decimal TotalAmount { get; set; }

    public decimal EmpCount { get; set; }

    public string? BranchIdMulti { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
