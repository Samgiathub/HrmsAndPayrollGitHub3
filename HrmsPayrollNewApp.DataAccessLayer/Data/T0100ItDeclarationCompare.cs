using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100ItDeclarationCompare
{
    public decimal ItTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal ItId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal Amount { get; set; }

    public string DocName { get; set; } = null!;

    public decimal? LoginId { get; set; }

    public DateTime? SystemDate { get; set; }

    public byte? RepeatYearly { get; set; }

    public decimal AmountEss { get; set; }

    public byte ItFlag { get; set; }

    public string? FinancialYear { get; set; }

    public bool IsLock { get; set; }

    public string? IsMetroNonMetro { get; set; }

    public string? IsCompareFlag { get; set; }
}
