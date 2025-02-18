using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040CurrencyMaster
{
    public decimal CurrId { get; set; }

    public decimal CmpId { get; set; }

    public string CurrName { get; set; } = null!;

    public decimal CurrRate { get; set; }

    public string CurrMajor { get; set; } = null!;

    public string CurrSymbol { get; set; } = null!;

    public string CurrSubName { get; set; } = null!;

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
