using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140ReimClaimTransacationPaymentMonthly
{
    public decimal TransId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ClaimId { get; set; }

    public decimal SalTransId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal Opening { get; set; }

    public decimal Credit { get; set; }

    public decimal Debit { get; set; }

    public decimal Balance { get; set; }
}
