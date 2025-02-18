using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150TravelSettlementExpenseTransaction
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime? ForDate { get; set; }

    public decimal OpeningAmount { get; set; }

    public decimal Amount { get; set; }

    public decimal ClosingAmount { get; set; }

    public string? TravelSettelmentId { get; set; }
}
